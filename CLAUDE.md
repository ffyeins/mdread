# GitHub-Style Markdown to HTML Converter - Project Context

## Project Overview
This project converts Markdown files to self-contained HTML with GitHub's exact light theme styling using Pandoc. HTML is preferred over PDF for better interactivity, searchability, and portability.

## What We Built

### Markdown to HTML Pipeline
Created two command-line scripts for working with markdown and HTML:

1. **md2html**: Converts markdown to persistent HTML files with GitHub styling
2. **mdread**: Quick preview of markdown in browser (temporary files, no leftovers)

Both scripts automatically find their resources and can be called from any directory.

**Installation Location**: `~/dotfiles/scripts/mdread/`

**Files Required**:
1. `md2html/md2html.py` - Conversion script (persistent HTML)
2. `mdread.sh` - Preview script (temporary HTML)
3. `md2html/github-markdown-light.css` - GitHub's official light theme CSS
4. `md2html/syntax-highlighting.css` - Syntax highlighting CSS

**Usage**:
```bash
# Convert to HTML file (via alias)
md2html document.md
md2html file1.md file2.md *.md

# Quick preview in browser (via alias)
mdread document.md
mdread file1.md file2.md *.md

# Direct calls
~/dotfiles/scripts/mdread/md2html/md2html.py document.md
~/dotfiles/scripts/mdread/mdread.sh document.md
```

The `md2html.py` script locates CSS files relative to its own location, allowing it to be called from any directory.

## File Contents

### md2html.py
Python-based conversion script that:
- Embeds HTML template directly in the code (no separate template file needed)
- Reads CSS files from its own directory using `Path(__file__).parent`
- Creates a temporary `.template.html` file during conversion and cleans it up afterward
- Supports batch processing of multiple files
- Uses Pandoc with `--standalone` and `--embed-resources` flags
- Embeds both GitHub styling and syntax highlighting CSS

### mdread.sh
Preview script that creates temporary HTML files for quick viewing in browser:
- Uses `mktemp` to create temp files in `/tmp/` (e.g., `/tmp/mdread.abc123.html`)
- Supports multiple files (opens each in a new browser tab)
- Opens HTML in default browser using `open` command
- Cleans up all temp files after 3 seconds (background process)
- No persistent files or leftovers
- Useful for read-only viewing without accidental edits

## Key Design Decisions

1. **HTML over PDF**: Chose HTML for distribution because:
   - Better interactivity (clickable links always work)
   - Searchable with Ctrl+F
   - Easy code copying without formatting issues
   - Smaller file sizes
   - No pagination/page breaks
   - Works on any device with a browser

2. **Self-contained HTML**: Using `--embed-resources --standalone`:
   - Single file with all CSS and images embedded
   - No external dependencies
   - Easy to share via email or cloud storage

3. **Layout**: GitHub's 980px max-width centered layout with responsive padding

4. **CSS Source**: Using official `github-markdown-light.css` from sindresorhus/github-markdown-css

5. **Syntax Highlighting**: Using separate `syntax-highlighting.css` file:
   - Embedded directly in HTML template
   - Supports all major programming languages
   - Consistent styling across all converted documents

6. **Two-Script Approach**:
   - **md2html**: For creating persistent HTML files to share or archive
   - **mdread**: For quick read-only viewing without risk of accidental edits or file clutter
   - Temporary files cleaned up automatically (3-second delay for browser loading)

## Dependencies

### Required
- **Python 3**: Script runtime (built-in on macOS)
- **pandoc**: Universal document converter (Homebrew)
- **github-markdown-light.css**: GitHub's light theme CSS
- **syntax-highlighting.css**: Code syntax highlighting CSS

## Directory Structure
```
~/dotfiles/scripts/mdread/
├── md2html/
│   ├── md2html.py                # Python conversion script (persistent HTML)
│   ├── github-markdown-light.css # GitHub light theme CSS
│   └── syntax-highlighting.css   # Syntax highlighting CSS
├── mdread.sh                     # Preview script (temporary HTML)
└── README.md                     # Documentation
```

The `md2html.py` script can be called from any directory - it locates the CSS files relative to its own location.

## Installation Paths (macOS)

- **Script location**: `~/dotfiles/scripts/mdread/`
- **Python 3**: Built-in on macOS
- **Pandoc**: Installed via Homebrew at `/opt/homebrew/bin/pandoc`
- **Aliases**: Add to `~/.zshrc`:
  ```bash
  alias md2html='~/dotfiles/scripts/mdread/md2html/md2html.py'
  alias mdread='~/dotfiles/scripts/mdread/mdread.sh'
  ```

## User Preferences

- macOS user (MacBook Air)
- Prefers command-line tools
- Senior developer, values concise technical explanations
- Uses dotfiles structure for scripts

## Resources

- GitHub Markdown CSS: https://github.com/sindresorhus/github-markdown-css
- Pandoc Manual: https://pandoc.org/MANUAL.html
- WeasyPrint Docs: https://doc.courtbouillon.org/weasyprint/

