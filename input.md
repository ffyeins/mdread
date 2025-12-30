# CLAUDE.md - Traffic Monitor Project

## Overview

A traffic monitoring system that queries the Google Routes API to track commute times between predefined locations in Buenos Aires, Argentina. Data is stored in SQLite and visualized with Grafana.

**Location:** `~/docker/traffic-monitor/` on the Arch Linux home server

---

## Architecture

```
┌─────────────────────┐     ┌──────────────────┐     ┌─────────────┐
│   Systemd Timers    │────▶│  Docker Compose  │────▶│ Google API  │
│  (day/night sched)  │     │  (one container  │     │  Routes v2  │
└─────────────────────┘     │   per route)     │     └─────────────┘
                            └────────┬─────────┘
                                     │
                            ┌────────▼─────────┐
                            │   SQLite DB      │
                            │  ./data/traffic.db│
                            └────────┬─────────┘
                                     │
                            ┌────────▼─────────┐
                            │     Grafana      │
                            │   (port 3000)    │
                            └──────────────────┘
```

**Execution model:** Containers are NOT long-running. They have `restart: "no"` and are triggered by systemd timers (`traffic-monitor-day.timer`, `traffic-monitor-night.timer`) which run `docker compose run --rm <service>`.

---

## Files

| File | Purpose |
|------|---------|
| `traffic_monitor.py` | Main script - queries API, stores to SQLite |
| `docker-compose.yml` | Defines route services + Grafana |
| `.env` | API key, addresses, coordinates (NOT in git) |
| `Dockerfile` | Python 3.11-slim with requests library |
| `data/traffic.db` | SQLite database (NOT in git) |
| `grafana-data/` | Grafana runtime data (NOT in git) |
| `migrate_database.py` | Database migration tool (for schema changes) |

---

## Active Routes (7 total)

| Service Name | Route | Direction |
|--------------|-------|-----------|
| `traffic-monitor-home-work` | Pilar → Chiclana office | Morning commute |
| `traffic-monitor-work-home` | Chiclana office → Pilar | Evening commute |
| `traffic-monitor-home-cabahome` | Pilar → CABA apartment | To city |
| `traffic-monitor-cabahome-home` | CABA apartment → Pilar | From city |
| `traffic-monitor-workclient-home` | Client office (Peru) → Pilar | From client |
| `traffic-monitor-peaje-puesto` | Peaje Pilar → Puesto Uno | Highway segment |
| `traffic-monitor-puesto-peaje` | Puesto Uno → Peaje Pilar | Highway segment (reverse) |

---

## Environment Variables

Each container receives:
- `GOOGLE_ROUTES_API_KEY` - API authentication
- `ORIGIN_ADDRESS` - Start point (address string or `lat,lng`)
- `DESTINATION_ADDRESS` - End point (address string or `lat,lng`)
- `ROUTE_NAME` - Identifier stored in database
- `TZ` - `America/Argentina/Buenos_Aires`

**Address format:** Either full address string or coordinates without spaces: `-34.457028,-58.721389`

---

## Database Schema

```sql
CREATE TABLE traffic_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    route_name TEXT NOT NULL,
    timestamp INTEGER NOT NULL,        -- Unix timestamp
    duration_seconds INTEGER NOT NULL, -- Travel time in seconds (traffic-aware)
    distance_meters INTEGER,           -- Route distance in meters
    day_of_week INTEGER,               -- 0=Monday, 6=Sunday
    hour INTEGER,                      -- 0-23
    minute INTEGER                     -- 0-59
);

-- Indexes
CREATE INDEX idx_route_timestamp ON traffic_data(route_name, timestamp);
CREATE INDEX idx_route_day_hour ON traffic_data(route_name, day_of_week, hour);
```

**Note:** The schema was simplified in December 2024 to remove unused columns (`duration_in_traffic_seconds`, `traffic_ratio`, `route_condition`). Historical data was migrated preserving all meaningful information.

---

## API Details

**Endpoint:** `https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix`

**Request:**
- `travelMode: DRIVE`
- `routingPreference: TRAFFIC_AWARE`
- `departureTime`: Current time + 1 minute (required for traffic data)

**Response fields used:**
- `duration` - Travel time string (e.g., "1800s") - stored as `duration_seconds`
- `distanceMeters` - Route distance - stored as `distance_meters`

**Quota:** 40,000 requests/month free tier (~11 routes max with current scheduling)

---

## Retry Logic

- `MAX_RETRIES = 5`
- `RETRY_DELAY = 60` seconds between attempts
- Exits with success on first successful API call
- Logs all attempts and final outcome

---

## Systemd Integration

Timers are defined in `/etc/systemd/system/`:
- `traffic-monitor-day.timer` - Runs every 10 minutes during day
- `traffic-monitor-night.timer` - Runs every 30 minutes at night
- `traffic-monitor.service` - Contains `ExecStart` lines for each route

Each route runs as: `docker compose run --rm <service-name>`

---

## Common Operations

```bash
# Test a single route manually
cd ~/docker/traffic-monitor
docker compose run --rm traffic-monitor-home-work

# Check recent data
sqlite3 -column -header ./data/traffic.db "
SELECT route_name, datetime(timestamp, 'unixepoch', 'localtime') as time,
       duration_seconds/60.0 as minutes, distance_meters/1000.0 as km
FROM traffic_data
ORDER BY timestamp DESC LIMIT 10;"

# Count samples per route
sqlite3 -column -header ./data/traffic.db "
SELECT route_name, COUNT(*) as samples
FROM traffic_data
GROUP BY route_name;"

# Check timer status
systemctl list-timers | grep traffic

# View Grafana
# http://192.168.0.50:3000 (admin/admin)

# Rebuild after code changes
docker compose build
```

---

## Adding a New Route

1. Add address to `.env`:
   ```bash
   NEW_LOCATION=Address or -34.123,-58.456
   ```

2. Add service to `docker-compose.yml` (copy existing, change ROUTE_NAME)

3. Add `ExecStart` line to systemd service:
   ```bash
   sudo nvim /etc/systemd/system/traffic-monitor.service
   # Add: ExecStart=/usr/bin/docker compose run --rm traffic-monitor-new-route
   sudo systemctl daemon-reload
   ```

4. Test manually, verify in database

---

## Known Quirks

1. **Traffic-aware duration only**: The Google Routes API only returns traffic-aware travel times. There is no baseline "no-traffic" duration available, so `duration_seconds` always reflects current traffic conditions.

2. **Coordinate format**: Must be `lat,lng` with NO spaces. The script detects coordinates by checking if the string contains a comma but no letters.

3. **Database locking**: Multiple containers write to the same SQLite file. SQLite handles this but could bottleneck if many routes run simultaneously.

4. **API response validation**: The script no longer validates route conditions. It assumes any successful API response with duration data is valid and stores it.

---

## Database Migrations

When making schema changes, follow this pattern:

1. Create a migration script (see `migrate_database.py` as example)
2. Test migration on a backup copy of the database first
3. Migration steps:
   - Create new table with updated schema
   - Copy data from old table (SELECT INTO new table)
   - Verify row counts match
   - Drop old table
   - Rename new table
   - Recreate indexes
4. Update `traffic_monitor.py` to match new schema
5. Rebuild Docker containers
6. Test with manual route execution

**Historical migrations:**
- 2024-12-24: Removed `duration_in_traffic_seconds`, `traffic_ratio`, `route_condition` columns (20,010 records migrated)

---

## Integration with Server

- Connected to `media-network` Docker bridge
- Grafana accessible at port 3000 (local/VPN only)
- Part of the home server monitoring stack
- Documentation: `~/documentation/traffic-monitor-documentation.md`
