# mdread

Read markdown in your browser, styled like GitHub. Two commands:

- `mdread` opens a preview in the browser
- `mdtohtml` saves an `.html` file next to each markdown file

## Install

```bash
brew install comrak
git clone <repo-url> ~/.mdread
echo 'export PATH="$HOME/.mdread:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Keep the `lib/` folder next to the scripts.

## Usage

```bash
mdread README.md             # preview in the browser
mdread --light a.md b.md     # light theme, one tab per file

mdtohtml README.md           # writes README.html
mdtohtml --force README.md   # replace a README.html that mdtohtml didn't create
```

Dark is the default theme. `--help` lists all options.

## Supports

- Tables, task lists, footnotes, strikethrough and collapsible sections
- Code highlighting with copy buttons
- Alerts: `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`
- Math: `$…$`, `$$…$$` and ```` ```math ```` blocks
- Mermaid diagrams
- Emoji shortcodes like `:rocket:` → 🚀 (not GitHub's custom ones like `:octocat:`)
- Heading links, and images that only show in dark or light mode
- YAML front matter, shown as a table (nested values as YAML)

Markdown is converted on your machine. Styling, highlighting, math and diagrams need an internet connection. Raw HTML is allowed, but scripts inside it never run.

## Tests

Run `tests/run` (needs Google Chrome).
