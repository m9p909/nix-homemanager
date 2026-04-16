# Naming and structure review

For all added or modified code, check:
- **Naming**: descriptive function/variable names; no vague "Service"/"Manager" unless justified; names reveal intent
- **Function size**: one responsibility per function, few arguments, no side effects when possible; flag functions with more than 9 branches
- **No duplication**: DRY — prefer reusing existing utilities over adding parallel implementations; flag copy-pasted logic
- **No dead code**: no commented-out code, unused imports, or leftover TODOs without tracking tickets
