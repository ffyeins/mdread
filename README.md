# mdread

Preview markdown files in the browser with GitHub's dark theme.

## Installation

Requires [pandoc](https://pandoc.org/) >= 3.9:

```bash
brew install pandoc
```

Clone the repo and add it to your PATH:

```bash
git clone <repo-url> ~/.mdread
echo 'export PATH="$HOME/.mdread:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## How to Use

```bash
# Preview a single file
mdread README.md

# Preview multiple files (opens one tab each)
mdread file1.md file2.md

mdread --help
mdread --version
```

The HTML is opened in your default browser and automatically cleaned up after a few seconds.

## Supported Features

- Tables, task lists, fenced code blocks, strikethrough
- Syntax highlighting (GitHub dark color scheme)
- Alerts (`> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!CAUTION]`)
- Footnotes (`[^1]`)
- Emoji shortcodes (`:rocket:` → 🚀)
- LaTeX math (`$inline$` and `$$display$$`) via MathJax
- Mermaid diagrams (` ```mermaid `) via Mermaid.js
- Collapsible sections (`<details>` / `<summary>`)

Math and Mermaid rendering require an internet connection (loaded from CDN).
