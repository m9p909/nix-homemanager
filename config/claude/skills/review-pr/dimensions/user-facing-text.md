# User-facing text review

Review all text that end users, API consumers, or operators will read. This includes UI labels, toast messages, error messages, API response messages, log messages, and CLI output.

For each user-facing string, check:
- **Active voice**: "The server rejected the request" not "The request was rejected"
- **Specific verbs**: "retrieve," "create," "delete" — not vague "get," "do," "handle"
- **No ambiguous pronouns**: replace "it," "this," "that" with the specific noun
- **One idea per sentence**: split compound sentences joined by "and"
- **No filler**: remove "really," "very," "basically," "actually," "in order to," "at this point in time"
- **Actionable errors**: tell the user what went wrong AND what to do next. Example: "The datacenter 'us-central1-a' does not support 'enterprise-giga' class. Select a different datacenter or service class."
- **Consistent terminology**: if the codebase calls it a "workspace," never switch to "project" in a message
- **Appropriate audience**: avoid jargon in end-user messages; use precise terms in developer-facing API errors
- **Log messages**: follow the project's log level conventions (debug/info/warn/error). Avoid logging raw string data. Include structured context (IDs, enums, counts) not prose
