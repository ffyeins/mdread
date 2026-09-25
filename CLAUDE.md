# mdread

Two bash commands for working with markdown files — GitHub-style theme (dark default, light via `--light`), rendered locally. macOS only.

## Project Structure

- `mdread` — preview markdown in the browser (temp file, opened with `open`)
- `mdtohtml` — convert markdown to HTML files next to the source (permanent output). Must stay its own real script, not a symlink or a mode of `mdread`
- `lib/render.sh` — shared code both scripts `source`: option parsing, the comrak call, the HTML template, CSS and page JavaScript
- `tests/run` — regression harness; its header documents the `.expect` format (checks, plus `@` directives such as `@ source` to reuse another fixture's markdown)
- `tests/fixtures/` — markdown inputs, `.expect` files and `img/`
- `test.md` — kitchen-sink sample for checking by eye (also rendered by the `kitchen-sink` fixture); its images come from `tests/fixtures/img/`

Each script defines `prog`, `VERSION` (mdread 5.x, mdtohtml 2.x) and `usage`, finds `lib/render.sh` via `readlink -f "${BASH_SOURCE[0]}"`, then calls `mdr_parse_args` and `mdr_render_html`.

## How It Works

Both tools share the rendering pipeline in `mdr_render_html`:

1. Renders markdown with `comrak --config-file none --unsafe` plus extensions `table, strikethrough, autolink, tasklist, footnotes, alerts, math-dollars, math-code` and `--tasklist-classes --gemoji --header-id-prefix '' --front-matter-delimiter '---' --syntax-highlighting none`
2. Applies GFM's tagfilter with `sed` (`mdr_tagfilter`); comrak's own tagfilter extension is deprecated and slated for removal
3. Renders YAML front matter (which comrak strips) as a one-row table, or a YAML code block if it isn't flat `key: value` (`mdr_frontmatter`, awk)
4. Wraps the body in a template with a per-run CSP nonce, pinned `github-markdown-css` (dark or light file, with SRI) and a small inline stylesheet (layout, copy button; theme colors via `--mdr-*` custom properties)
5. Page script (classic, runs during parse): drops images for the other theme, adds heading-anchor icons and alert octicons, adds copy buttons (skipping Mermaid/math blocks), and in preview mode keeps `#links` on the page
6. Conditionally adds Mermaid (when the body has `<code class="language-mermaid"`) and MathJax (when it has `data-math-style=`)
7. starry-night ES module (only when a fenced code block names a language, including the front-matter YAML fallback) highlights code; languages outside its `common` bundle load on demand from a flag→scope map

**mdread** additionally:
- Writes pages to `${TMPDIR:-/tmp}/mdread.XXXXXX.html` (mktemp then rename, since macOS mktemp only replaces trailing Xs)
- Emits `<base href="file:///<source dir>/">` so relative images and links resolve; the page script handles `#links` because of it
- Opens each page with `open`; sweeps its own pages older than a day at startup instead of deleting new ones
- EXIT trap removes pages if it exits before opening them

**mdtohtml** additionally:
- Writes `<name>.html` next to the source (`.md/.markdown/.mdown/.mkd/.mkdn` replaced case-insensitively, else `.html` appended) via a temp file + `mv`, keeping umask permissions
- Refuses to overwrite an `.html` without its `<meta name="generator" content="mdtohtml …">` marker (or mdtohtml 1.x's major-pinned stylesheet link) unless `-f/--force`
- Prints each output path to stdout

## Dependencies

Keep dependencies to a minimum. comrak is the only runtime dependency beyond macOS built-ins (bash 3.2, sed, awk, od, open). Don't add a tool, package or CDN library without saying what it replaces or why built-ins can't do the job, and offer a no-new-dependency alternative. Dev-only tools (headless Chrome for `tests/run`) must stay out of the runtime path.

- `comrak` (`brew install comrak`) — CommonMark + GFM parser (cmark-gfm compatible); replaced cmark-gfm because it keeps math intact and builds in alerts, heading IDs, front matter and emoji
- macOS `open` command
- Internet connection only for CDN assets (CSS/JS for styling, syntax highlighting, MathJax, Mermaid)
- Tests: Google Chrome (headless) and internet

## Key Details

- Rendering is done locally — no API calls, no rate limits, no auth tokens
- CDN versions are pinned in `lib/render.sh`: github-markdown-css 5.9.0, mermaid 11.17.2, mathjax 3.2.2 (all with SRI; the CSS uses the non-minified files because jsDelivr's auto-minified ones can't carry SRI), starry-night 3.11.0 and hast-util-to-dom 4.0.1 from esm.sh (no SRI). Bumping a version means refreshing its hash (command in the file's header)
- CSP: `script-src 'nonce-…' 'strict-dynamic' 'wasm-unsafe-eval'` (starry-night's oniguruma needs WASM). Every script we emit must carry the nonce. `<base>` goes before the CSP meta so `base-uri 'none'` only blocks `<base>` from the markdown
- github-markdown-css 5.9.0 already styles alerts, task lists, footnotes, `kbd`, `pl-*` syntax colors and heading anchors, so the inline CSS doesn't repeat them
- Math: comrak marks math with `data-math-style`; the page wraps exactly those elements in `\(…\)` / `\[…\]` and typesets them with `MathJax.typesetPromise` (`startup.typeset: false`), so MathJax never scans for `$`. comrak's rule: `$…$` is math only when the text touches both dollar signs and the closing `$` isn't followed by a digit (`$5 and $10` stays text); `\$` is a literal dollar. Also supported: ```` ```math ```` blocks and `` $`…`$ ``
- Emoji come from comrak's `--gemoji` (standard Unicode shortcodes); GitHub's custom image emoji (`:octocat:`, `:shipit:`) stay as text
- Options are parsed anywhere (`--light/--dark`, last wins; `-h`, `-v`, `--`); dash-leading file names are prefixed with `./` before use
- Exit codes: 0 all files converted; 1 any input failed (the others are still processed); 2 usage error
- Escape HTML with `mdr_escape_html` (sed), not `${var//…}`: bash 5.2 treats `&` in the replacement as the matched text
- Keep scripts bash 3.2-safe (macOS `/usr/bin/env bash`): no `${x,,}`, guard empty arrays under `set -u`
- Run `shellcheck -x mdread mdtohtml lib/render.sh tests/run` and `tests/run` after changes

## Known Limitations

- CDN assets require internet — HTML renders but is unstyled and unhighlighted without it
- Relative links to other `.md` files open the raw markdown (GitHub would render it)
- Syntax highlighting covers starry-night's `common` bundle plus the on-demand map in `lib/render.sh`; other languages render plain
- Nested YAML front matter is shown as a YAML code block rather than GitHub's nested tables

## Documentation

`README.md` is for humans: keep it simple and short (what it does, install, usage, a feature list). Flags, exit codes, internals and edge cases belong in this file.
