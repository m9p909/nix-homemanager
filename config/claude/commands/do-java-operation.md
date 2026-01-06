---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(mvn:*), Bash(git:*), Bash(find:*), Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(timeout 300 mvn:*)
description: Generic command to implement Java operations with full Maven permissions
argument-hint: [description of operation to implement]
---

# Java Operation Implementation

Implement the following Java operation: {{arg}}

## Instructions

1. **Check for Maven profiles**: First, check `pom.xml` for low-validation profiles (like `-Pai`, `-DskipTests`, `-DskipValidations`) that can speed up builds during development.

2. **Understand the project structure**: Use `mvn help:effective-pom` or examine the `pom.xml` to understand:
   - Module structure
   - Build plugins
   - Dependencies
   - Available profiles

3. **Implement the operation**:
   - Read relevant source files
   - Make necessary changes using Edit or Write tools
   - Follow existing code patterns and conventions
   - Add appropriate tests if needed

4. **Validate changes**:
   - If a fast profile exists (like `-Pai`), use it for quick compilation: `mvn clean compile -Pai`
   - Otherwise use: `mvn clean compile -DskipTests`
   - Fix any compilation errors

5. **Run tests**:
   - Use the fast profile if available: `mvn test -Pai`
   - Otherwise: `mvn test`
   - Run tests automatically without asking for confirmation

## Common Maven Profiles to Check For
- `-Pai` - AI/development profile (skips static analysis)
- `-DskipTests` - Skip test execution
- `-DskipValidations` - Skip validation checks
- `-Dcheckstyle.skip=true` - Skip checkstyle
- `-Dpmd.skip=true` - Skip PMD

## Available Tools
- Read/Write/Edit for file operations
- Glob/Grep for searching code
- Maven commands for building/testing
- Git commands for version control

Execute the operation efficiently using available Maven profiles to minimize build time.
