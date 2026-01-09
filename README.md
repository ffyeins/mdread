# GitHub-Style Markdown to HTML Converter

Convert Markdown files to self-contained HTML with GitHub theme styling using Pandoc.

## Features

- GitHub's exact theme CSS (light and dark themes available)
- Syntax highlighting for code blocks
- Self-contained HTML files (all resources embedded)
- Two modes:
  - **md2html**: Create persistent HTML files (batch processing supported)
  - **mdread**: Quick browser preview with no leftovers
- Easy theme switching via constants at top of script
- Preserves filenames (`input.md` → `input.html`)
- Responsive layout with 980px max-width

## Prerequisites

- **pandoc** - Install via Homebrew:
  ```bash
  brew install pandoc
  ```

## Installation

1. **Ensure files are in your dotfiles directory**:
   ```bash
   ~/dotfiles/scripts/mdread/
   ├── md2html/
   │   ├── md2html.py
   │   ├── github-markdown-light.css
   │   ├── github-markdown-dark.css
   │   ├── github-syntax-highlighting-light-pandoc.css
   │   └── github-syntax-highlighting-dark-pandoc.css
   └── mdread.sh
   ```

2. **Make the scripts executable**:
   ```bash
   chmod +x ~/dotfiles/scripts/mdread/md2html/md2html.py
   chmod +x ~/dotfiles/scripts/mdread/mdread.sh
   ```

3. **Create aliases** (recommended):

   Add to your `~/.zshrc`:
   ```bash
   alias md2html='~/dotfiles/scripts/mdread/md2html/md2html.py'
   alias mdread='~/dotfiles/scripts/mdread/mdread.sh'
   ```

   Then reload your shell config:
   ```bash
   source ~/.zshrc
   ```

## Usage

The scripts can be called from any directory - they automatically locate template and CSS files.

### Convert to HTML file (md2html)

Creates persistent HTML files from markdown:

**With alias:**
```bash
md2html document.md
md2html file1.md file2.md file3.md
md2html *.md
```

**Without alias:**
```bash
~/dotfiles/scripts/mdread/md2html/md2html.py document.md
~/dotfiles/scripts/mdread/md2html/md2html.py *.md
```

### Quick preview in browser (mdread)

Opens markdown as HTML in browser without creating permanent files:

**With alias:**
```bash
mdread document.md
mdread file1.md file2.md file3.md
mdread *.md
```

**Without alias:**
```bash
~/dotfiles/scripts/mdread/mdread.sh document.md
~/dotfiles/scripts/mdread/mdread.sh *.md
```

Temp HTML files are created in `/tmp/` and automatically cleaned up after 3 seconds. No files are left behind.

## Files

- `md2html/md2html.py` - Python conversion script (creates persistent HTML files)
- `mdread.sh` - Preview script (temporary HTML, opens in browser)
- `md2html/github-markdown-light.css` - GitHub's light theme CSS
- `md2html/github-markdown-dark.css` - GitHub's dark theme CSS
- `md2html/github-syntax-highlighting-light-pandoc.css` - Light theme syntax highlighting
- `md2html/github-syntax-highlighting-dark-pandoc.css` - Dark theme syntax highlighting

## Theme Selection

To switch between light and dark themes, edit `md2html.py` and change the constants at the top:

```python
# Selected themes (easy to change)
SELECTED_THEME = GITHUB_DARK  # or GITHUB_LIGHT
SELECTED_SYNTAX_HIGHLIGHTING_THEME = GITHUB_SYNTAX_DARK  # or SYNTAX_LIGHT
```

The background color automatically adjusts to match the selected theme.

## Output

Generated HTML files are:
- Self-contained (single file, no dependencies)
- Fully styled with GitHub theme (light or dark)
- Code blocks with syntax highlighting
- Responsive and mobile-friendly
- Searchable and interactive

## Example

```bash
md2html README.md
# Creates README.html with GitHub styling
```
