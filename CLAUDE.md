# mdread

A single bash script that converts markdown files to GitHub dark-themed HTML and opens them in the default browser. macOS only.

## Project Structure

- `mdread` — the entire tool, a self-contained bash script

## How It Works

1. Converts markdown to HTML using `pandoc -f gfm -t html5`
2. Wraps the output in an HTML template with inline GitHub dark theme CSS
3. Writes to a temp file in `/tmp/mdread.XXXXXX.html`
4. Opens all files with `open` (macOS)
5. Background cleanup removes temp files after 3 seconds

## Dependencies

- `pandoc` (installed via Homebrew)
- macOS `open` command

## Key Details

- Uses GFM (GitHub Flavored Markdown) mode for tables, task lists, fenced code blocks
- Syntax highlighting uses pandoc's `breezedark` tokenizer with custom CSS colors matching GitHub's dark theme
- Not using `--standalone` — we provide our own HTML wrapper
- Temp file creation uses `mktemp` + rename to add `.html` extension (macOS `mktemp` only replaces trailing Xs)
