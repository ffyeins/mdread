# Installation Guide - GitHub-Style Markdown to HTML

This guide shows how to install all necessary tools to convert Markdown files to self-contained HTML with GitHub styling.

## Prerequisites

- macOS (tested on MacBook Air)
- Homebrew installed
- Terminal access

## Installation Steps

### 1. Install Pandoc

```bash
brew install pandoc
```

Verify installation:
```bash
pandoc --version
```

### 2. Download GitHub CSS

```bash
curl -O https://raw.githubusercontent.com/sindresorhus/github-markdown-css/main/github-markdown-light.css
```

### 3. Create Template File

Create a file named `template.html` with this content:

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

## Quick Setup Script

Run this to set up everything in one go:

```bash
# Create project directory
mkdir -p ~/github-style-markdown-pdf-generator
cd ~/github-style-markdown-pdf-generator

# Download CSS
curl -O https://raw.githubusercontent.com/sindresorhus/github-markdown-css/main/github-markdown-light.css

# Create template.html
cat > template.html << 'EOF'
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
EOF

echo "✅ Setup complete!"
echo "Your files are in: $(pwd)"
```

## Usage

Once installed, convert markdown to HTML:

```bash
pandoc input.md -o output.html \
  --template=./template.html \
  --embed-resources \
  --standalone \
  --css=github-markdown-light.css \
  --metadata title="Your Document Title"
```

**What this does:**
- Creates a single self-contained HTML file
- Embeds all CSS and images
- Applies GitHub styling
- Can be opened in any browser

**View the result:**
```bash
open output.html
```

## File Structure

Your project directory should look like:

```
github-style-markdown-pdf-generator/
├── github-markdown-light.css    # GitHub styling
├── template.html                # HTML template
├── input.md                     # Your markdown file
└── output.html                  # Generated HTML
```

## Optional: Create Alias

Add to `~/.zshrc` for easier usage:

```bash
alias md2html='pandoc $1 -o ${1%.md}.html --template=./template.html --embed-resources --standalone --css=github-markdown-light.css --metadata title="${1%.md}"'
```

Reload: `source ~/.zshrc`

Then use:
```bash
md2html input.md
# Creates input.html
```
