#!/bin/bash

# Convert markdown files to HTML using GitHub styling

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths to template and CSS files
TEMPLATE="$SCRIPT_DIR/template.html"
CSS="$SCRIPT_DIR/github-markdown-light.css"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown-file> [<markdown-file> ...]"
    echo "Example: $0 file1.md file2.md file3.md"
    exit 1
fi

for md_file in "$@"; do
    if [ ! -f "$md_file" ]; then
        echo "Error: File '$md_file' not found. Skipping."
        continue
    fi

    # Get filename without extension and create output filename
    base_name="${md_file%.md}"
    html_file="${base_name}.html"

    # Extract title from filename (optional, falls back to "Document")
    title=$(basename "$base_name")

    echo "Converting $md_file → $html_file"

    pandoc "$md_file" -o "$html_file" \
        --template="$TEMPLATE" \
        --embed-resources \
        --standalone \
        --css="$CSS" \
        --metadata title="$title"

    if [ $? -eq 0 ]; then
        echo "✓ Successfully created $html_file"
    else
        echo "✗ Failed to convert $md_file"
    fi
done
