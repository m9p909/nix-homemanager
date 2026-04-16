# Security checklist

For every file touched by the PR, check:
- **Input validation**: all data crossing system boundaries (user input, external APIs, file uploads) is validated and sanitized
- **Secrets exposure**: no credentials, API keys, tokens, or connection strings in code or logs
- **Injection risks**: SQL injection, XSS, command injection — parameterized queries, escaped output, no shell interpolation of user input
- **Auth/authorization gaps**: endpoints enforce authentication; actions check authorization; no privilege escalation paths
