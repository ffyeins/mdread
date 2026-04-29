# mdread

A single bash script that converts markdown files to GitHub-rendered HTML and opens them in the default browser. macOS only.

## Project Structure

- `mdread` — the entire tool, a self-contained bash script

## How It Works

1. Sends markdown content to GitHub's Markdown API (`POST /markdown`) for rendering
2. Wraps the API response in an HTML template with `github-markdown-css` (dark) from CDN
3. Includes inline CSS for GitHub's "pretty-lights" syntax highlighting token colors
4. Conditionally injects MathJax/Mermaid CDN scripts only when content needs them
5. Adds copy-to-clipboard buttons on code blocks via inline JavaScript
6. Writes to a temp file in `/tmp/mdread.XXXXXX.html`
7. Opens each file with `open` (macOS)
8. Background cleanup removes temp files after 10 seconds
9. EXIT trap cleans up temp files on early exit or error

## Dependencies

- `curl` (ships with macOS)
- `jq` or `python3` (for JSON encoding — `python3` ships with macOS)
- macOS `open` command
- Internet connection (GitHub API + CDN for CSS/MathJax/Mermaid)

## Key Details

- Rendering is pixel-perfect — GitHub's own API produces the HTML, identical to github.com
- CSS uses `github-markdown-css` (sindresorhus) dark variant from CDN
- Syntax highlighting colors use GitHub's "pretty-lights" CSS classes (`pl-k`, `pl-s`, etc.) included inline
- Auth token via `GITHUB_TOKEN` or `GH_TOKEN` env vars increases rate limit from 60/hr to 5000/hr
- JSON payload built with `jq -Rs` (preferred) or `python3` fallback
- HTML assembly uses quoted heredocs (`<<'EOF'`) + `printf '%s'` for variable content to avoid shell expansion of API output
- Mermaid.js needs code blocks unwrapped from `<pre><code class="language-mermaid">` — done via inline script
- MathJax loaded conditionally when source file contains `$`, `$$`, or `\(` patterns
- Per-file error handling: API failures skip the file instead of aborting the whole script
- Filenames are HTML-escaped before injection into `<title>` to prevent malformed HTML

## Known Limitations

- Requires internet connection (GitHub API for rendering + CDN for CSS/JS)
- Rate-limited: 60 requests/hr without auth token, 5000/hr with token
- Relative image paths in markdown won't resolve (HTML is served from `/tmp`)
- `--help`/`--version` only checked on first argument
