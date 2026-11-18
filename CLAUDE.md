# mdread

Two bash commands for working with markdown files — GitHub-style theme (dark default, light via `--light`), rendered locally. macOS only.

## Project Structure

- `mdread` — preview markdown in the browser (temp file, opened with `open`)
- `mdtohtml` — convert markdown to HTML files next to the source (permanent output). Must stay its own real script, not a symlink or a mode of `mdread`
- `lib/render.sh` — shared code both scripts `source`: option parsing, the comrak call, the HTML template, CSS and page JavaScript
- `tests/run` — regression harness; its header documents the `.expect` format (checks, plus `@` directives such as `@ source` to reuse another fixture's markdown)
- `tests/fixtures/` — markdown inputs, `.expect` files and `img/`; `mermaid-tall.md` (a tall, narrow flowchart) is also handy for checking `--max-diagram-height` and the expanded view's pan and zoom by eye
- `test.md` — kitchen-sink sample for checking by eye (also rendered by the `kitchen-sink` fixture); its images come from `tests/fixtures/img/`
- `mermaid.md` — one example of each Mermaid diagram type, for comparing diagram renderers by eye (also rendered by the `mermaid-gallery`, `mermaid-beautiful` and `mermaid-pele` fixtures)

Each script defines `prog`, `VERSION` (mdread 5.x, mdtohtml 2.x) and `usage`, finds `lib/render.sh` via `readlink -f "${BASH_SOURCE[0]}"`, then calls `mdr_parse_args` and `mdr_render_html <file> <theme> <renderer> <max diagram height> [base_url]` (base_url is mdread's).

## How It Works

Both tools share the rendering pipeline in `mdr_render_html`:

1. Renders markdown with `comrak --config-file none --unsafe` plus extensions `table, strikethrough, autolink, tasklist, footnotes, alerts, math-dollars, math-code` and `--tasklist-classes --gemoji --header-id-prefix '' --front-matter-delimiter '---' --syntax-highlighting none`
2. Applies GFM's tagfilter with `sed` (`mdr_tagfilter`); comrak's own tagfilter extension is deprecated and slated for removal
3. Renders YAML front matter (which comrak strips) as a one-row table, or a YAML code block if it isn't flat `key: value` (`mdr_frontmatter`, awk)
4. Wraps the body in a template with a per-run CSP nonce, pinned `github-markdown-css` (dark or light file, with SRI) and a small inline stylesheet (layout, copy and diagram buttons, the diagram dialog; theme colors and the diagram height limit via `--mdr-*` custom properties)
5. Page script (classic, runs during parse): drops images for the other theme, adds heading-anchor icons and alert octicons, adds copy buttons (skipping Mermaid/math blocks), shares `copyButton(className, label, getText)` and `addCodeCopy(pre)` with the diagram module as `window.mdr`, and in preview mode keeps `#links` on the page
6. Diagrams (only when the body has `<code class="language-mermaid"`): one module script for all three renderers, drawn by the one `--mermaid` picks:
   - `pele` (default): every diagram goes to Pele
   - `beautiful-mermaid`: routes each diagram by the type named on its first line that isn't blank or a `%%` comment. beautiful-mermaid's six types (`graph`/`flowchart`, `stateDiagram`, `sequenceDiagram`, `classDiagram`, `erDiagram`, `xychart`) go to it; every other type, and any diagram it throws on, goes to Pele. If beautiful-mermaid fails to load, Pele draws its diagrams too
   - `mermaid`: mermaid.js, theme `dark` or `default`. It draws one diagram at a time with `mermaid.render(id, text, container)` (`startOnLoad: false`, `suppressErrorRendering: true`) rather than `startOnLoad`/`run()`, so each diagram's failure is known and handled like Pele's. Drawing inside the container lets the page's CSS apply while it measures text

   The module captures each block's text and number (its position among the page's Mermaid blocks) before its first `await`, so starry-night's module can't get in the way. Bash prints only the URLs of the libraries the chosen renderer can load, so the page names nothing it won't fetch. beautiful-mermaid is a dynamic `import()` from esm.sh; Pele and mermaid.js are `<script>`s the module adds with their SRI hashes (allowed by `strict-dynamic`). Each loads only when a diagram needs it.
   - beautiful-mermaid output goes in `.beautiful-mermaid`, with its built-in `github-dark`/`github-light` themes, their `bg` swapped for `--mdr-diagram-bg` since its node and line colors derive from it. Its SVG `@import`s the Inter font from Google Fonts, which the CSP blocks, so the page strips that line and the system font is used
   - Pele output goes in `.pele-diagram`, through `pele.mount`, which measures text with the page font, re-lays the diagram out to fit its container's width and adds zoom controls when the diagram shows smaller than its natural size. The module keeps the `Mounted` object. Pele's defaults are light, so `--pele-*` variables on `:root` carry GitHub's colors: `--pele-bg` is the diagram background (it masks lines behind labels), and `--pele-surface` (node fill) a different shade
   - mermaid.js output goes in `.mermaid-diagram` (not `.mermaid`, which mermaid.js's own `run()` would pick up); its SVGs have ids `mdr-mermaid-<N>`
   - Each drawn diagram sits in a `.mdr-diagram` wrapper, a 16px-padded box with rounded corners on `--mdr-diagram-bg` (GitHub's code block color: `#151b23` dark, `#f6f8fa` light), with a `.mdr-diagram-tools` toolbar, which shows on hover or when a button has keyboard focus (`:has(:focus-visible)`, like the code copy button): **Copy diagram source** (`mdr.copyButton`), **Download SVG** and **Expand diagram**. Double-clicking the diagram also expands it: a capturing `dblclick` listener on the wrapper (skipping the toolbar and `.pele-zoom`) stops the event before Pele's zoom, which would otherwise zoom in place, and a `mousedown` with `detail > 1` is cancelled so the double-click doesn't select text. `--pele-zoom-top/bottom/right` move Pele's zoom controls to the bottom right, under the toolbar and lined up with it
   - A diagram that can't be drawn (Pele's `onError`, a throw from `mermaid.render`) keeps its source `<pre>` under a `.mdr-diagram-error` note, with the ordinary code copy button and no diagram buttons. If Pele or mermaid.js fails to load, its blocks stay as source with that copy button
   - **Height limit** (`--max-diagram-height`, default `80vh`): `--mdr-diagram-max-height` on `:root`, left out with `none`. After drawing, the module sets each SVG's inline `max-width` to `min(<its own max-width or 100%>, calc(var(--mdr-diagram-max-height) * W/H))`. The height is `auto`, so a taller diagram scales down with its proportions kept, and the cap follows window resizes. Pele's layout only adapts to width, but its zoom measures the SVG's rendered size, so a capped Pele diagram gets zoom controls in place. Pele's `onRender` applies the cap after every redraw; on the first render it runs before the zoom exists, and later it calls `zoom.refresh()` so the zoom sees the cap
   - **Download SVG**: clones the live SVG at its natural (viewBox) size, without the page's inline sizing or Pele's zoom leftovers (for Pele the viewBox is reset too, which undoes zoom). Every `var(--x)` the SVG uses but doesn't define (Pele's `--pele-*` colors) is written on its root from the computed style, and the root gets the wrapper's background, since all three renderers draw on transparent. It's serialized with `XMLSerializer`, not `outerHTML`, so mermaid.js's `<foreignObject>` HTML labels are well-formed XML. Saved through a blob URL and a temporary `<a download>` as `<title without .md/.markdown/…>-diagram-<N>.svg`
   - **Expand**: a `<dialog>` opened with `showModal()`, chosen over `requestFullscreen()` because Esc, focus handling and a backdrop come built in, it opens instantly inside the window instead of moving to a macOS fullscreen Space, it can scroll, and it works headless. It's appended inside `.markdown-body` for the page's font; `.markdown-body > .mdr-dialog { margin: auto !important }` undoes github-markdown-css's last-child margin. Its background is `--mdr-diagram-bg`. beautiful-mermaid and mermaid.js get a clone of the SVG; Pele gets a new `pele.mount` with `zoom: false` and `maxWidth` set to the dialog's width when it opens, so it's laid out once for that width and never re-lays out as the zoom changes; once drawn, its container shrinks to fit it. Esc, the close button or a click on the backdrop closes it
   - **Pan and zoom** in the dialog (`panZoom`): `.mdr-dialog-view` is a scroll box and the diagram a flex item with auto margins, so it's centered when it fits; when it doesn't, the view opens scrolled to its middle (a Pele redraw keeps the scroll). It opens at 100%, the diagram's natural size
     - Pan: dragging with the mouse scrolls the view (pointer capture, `cursor: grab`/`grabbing`, ended by `pointerup` or `lostpointercapture`). Presses on the scrollbars are ignored, and touch is left to native scrolling. The view is focused on open and on each drag, so the arrow keys scroll it too
     - Zoom: sets the SVG's inline width and height to its natural size times the scale, then scrolls so the point under the cursor (or the view's center) stays put. `.mdr-zoom` at the bottom right is `[ - 100% + ]`: the buttons step through `zoomSteps` (10% to 500%), and the percentage (labelled "Reset zoom (N%)") goes back to 100%; `+`/`=`, `-` and `0` do the same. The wheel zooms instead of scrolling, freely between 10% and 500%: up zooms in, each event by at most 2^0.48 (`2 ** (clamp(-deltaY, ±24) * 0.02)`, after Firefox's line and page deltas are turned into pixels). Pinching zooms too: Chrome and Firefox send it as a wheel event with `ctrlKey`, which the same rule handles (spreading is a negative `deltaY`, so flipping the wheel's direction would flip pinching unless split out); Safari sends `gesture*` events, and wheel events during a gesture are ignored so it can't zoom twice
7. MathJax (only when the body has `data-math-style=`); see Math under Key Details
8. starry-night ES module (only when a fenced code block names a language, including the front-matter YAML fallback) highlights code; languages outside its `common` bundle load on demand from a flag→scope map

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
- Internet connection only for CDN assets, which the page loads when it needs them:
  - github-markdown-css: GitHub styling
  - starry-night + hast-util-to-dom: syntax highlighting
  - MathJax: math
  - Pele: default diagram renderer, every Mermaid type (with beautiful-mermaid, the types it lacks); one file with no dependencies of its own
  - beautiful-mermaid: only with `--mermaid beautiful-mermaid`, picked for its look; only six diagram types
  - mermaid.js: only with `--mermaid mermaid`
- Tests: Google Chrome (headless) and internet

## Key Details

- Rendering is done locally — no API calls, no rate limits, no auth tokens
- CDN versions are pinned in `lib/render.sh`: github-markdown-css 5.9.0, mermaid 11.17.2, pele 1.13.0, mathjax 3.2.2 (all with SRI; the CSS uses the non-minified files because jsDelivr's auto-minified ones can't carry SRI), starry-night 3.11.0, hast-util-to-dom 4.0.1 and beautiful-mermaid 1.1.3 from esm.sh (no SRI; beautiful-mermaid's URL is at the top with the others, starry-night's in its module). Bumping a version means refreshing its hash (command in the file's header)
- CSP: `script-src 'nonce-…' 'strict-dynamic' 'wasm-unsafe-eval'` (starry-night's oniguruma needs WASM). Every script we emit must carry the nonce. `<base>` goes before the CSP meta so `base-uri 'none'` only blocks `<base>` from the markdown
- github-markdown-css 5.9.0 already styles alerts, task lists, footnotes, `kbd`, `pl-*` syntax colors and heading anchors, so the inline CSS doesn't repeat them
- Math: comrak marks math with `data-math-style`; the page wraps exactly those elements in `\(…\)` / `\[…\]` and typesets them with `MathJax.typesetPromise` (`startup.typeset: false`), so MathJax never scans for `$`. comrak's rule: `$…$` is math only when the text touches both dollar signs and the closing `$` isn't followed by a digit (`$5 and $10` stays text); `\$` is a literal dollar. Also supported: ```` ```math ```` blocks and `` $`…`$ ``
- Emoji come from comrak's `--gemoji` (standard Unicode shortcodes); GitHub's custom image emoji (`:octocat:`, `:shipit:`) stay as text
- Options are parsed anywhere (`--light/--dark`, last wins; `--mermaid NAME` or `--mermaid=NAME` with `pele` (default), `beautiful-mermaid` or `mermaid`, where an unknown name is a usage error; `--max-diagram-height H` or `--max-diagram-height=H`, last wins, with `H` one of `N`/`Npx` (a bare number means px), `Nvh` or `none`, `N > 0` and decimals allowed, default `80vh`; anything else, `%` and `0` included, or a missing value is a usage error; `-h`, `-v`, `--`); dash-leading file names are prefixed with `./` before use
- No environment variables: for a persistent `--max-diagram-height`, use a shell alias; options are parsed anywhere and the last one wins, so passing the flag again overrides it
- Exit codes: 0 all files converted; 1 any input failed (the others are still processed); 2 usage error
- Escape HTML with `mdr_escape_html` (sed), not `${var//…}`: bash 5.2 treats `&` in the replacement as the matched text
- Keep scripts bash 3.2-safe (macOS `/usr/bin/env bash`): no `${x,,}`, guard empty arrays under `set -u`
- Run `shellcheck -x mdread mdtohtml lib/render.sh tests/run` and `tests/run` after changes

## Known Limitations

- CDN assets require internet — HTML renders but is unstyled and unhighlighted without it
- Relative links to other `.md` files open the raw markdown (GitHub would render it)
- Syntax highlighting covers starry-night's `common` bundle plus the on-demand map in `lib/render.sh`; other languages render plain
- Nested YAML front matter is shown as a YAML code block rather than GitHub's nested tables
- With `--mermaid beautiful-mermaid`, one page can mix two diagram styles: beautiful-mermaid's six types look different from the ones Pele draws
- beautiful-mermaid's parser is lenient: some broken diagrams of its types (a flowchart with a stray `][` line) are drawn instead of failing, so they never reach Pele's error note
- beautiful-mermaid diagrams use the system font rather than its intended Inter, because the CSP blocks Google Fonts. Their SVG downloads do too
- Diagrams scaled down to the height limit can have small text; expand shows them at full size, with pan and zoom (Pele's zoom also works in place)
- In the expanded view the wheel only zooms: two-finger horizontal scrolling does nothing, and panning is dragging or the arrow keys. Safari's pinch (`gesture*` events) hasn't been checked in Safari itself
- mermaid.js SVG downloads keep its HTML labels in `<foreignObject>`: browsers and Quick Look draw them, but some SVG editors don't
- `tests/run` checks that the diagram buttons exist and that the height cap is applied, not copy, download, expand, double-click or pan and zoom; check those by hand in a browser. The dialog can be driven headless the same way (dispatch `dblclick`, click the zoom buttons, send `WheelEvent`s and `PointerEvent`s with `pointerId: 1`), but its `close` event doesn't fire reliably under `--virtual-time-budget` (not even on a bare page), so a dialog left open after `close()` there isn't a bug. Downloads can be checked headless in a scratch copy of a page: add a script carrying the page's nonce that wraps `window.Blob` to record the SVG text, stubs `HTMLAnchorElement.prototype.click` so nothing is saved, and clicks the Download buttons. Don't read the blobs back with `blob.text()`, which doesn't finish within `--virtual-time-budget`

## Documentation

`README.md` is for humans: keep it simple and short (what it does, install, usage, a feature list). Flags, exit codes, internals and edge cases belong in this file.
