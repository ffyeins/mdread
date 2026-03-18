# mdread

Preview markdown files in the browser with GitHub's dark theme.

## Installation

Requires [pandoc](https://pandoc.org/):

```bash
brew install pandoc
```

Clone the repo and add it to your PATH:

```bash
git clone <repo-url> ~/.mdread
echo 'export PATH="$HOME/.mdread:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## How to Use

```bash
# Preview a single file
mdread README.md

# Preview multiple files (opens one tab each)
mdread file1.md file2.md
```

The HTML is opened in your default browser and automatically cleaned up after a few seconds.
