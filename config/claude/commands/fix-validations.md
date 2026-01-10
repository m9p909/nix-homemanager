---
allowed-tools: Bash(mvn:*), Bash(grep:*), Bash(find:*), Read, Edit, Write
description: Run mvn clean install -DskipTests and fix any static analysis issues
---

# Fix Validation Issues

Run Maven clean install with static analysis (skipping tests) and fix any Checkstyle, PMD, or SpotBugs issues that are reported.

## Instructions

1. Run `mvn clean install -DskipTests` to compile and run static analysis. Don't use the `Pai` profile
2. Analyze the output for any validation failures:
   - Checkstyle violations
   - PMD violations
   - SpotBugs violations
3. For each violation found:
   - Read the relevant source file
   - Fix the issue according to the validation rule
   - Ensure the fix follows project coding standards
4. After fixing all issues, run the build again to verify all validations pass
5. Provide a summary of what was fixed

## Important Notes

- Use the `-Pai` profile for faster builds during development
- Focus on fixing actual code quality issues, not disabling checks
- Follow existing code patterns in the codebase
- Do not modify configuration files unless absolutely necessary
- Verify fixes don't break existing functionality
