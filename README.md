# mdread

Preview markdown files in the browser — rendered by GitHub's own API, pixel-perfect dark theme.

## Installation

No external dependencies needed (uses `curl`, `jq`/`python3`, and `open` which ship with macOS).

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

## Authentication

Set `GITHUB_TOKEN` or `GH_TOKEN` to increase API rate limits from 60/hr to 5000/hr:

```bash
export GITHUB_TOKEN="ghp_..."
```

## Supported Features

- Tables, task lists, fenced code blocks, strikethrough
- Syntax highlighting (identical to github.com)
- Alerts (`> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!CAUTION]`)
- Footnotes (`[^1]`)
- Emoji shortcodes (`:rocket:` → 🚀)
- LaTeX math (`$inline$` and `$$display$$`) via MathJax
- Mermaid diagrams (` ```mermaid `) via Mermaid.js
- Collapsible sections (`<details>` / `<summary>`)
- Copy-to-clipboard buttons on code blocks

Requires an internet connection (GitHub API for rendering + CDN for CSS/MathJax/Mermaid).
