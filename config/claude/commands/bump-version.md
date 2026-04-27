---
allowed-tools: Bash(mvn:*), Bash(git:*), Bash(grep:*), Read, Glob, Grep, Edit, Write
description: Bump a dependency version in the maas ecosystem following the correct procedure.
argument-hint: [package-name and/or DATAGO ticket]
---

# Bump Version

Bump a dependency version in the maas ecosystem. The user will provide a package name, vulnerability ticket, or version details in `$ARGUMENTS`.

## Dependency Diagram

All spring-boot library versions are defined in `spring-boot-starter-parent` and updated via `maas-parent`.

```
maas-parent --> spring-boot-starter-parent
maas-service-parent --> maas-parent
maas-rest-lib --> maas-parent
maas-base --> maas-parent
maas-cloud-agent-lib --> maas-parent
maas-vault-lib --> maas-parent
maas-core --> maas-service-parent
maas-core *-- maas-vault-lib
maas-core *-- maas-rest-lib
maas-core *-- maas-base
maas-core *-- maas-cloud-agent-lib
maas-base --* maas-rest-lib
maas-base --* maas-cloud-agent-lib
maas-base --* maas-vault-lib
```

## Steps

### 1. Find where the version is specified

**This is critical. Do NOT add conflicting version numbers across pom files.**

- If the package is a **spring-boot library**: the version comes from `spring-boot-starter-parent` and must be updated in **maas-parent**.
- For non-spring packages: run `mvn dependency:tree -DoutputFile=dep-tree.txt` to trace the package origin.
- Search the dep-tree output for the package to identify which repo/module owns the version.
- Check the relevant `pom.xml` `<properties>` section for the version property.

Report to the user: which repo and file owns this version, and the current version number.

### 2. Increase the version

- Edit the version property in the correct `pom.xml`.
- Only change the specific property — do not scatter version overrides into child poms.

### 3. Install and verify

- Run `mvn install -DskipTests` to verify the build compiles.
- Run `mvn dependency:tree | grep <package-name>` to confirm the package version actually changed.
- Report both results to the user.

### 4. Ask the user to run the app

Tell the user to run the application and verify there are no major problems before proceeding.

### 5. Submit PRs

Remind the user which repos need PRs (e.g. if maas-parent was changed, a PR is needed there, then downstream repos need to pick up the new parent version).
