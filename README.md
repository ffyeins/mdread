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

## Installation

1. **Ensure files are in your dotfiles directory**:
   ```bash
   ~/dotfiles/scripts/md2html/
   ├── md2html.sh
   ├── template.html
   └── github-markdown-light.css
   ```

2. **Make the script executable**:
   ```bash
   chmod +x ~/dotfiles/scripts/md2html/md2html.sh
   ```

3. **Create an alias** (recommended):

   Add to your `~/.zshrc`:
   ```bash
   alias md2html='~/dotfiles/scripts/md2html/md2html.sh'
   ```

   Then reload your shell config:
   ```bash
   source ~/.zshrc
   ```

## Usage

The script can be called from any directory - it automatically locates its template and CSS files.

### With alias:
```bash
md2html document.md
md2html file1.md file2.md file3.md
md2html *.md
```

### Without alias:
```bash
~/dotfiles/scripts/md2html/md2html.sh document.md
~/dotfiles/scripts/md2html/md2html.sh *.md
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
