# GitHub-Style Markdown to HTML Converter

Convert Markdown files to self-contained HTML with GitHub's light theme styling using Pandoc.

## Features

- GitHub's exact light theme CSS
- Self-contained HTML files (all resources embedded)
- Preserves filenames (`input.md` → `input.html`)
- Batch processing support
- Responsive layout with 980px max-width

## Prerequisites

- **pandoc** - Install via Homebrew:
  ```bash
  brew install pandoc
  ```

## Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd md2html
   ```

2. **Create an alias** (optional but recommended):

   Add to your shell config file (`~/.zshrc` for zsh or `~/.bashrc` for bash):
   ```bash
   alias md2html='~/dotfiles/scripts/md2html.sh'
   ```

   Then reload your shell config:
   ```bash
   source ~/.zshrc  # or source ~/.bashrc
   ```

## Usage

### With alias:
```bash
md2html document.md
md2html file1.md file2.md file3.md
md2html *.md
```

### Without alias:
```bash
./md2html.sh document.md
./md2html.sh *.md
```

## Files

- `md2html.sh` - Conversion script
- `template.html` - HTML template with GitHub layout
- `github-markdown-light.css` - GitHub's light theme CSS

## Output

Generated HTML files are:
- Self-contained (single file, no dependencies)
- Fully styled with GitHub's light theme
- Responsive and mobile-friendly
- Searchable and interactive

## Example

```bash
md2html README.md
# Creates README.html with GitHub styling
```
