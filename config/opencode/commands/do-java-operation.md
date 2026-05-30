---
description: Implement Java operations with full Maven permissions
---

# Java Operation Implementation

Implement the following Java operation: $ARGUMENTS

## Instructions

1. **Check for Maven profiles**: First, check `pom.xml` for low-validation profiles (like `-Pai`, `-DskipTests`, `-DskipValidations`) that can speed up builds during development.

2. **Understand the project structure**: Use `mvn help:effective-pom` or examine the `pom.xml` to understand:
   - Module structure
   - Build plugins
   - Dependencies
   - Available profiles

3. **Implement the operation**:
   - Read relevant source files
   - Make necessary changes
   - Follow existing code patterns and conventions
   - Add appropriate tests if needed

4. **Validate changes**:
   - If a fast profile exists (like `-Pai`), use it for quick compilation: `mvn clean compile -Pai`
   - Otherwise use: `mvn clean compile -DskipTests`
   - Fix any compilation errors

5. **Run tests**:
   - Use the fast profile if available: `mvn test -Pai`
   - Otherwise: `mvn test`

## Common Maven Profiles to Check For
- `-Pai` - AI/development profile (skips static analysis)
- `-DskipTests` - Skip test execution
- `-DskipValidations` - Skip validation checks
- `-Dcheckstyle.skip=true` - Skip checkstyle
- `-Dpmd.skip=true` - Skip PMD

Execute the operation efficiently using available Maven profiles to minimize build time.
