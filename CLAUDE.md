# mdread

A single bash script that converts markdown files to GitHub dark-themed HTML and opens them in the default browser. macOS only.

## Project Structure

- `mdread` — the entire tool, a self-contained bash script

## How It Works

1. Converts markdown to HTML using `pandoc -f gfm -t html5 --mathjax`
2. Wraps the output in an HTML template with inline GitHub dark theme CSS
3. Conditionally injects MathJax/Mermaid CDN scripts only when content needs them
4. Writes to a temp file in `/tmp/mdread.XXXXXX.html`
5. Opens each file with `open` (macOS)
6. Background cleanup removes temp files after 10 seconds
7. EXIT trap cleans up temp files on early exit or error

## Dependencies

- `pandoc` >= 3.9 (installed via Homebrew) — needed for GFM alerts support
- macOS `open` command
- Internet connection for MathJax and Mermaid rendering (CDN)

## Key Details

- Uses GFM (GitHub Flavored Markdown) mode for tables, task lists, fenced code blocks, alerts, footnotes, emoji, math
- Syntax highlighting uses pandoc's `breezedark` tokenizer with custom CSS colors matching GitHub's dark theme
- Not using `--standalone` — we provide our own HTML wrapper
- `--mathjax` flag wraps math in `\(` `\)` delimiters that MathJax understands
- Mermaid.js needs `<code>` tags unwrapped from pandoc's `<pre class="mermaid"><code>` output — done via inline script
- Temp file creation uses `mktemp` + rename to add `.html` extension (macOS `mktemp` only replaces trailing Xs)
- Per-file error handling: pandoc failures skip the file instead of aborting the whole script
- Filenames are HTML-escaped before injection into `<title>` to prevent malformed HTML
- `--` is passed before filenames to pandoc to prevent filenames starting with `-` from being parsed as flags

## Known Limitations

- Relative image paths in markdown won't resolve (HTML is served from `/tmp`)
- GitHub autolinked references (`#123`, `@user`, SHAs) are not supported — they require repo context
- `--help`/`--version` only checked on first argument
