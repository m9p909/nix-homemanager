# Concurrency review

For code that touches shared resources (DB, queues, external services, caches), check:
- **Connection/resource leaks**: DB connections, HTTP clients, file handles are released in error paths (try-finally, try-with-resources, defer)
- **Lock ordering**: consistent acquisition order across the codebase to prevent deadlocks
- **Timeout configuration**: external calls and DB queries have explicit timeouts; no unbounded waits
- **Idempotency**: retryable operations (queue consumers, webhook handlers, cron jobs) are idempotent — repeated execution produces the same result
