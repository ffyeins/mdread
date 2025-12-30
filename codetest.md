# Syntax Highlighting Test

## Bash

```bash
#!/bin/bash

# Convert markdown files to HTML
for file in *.md; do
    echo "Processing $file"
    pandoc "$file" -o "${file%.md}.html"
done

if [ $? -eq 0 ]; then
    echo "Conversion successful"
fi
```

## Java

```java
public class HelloWorld {
    private static final String GREETING = "Hello, World!";

    public static void main(String[] args) {
        System.out.println(GREETING);

        // Create a list
        List<String> names = new ArrayList<>();
        names.add("Alice");
        names.add("Bob");

        for (String name : names) {
            System.out.println("Hello, " + name);
        }
    }
}
```

## JavaScript

```javascript
// Async function example
async function fetchUserData(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching user:', error);
        throw error;
    }
}

// Arrow function and array methods
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
console.log(doubled);
```

## SQL

```sql
-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email) VALUES
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com');

-- Complex query with JOIN
SELECT
    u.username,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.username
HAVING COUNT(o.id) > 5
ORDER BY total_spent DESC;
```
