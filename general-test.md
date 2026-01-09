# H1 Header

## H2 Header

### H3 Header

#### H4 Header

##### H5 Header

###### H6 Header

## Text Formatting

This is **bold text** and this is *italic text*.

You can also use __bold__ and _italic_ with underscores.

Combine them: ***bold and italic*** or **_nested_**.

Here is some `inline code` in a sentence.

~~Strikethrough text~~

## Lists

### Unordered List

- Item one
- Item two
    - Nested item
    - Another nested item
- Item three

### Ordered List

1. First item
2. Second item
    1. Nested numbered
    2. Another nested
3. Third item

### Task List

- [x] Completed task
- [ ] Incomplete task
- [ ] Another pending task

## Code

Inline code: `const x = 42;`

### Code Block with Syntax Highlighting

```javascript
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

console.log(fibonacci(10));
```

```python
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)
```

```bash
#!/bin/bash
for i in {1..5}; do
  echo "Iteration $i"
done
```

## Links and Images

[Link to GitHub](https://github.com)

[Link with title](https://github.com "GitHub Homepage")

## Blockquotes

> This is a blockquote.
> It can span multiple lines.
>
> > Nested blockquote
> > with multiple lines

## Horizontal Rules

---

***

___

## Tables

| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Row 1    | Data     | Value    |
| Row 2    | More     | Info     |
| Row 3    | Even     | More     |

| Left | Center | Right |
|:-----|:------:|------:|
| L1   | C1     | R1    |
| L2   | C2     | R2    |

## Footnotes

Here's a sentence with a footnote[^1].

[^1]: This is the footnote content.

## Definition Lists

Term 1
: Definition for term 1

Term 2
: First definition for term 2
: Second definition for term 2

## Emoji (if supported)

:rocket: :heart: :computer: :tada:
