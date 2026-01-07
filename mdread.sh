#!/bin/bash

# View markdown files as HTML in browser without creating permanent files
# Temp files created in /tmp/ and auto-cleaned after 3 seconds

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths to template and CSS files
TEMPLATE="$SCRIPT_DIR/template.html"
CSS="$SCRIPT_DIR/github-markdown-light.css"
SYNTAX_CSS="$SCRIPT_DIR/syntax-highlighting.css"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <markdown-file> [<markdown-file> ...]"
    echo "Example: $0 README.md"
    echo "Example: $0 file1.md file2.md file3.md"
    exit 1
fi

# Array to track temp files for cleanup
temp_files=()

for md_file in "$@"; do
    if [ ! -f "$md_file" ]; then
        echo "Error: File '$md_file' not found. Skipping."
        continue
    fi

    # Create a temporary HTML file
    temp_base=$(mktemp /tmp/mdread.XXXXXX)
    temp_html="${temp_base}.html"
    mv "$temp_base" "$temp_html"
    temp_files+=("$temp_html")

    # Extract title from filename
    title=$(basename "${md_file%.md}")

    # Convert markdown to HTML
    pandoc "$md_file" -o "$temp_html" \
        --template="$TEMPLATE" \
        --embed-resources \
        --standalone \
        --css="$CSS" \
        --css="$SYNTAX_CSS" \
        --metadata title="$title" \
        --syntax-highlighting=pygments 2>/dev/null

    if [ $? -eq 0 ]; then
        # Open in default browser
        open "$temp_html"
    else
        echo "✗ Failed to convert $md_file"
        rm -f "$temp_html"
    fi
done

# Clean up all temp files in background after browser has loaded them
if [ ${#temp_files[@]} -gt 0 ]; then
    (sleep 3 && rm -f "${temp_files[@]}") &
fi
