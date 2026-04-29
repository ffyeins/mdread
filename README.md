# mdread

Preview markdown files in the browser — GitHub-style dark theme, rendered locally.

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

mdtohtml --help
mdtohtml --version
```

## Supported Features

- Tables, task lists, fenced code blocks, strikethrough, footnotes
- Syntax highlighting (matches GitHub's colors via starry-night)
- Alerts (`> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!CAUTION]`)
- Emoji shortcodes (`:rocket:` → 🚀)
- LaTeX math (`$inline$` and `$$display$$`) via MathJax
- Mermaid diagrams (` ```mermaid `) via Mermaid.js
- Collapsible sections (`<details>` / `<summary>`)
- Copy-to-clipboard buttons on code blocks

Markdown rendering is done locally with `cmark-gfm` — no API calls, no rate limits, no auth tokens. CDN assets (CSS, syntax highlighting, MathJax, Mermaid) require an internet connection.
