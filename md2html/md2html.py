#!/usr/bin/env python3
"""Convert Markdown files to self-contained HTML with GitHub light theme styling."""

import subprocess
import sys
from pathlib import Path

# Theme constants
GITHUB_LIGHT = "github-markdown-light.css"
GITHUB_DARK = "github-markdown-dark.css"

# Syntax highlighting constants
SYNTAX_LIGHT = "github-syntax-highlighting-light-pandoc.css"
GITHUB_SYNTAX_DARK = "github-syntax-highlighting-dark-pandoc.css"

# Selected themes (easy to change)
SELECTED_THEME = GITHUB_DARK 
SELECTED_SYNTAX_HIGHLIGHTING_THEME = GITHUB_SYNTAX_DARK

def get_script_dir() -> Path:
    """Get the directory containing this script."""
    return Path(__file__).parent.resolve()


def read_css_file(filename: str) -> str:
    """Read a CSS file from the script's directory."""
    css_path = get_script_dir() / filename
    if not css_path.exists():
        print(f"Error: CSS file not found: {css_path}", file=sys.stderr)
        sys.exit(1)
    return css_path.read_text()


def convert_md_to_html(md_path: Path) -> None:
    """Convert a single Markdown file to HTML."""
    if not md_path.exists():
        print(f"Error: File not found: {md_path}", file=sys.stderr)
        return

    output_path = md_path.with_suffix(".html")

    # Read CSS files
    github_css = read_css_file(SELECTED_THEME)
    syntax_css = read_css_file(SELECTED_SYNTAX_HIGHLIGHTING_THEME)

    # Set background color based on theme
    bg_color = "#0d1117" if SELECTED_THEME == GITHUB_DARK else "#ffffff"

    # HTML template with embedded CSS
    html_template = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{md_path.stem}</title>
    <style>
{github_css}
{syntax_css}
    </style>
    <style>
        html, body {{
            margin: 0;
            padding: 0;
            background-color: {bg_color};
        }}
        .container {{
            box-sizing: border-box;
            min-width: 200px;
            max-width: 980px;
            margin: 0 auto;
            padding: 45px;
        }}
        @media (max-width: 767px) {{
            .container {{
                padding: 15px;
            }}
        }}
        /* Fix Pandoc task list checkbox spacing */
        .markdown-body input[type="checkbox"] {{
            margin-right: 0.35em;
        }}
    </style>
</head>
<body>
<div class="container">
    <article class="markdown-body">
$body$
    </article>
</div>
</body>
</html>"""

    # Write template to temp file
    template_path = get_script_dir() / ".template.html"
    template_path.write_text(html_template)

    try:
        # Run pandoc
        result = subprocess.run(
            [
                "pandoc",
                str(md_path),
                "-o", str(output_path),
                f"--template={template_path}",
                "--standalone",
                "--embed-resources",
            ],
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            print(f"Error converting {md_path}: {result.stderr}", file=sys.stderr)
        else:
            print(f"Created: {output_path}")

    finally:
        # Clean up template
        template_path.unlink(missing_ok=True)


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: md2html.py <file.md> [file2.md ...]", file=sys.stderr)
        sys.exit(1)

    for arg in sys.argv[1:]:
        md_path = Path(arg).resolve()
        convert_md_to_html(md_path)


if __name__ == "__main__":
    main()
