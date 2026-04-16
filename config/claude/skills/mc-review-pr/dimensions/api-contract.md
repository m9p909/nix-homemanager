# API contract review

For any added or modified API endpoints (REST, gRPC, GraphQL), check:
- **REST conventions**: resources are nouns, correct HTTP methods (GET reads, POST creates, PUT replaces, PATCH updates, DELETE removes), proper status codes (201 for creation, 404 for missing, 409 for conflict)
- **Backward compatibility**: new fields are additive only; removed or renamed fields break existing clients — flag as critical
- **Error response format**: consistent structure across endpoints, actionable messages, appropriate detail level (no stack traces in production responses)
- **Pagination/filtering**: large result sets use pagination; no unbounded queries that return all rows
