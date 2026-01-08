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
1. `md2html/md2html.sh` - Conversion script (persistent HTML)
2. `mdread.sh` - Preview script (temporary HTML)
3. `md2html/github-markdown-light.css` - GitHub's official light theme CSS
4. `md2html/template.html` - HTML wrapper with proper layout

**Usage**:
```bash
# Convert to HTML file (via alias)
md2html document.md
md2html file1.md file2.md *.md

# Quick preview in browser (via alias)
mdread document.md
mdread file1.md file2.md *.md

# Direct calls
~/dotfiles/scripts/mdread/md2html/md2html.sh document.md
~/dotfiles/scripts/mdread/mdread.sh document.md
```

The `md2html.sh` script uses `SCRIPT_DIR` to locate template and CSS files in the same directory, allowing it to be called from anywhere.

## File Contents

### template.html
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$if(title)$$title$$else$Document$endif$</title>
  <style>
    body {
      margin: 0;
      padding: 0;
      background-color: #ffffff;
    }
    .container {
      max-width: 980px;
      margin: 0 auto;
      padding: 45px;
    }
    @media (max-width: 767px) {
      .container {
        padding: 15px;
      }
    }
  </style>
$if(highlighting-css)$
  <style>
$highlighting-css$
  </style>
$endif$
  $for(css)$
  <link rel="stylesheet" href="$css$">
  $endfor$
</head>
<body>
  <div class="container">
    <article class="markdown-body">
      $body$
    </article>
  </div>
</body>
</html>
```

### md2html.sh
The script uses `--syntax-highlighting=pygments` to enable Pandoc's built-in syntax highlighting. The `$highlighting-css$` variable in the template allows Pandoc to inject the necessary CSS for syntax highlighting. Supports batch processing of multiple files.

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

5. **Syntax Highlighting**: Using Pandoc's built-in highlighting with `--syntax-highlighting=pygments`:
   - Supports all major programming languages
   - CSS automatically embedded via `$highlighting-css$` template variable
   - Alternative styles available: pygments, tango, kate, monochrome, breezedark, espresso, zenburn, haddock

6. **Two-Script Approach**:
   - **md2html**: For creating persistent HTML files to share or archive
   - **mdread**: For quick read-only viewing without risk of accidental edits or file clutter
   - Temporary files cleaned up automatically (3-second delay for browser loading)

## Dependencies

### Required
- **pandoc**: Universal document converter (Homebrew)
- **github-markdown-light.css**: GitHub's light theme CSS

## Directory Structure
```
~/dotfiles/scripts/mdread/
├── md2html/
│   ├── md2html.sh               # Conversion script (persistent HTML)
│   ├── github-markdown-light.css # GitHub light theme CSS
│   └── template.html            # HTML template with layout
├── mdread.sh                    # Preview script (temporary HTML)
└── README.md                    # Documentation
```

The `md2html.sh` script can be called from any directory - it locates the template and CSS files relative to its own location.

## Installation Paths (macOS)

- **Script location**: `~/dotfiles/scripts/mdread/`
- **Pandoc**: Installed via Homebrew at `/opt/homebrew/bin/pandoc`
- **Aliases**: Add to `~/.zshrc`:
  ```bash
  alias md2html='~/dotfiles/scripts/mdread/md2html/md2html.sh'
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

