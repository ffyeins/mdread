# GitHub-Style Markdown to HTML Converter - Project Context

## Project Overview
This project converts Markdown files to self-contained HTML with GitHub's exact light theme styling using Pandoc. HTML is preferred over PDF for better interactivity, searchability, and portability.

## What We Built

### Markdown to HTML Pipeline
Created a command-line script to generate self-contained HTML files with GitHub styling. The script automatically finds its resources and can be called from anywhere.

**Installation Location**: `~/dotfiles/scripts/md2html/`

**Files Required**:
1. `md2html.sh` - Conversion script
2. `github-markdown-light.css` - GitHub's official light theme CSS
3. `template.html` - HTML wrapper with proper layout

**Usage**:
```bash
# Via alias (recommended)
md2html document.md
md2html file1.md file2.md *.md

# Direct call
~/dotfiles/scripts/md2html/md2html.sh document.md
```

The script uses `SCRIPT_DIR` to locate template and CSS files, allowing it to be called from any directory.

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

## Dependencies

### Required
- **pandoc**: Universal document converter (Homebrew)
- **github-markdown-light.css**: GitHub's light theme CSS

## Directory Structure
```
~/dotfiles/scripts/md2html/
├── md2html.sh                   # Conversion script
├── github-markdown-light.css    # GitHub light theme CSS
├── template.html                # HTML template with layout
└── README.md                    # Documentation
```

The script can be called from any directory - it will locate the template and CSS files relative to its own location.

## Installation Paths (macOS)

- **Script location**: `~/dotfiles/scripts/md2html/`
- **Pandoc**: Installed via Homebrew at `/opt/homebrew/bin/pandoc`
- **Alias**: Add to `~/.zshrc`: `alias md2html='~/dotfiles/scripts/md2html/md2html.sh'`

## User Preferences

- macOS user (MacBook Air)
- Prefers command-line tools
- Senior developer, values concise technical explanations
- Uses dotfiles structure for scripts

## Resources

- GitHub Markdown CSS: https://github.com/sindresorhus/github-markdown-css
- Pandoc Manual: https://pandoc.org/MANUAL.html
- WeasyPrint Docs: https://doc.courtbouillon.org/weasyprint/

