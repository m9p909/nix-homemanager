# Test coverage review

For test files added or modified, check:
- **Edge cases and failure paths**: tests cover boundary conditions, empty inputs, nulls, error responses — not just the happy path
- **Behavior over implementation**: tests assert on observable outcomes, not internal method calls or private state
- **Reasonable coverage ratio**: new production code has proportional test coverage; flag untested public methods or branches
