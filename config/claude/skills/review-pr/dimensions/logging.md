# Logging review

For every log statement added or modified, check:
- **Correct level**: error = unacceptable failure that breaks the operation, warn = possible failure but uncertain, info = default for normal flow, debug = verbose detail usually unnecessary
- **No raw string data**: log enums, IDs, counts — not raw request bodies, user input, or serialized objects
- **Structured context**: include IDs, enums, counts as key-value pairs, not prose sentences
