# mdread

Preview markdown files in the browser — GitHub-style theme (dark default, light via `--light`), rendered locally.

## Installation

Install the rendering dependency:

```bash
brew install cmark-gfm
```

Clone the repo and add it to your PATH:

```bash
git clone <repo-url> ~/.mdread
echo 'export PATH="$HOME/.mdread:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Tools

### mdread

Preview markdown in the browser. The HTML is opened in your default browser and automatically cleaned up after a few seconds.

```bash
# Preview a single file
mdread README.md

# Preview multiple files (opens one tab each)
mdread file1.md file2.md

# Render with the light theme instead of the default dark
mdread --light README.md

mdread --help
mdread --version
```

### mdtohtml

Convert markdown files to standalone HTML files. Each input file produces a `.html` file in the same directory.

```bash
# Convert a single file (creates README.html)
mdtohtml README.md

# Convert multiple files
mdtohtml file1.md file2.md

# Convert all markdown files in a directory
mdtohtml *.md

# Render with the light theme instead of the default dark
mdtohtml --light README.md

mdtohtml --help
mdtohtml --version
```

## Supported Features

- Tables, task lists, fenced code blocks, strikethrough, footnotes
- GitHub light and dark themes (`--light` / `--dark`, default dark) — page styling, syntax highlighting, alerts, kbd, copy buttons, and Mermaid diagrams all switch together
- Syntax highlighting (matches GitHub's colors via starry-night)
- Alerts (`> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!CAUTION]`)
- Emoji shortcodes (`:rocket:` → 🚀)
- LaTeX math (`$inline$` and `$$display$$`) via MathJax
- Mermaid diagrams (` ```mermaid `) via Mermaid.js
- Collapsible sections (`<details>` / `<summary>`)
- Copy-to-clipboard buttons on code blocks

Markdown rendering is done locally with `cmark-gfm` — no API calls, no rate limits, no auth tokens. CDN assets (CSS, syntax highlighting, MathJax, Mermaid) require an internet connection.
