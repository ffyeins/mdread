# mdread

Two bash scripts for working with markdown files — GitHub-style dark theme, rendered locally. macOS only.

## Project Structure

- `mdread` — preview markdown in the browser (temp file, auto-cleanup)
- `mdtohtml` — convert markdown to standalone HTML files (permanent output)

## How It Works

Both tools share the same rendering pipeline:

1. Renders markdown to HTML locally using `cmark-gfm` with all GFM extensions
2. Wraps the output in an HTML template with `github-markdown-css` (dark) from CDN
3. Loads `@wooorm/starry-night` from CDN for syntax highlighting (produces `pl-*` classes matching GitHub)
4. Conditionally injects MathJax/Mermaid CDN scripts only when content needs them
5. Adds copy-to-clipboard buttons on code blocks via inline JavaScript

**mdread** additionally:
6. Writes to a temp file in `/tmp/mdread.XXXXXX.html`
7. Opens each file with `open` (macOS)
8. Background cleanup removes temp files after 10 seconds
9. EXIT trap cleans up temp files on early exit or error

**mdtohtml** additionally:
6. Writes `.html` files next to the source (e.g. `test.md` → `test.html`)
7. Prints each output path to stdout

## Dependencies

- `cmark-gfm` (`brew install cmark-gfm`) — GitHub's own markdown parser
- macOS `open` command
- Internet connection only for CDN assets (CSS/JS for styling, syntax highlighting, MathJax, Mermaid)

## Key Details

- Rendering is done locally via `cmark-gfm` — no API calls, no rate limits, no auth tokens
- GFM extensions enabled: table, autolink, tagfilter, strikethrough, tasklist, footnotes
- `--unsafe` flag allows raw HTML passthrough in markdown
- CSS uses `github-markdown-css` (sindresorhus) dark variant from CDN
- Syntax highlighting uses `@wooorm/starry-night` (ES module from esm.sh CDN), which uses the same TextMate grammars as GitHub and produces identical `pl-*` CSS classes
- Inline `pl-*` CSS provides GitHub's "pretty-lights" dark syntax colors
- GitHub-style alerts (`> [!NOTE]`, `> [!TIP]`, etc.) transformed from blockquotes to styled divs via inline JS
- Emoji shortcodes (`:rocket:`, `:+1:`, etc.) replaced with unicode emoji via inline JS
- HTML assembly uses quoted heredocs (`<<'EOF'`) + `printf '%s'` for variable content to avoid shell expansion
- Mermaid.js code blocks detected by `language-mermaid` class, unwrapped from `<pre><code>` via inline script
- MathJax loaded conditionally when source file contains `$`, `$$`, or `\(` patterns
- Filenames are HTML-escaped before injection into `<title>` to prevent malformed HTML

## Known Limitations

- CDN assets (CSS, starry-night, MathJax, Mermaid) require internet — HTML renders but is unstyled without it
- Relative image paths in markdown won't resolve in `mdread` (HTML is served from `/tmp`); `mdtohtml` output lives next to the source so relative paths work
- `--help`/`--version` only checked on first argument
- Syntax highlighting coverage depends on starry-night's "common" grammar bundle (~35 languages)
