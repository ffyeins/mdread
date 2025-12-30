# GitHub-Style Markdown to HTML Converter - Project Context

## Project Overview
This project converts Markdown files to self-contained HTML with GitHub's exact light theme styling using Pandoc. HTML is preferred over PDF for better interactivity, searchability, and portability.

## What We Built

### Markdown to HTML Pipeline
Created a command-line workflow to generate self-contained HTML files with GitHub styling:

**Files Required**:
1. `github-markdown-light.css` - GitHub's official light theme CSS
2. `template.html` - HTML wrapper with proper layout
3. Your markdown file (e.g., `input.md`)

**Command**:
```bash
pandoc input.md -o output.html \
  --template=./template.html \
  --embed-resources \
  --standalone \
  --css=github-markdown-light.css \
  --metadata title="Your Document Title"
```

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
project/
├── github-markdown-light.css   # GitHub light theme CSS
├── template.html           # HTML template with layout
├── input.md                     # Your markdown file
└── output.html                  # Generated HTML file
```

## Installation Paths (macOS)

- Pandoc: Installed via Homebrew at `/opt/homebrew/bin/pandoc`
- CSS file: Downloaded from npm or GitHub to project directory

## User Preferences

- macOS user (MacBook Air)
- Prefers command-line tools
- Senior developer, values concise technical explanations
- Working directory: `~/dev/github-style-markdown-pdf-generator/`

## Resources

- GitHub Markdown CSS: https://github.com/sindresorhus/github-markdown-css
- Pandoc Manual: https://pandoc.org/MANUAL.html
- WeasyPrint Docs: https://doc.courtbouillon.org/weasyprint/

