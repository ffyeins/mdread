#!/bin/bash

# View markdown files as HTML in browser without creating permanent files
# Temp files created in /tmp/ and auto-cleaned after 3 seconds

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MD2HTML="$SCRIPT_DIR/md2html/md2html.py"

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

    # Create temporary markdown file in /tmp
    temp_base=$(mktemp /tmp/mdread.XXXXXX)
    temp_md="${temp_base}.md"
    temp_html="${temp_base}.html"
    mv "$temp_base" "$temp_md"

    # Copy markdown content to temp file
    cp "$md_file" "$temp_md"

    # Convert using md2html.py
    "$MD2HTML" "$temp_md" > /dev/null 2>&1

    if [ -f "$temp_html" ]; then
        # Open in default browser
        open "$temp_html"
        temp_files+=("$temp_md" "$temp_html")
    else
        echo "✗ Failed to convert $md_file"
        rm -f "$temp_md"
    fi
done

# Clean up all temp files in background after browser has loaded them
if [ ${#temp_files[@]} -gt 0 ]; then
    (sleep 3 && rm -f "${temp_files[@]}") &
fi
