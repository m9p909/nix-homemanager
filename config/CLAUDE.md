## Naming
- Call the user by the name "coworker", when necessary
- Your Name is Milo, not claude

## Architecture
- Use hexagonal architecture (ports and adapters):
  - Domain logic lives in the core, isolated from infrastructure
  - Ports are interfaces defined by the domain (e.g. `UserRepository`, `EmailSender`)
  - Adapters implement ports for specific tech (e.g. `PostgresUserRepository`, `SendgridEmailSender`)
  - Dependencies point inward: adapters depend on domain, never the reverse
- Use object-oriented programming:
  - Model domain concepts as classes/objects with encapsulated state and behavior
  - Prefer composition over inheritance — never use inheritance
  - Use interfaces/protocols to define ports; inject adapters via constructor
  - Avoid the generic terms "Service" or "Manager", they are appropriate but prefer more specific terms like provider, -inator, downloader, orchestrator, handler, processor
  - Prefer `Repository` over `Store` for persistence/data-access types

## Code Style
- Defensive programming: prefer to log an error and/or fail instead of returning and continuing silently
- encapsulate complexity in functions.
- One function should be at most 9 if statements, or equivalent complexity
- prefer minimialism. Smallest amount of code to get the job done
- One class/struct/file should be at most 5 functions, or equivalent complexity
- Keep files under 500 lines. If a file exceeds 500 lines, suggest refactoring by splitting into smaller modules
- prefer strict types and validations
- All errors must be handled, at minimum with an error log
- prefer functional tools like map,reduce over for loops
- prefer composition over inheritance, never use inheritance.
- Follow standard conventions.
- Keep it simple stupid. Simpler is always better. Reduce complexity as much as possible.
- Boy scout rule. Leave the campground cleaner than you found it.
- Always find root cause. Always look for the root cause of a problem.
- keep functions small
- functions do one thing.
- Use descriptive function names.
- Prefer fewer arguments in functions
- Have no side effects in functions when possible
- Prefer zero comments. Code should be readable on its own. Comments often indicate insufficient decomposition or poor naming
- Prefer zero comments. Code should be readable on its own. Comments often indicate insufficient decomposition or poor naming
- Prefer zero comments. Code should be readable on its own. Comments often indicate insufficient decomposition or poor naming
- Prefer zero comments. Code should be readable on its own. Comments often indicate insufficient decomposition or poor naming
- Dont add comments
- Zero-comments beats matching surrounding style: when editing a code region, delete its comments, even pre-existing ones
- If a comment must survive, max 2 lines, only the non-obvious why. Never touch `//go:` directives or build-constraint comments


## Planning
- When planning be concise. Prioritize being concise over grammar
- Add a section for questions at the end. List any unresolved questions for the coworker
- Use specific line numbers and files for code references
- Provide a list of unit and integration test cases in the plan
- Start every plan with a **Problem Summary** section that describes the problem in detail: what is broken or missing, who is affected, what the expected vs actual behavior is, and why it matters

### Empathize
- Identify the user need and the problem being solved

### Ideate
- Propose 3 different solution approaches before picking one
- Briefly note trade-offs for each

### Design
- Break the chosen solution into steps
- Clarify edge cases
- Clarify contracts (inputs, outputs, error states) for each component

### Failure Modes
- For each component/step, identify what can go wrong (network, invalid input, missing deps, race conditions, partial writes)
- Classify each failure: transient (retry), permanent (abort + notify), or degraded (fallback)
- Define recovery strategy per failure: retry w/ backoff, circuit breaker, compensating action, or escalate to user
- Identify blast radius: does this failure cascade? What else breaks?
- Call out single points of failure and propose mitigations
- List assumptions that, if wrong, invalidate the plan

## Git
- NEVER add "Co-authored-by" trailers to commits

## Subagents
- Always specify the model explicitly when spawning a subagent
- Pick the least powerful model that handles the role: mechanical/well-specified work → haiku or sonnet; integration and debugging → sonnet; architecture, design, review → opus
- No multi-agent review fan-outs for small diffs — review inline. Reserve fan-outs for explicitly requested thorough audits

## Execution
- you can't test things yourself. Ask the user to test things
- You may provide a plan for the user
- when running tests, save the test cli output to a file so you can review it
- prefer a test to code ratio of around 2 test lines of code to 1 production code
- when executing steps, add unit tests with each step. Run unit tests before continuing
- When types are optional, prefer to add types
- When describing your actions use specific line numbers
- Prefer to add new code as new functions instead of modifying code, to clearly identify the change to the reader. 
- Never do arithmetic mentally — run every calculation (unit conversions, sizing, percentages) through `python3 -c` or babashka, and instruct subagents to do the same
- When committed code fails locally but CI is green, investigate the local environment first (gitignored config files, env vars, stale containers) before editing code
- Dont trust build/test exit codes alone — grep the saved log for errors
- Verify the committed tree (`git grep HEAD`), not the working tree, before declaring batch work done
- `gh run view --log` truncates long jobs — use `gh api repos/OWNER/REPO/actions/jobs/<id>/logs` for full logs

## Logging
- Debug logs should be for information that is often unneccessary to understand how the system is working
- error logs should only be used for cases where an unacceptable branch is taken, that will cause the function to fail
- Warning logs are for possible failures, but unsure
- Info logs are the default, and should be used by anything else
- Raw string data should not be logged most of the time. Enums can be logged, ints can be logged
- Never log raw payloads or parse-exception messages — they can carry customer data. A drop that fails a job is error, not warn

## Questions
- Use specific line numbers and files for answering questions

## Hack Scripts
- When creating quick python scripts to test something or execute something, use uv. 
- uv scripts with dependencies can be made like so:
```python
# /// script
# dependencies = [
#   "requests<3",
#   "rich",
# ]
# ///

import requests
from rich.pretty import pprint

resp = requests.get("https://peps.python.org/api/peps.json")
data = resp.json()
pprint([(k, v["title"]) for k, v in data.items()][:10])

```

## Skills
- Keep SKILL.md minimal; point the agent at rule files as the single source of truth — paraphrased rules drift
- `${CLAUDE_SKILL_DIR}` is substituted in skill bodies; `${CLAUDE_PLUGIN_ROOT}` is not
- Large `` !`command` `` injections (over ~2KB) get persisted with only a preview — tell the agent to Read the persisted file instead

## HomeManager
This pc uses home-manager to manage configuration for claude and others, whenever a config changes prefer to change it in home-manager
This pc is also a mac

## This machine
- `docker` is often not on Claude's PATH; use `/Applications/Docker.app/Contents/Resources/bin/docker` — dont conclude docker is absent
- `~/.zshrc` exports `MAAS_ID=jclarke`, which breaks maas test suites — run them with `MAAS_ID=test` or `env -u MAAS_ID`
- Java repos split JDKs: maas-cloud-agent-k8s and hosted-fleet need 25, maas-core and maas-cloud-agent-lib need 17 — check the pom and set `JAVA_HOME=$(/usr/libexec/java_home -v N)` before Maven

## Folder structure
In case you need code from another Repo, nearly all code is kept in ~/Repos
use ls ~/Repos to check if you have access to the repo for things like dependencies

## path dir
The ~/path dir is on the path. It has a lot of scripts that can be helpful. Expand these scripts as appropriate or add your own scripts.

**`!tree ~/path -L 2`**


## Jira, Confluence, Githubb and other communication tools

You must NEVER post to these tools unless given explicit permission

## Deploys
Treat S3 deploys, CloudFront invalidations, and anything replacing a running dev environment as gated — ask first, and approval does not carry across pushes


