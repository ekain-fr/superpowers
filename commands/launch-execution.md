---
description: Launch queued plan execution with fresh context
disable-model-invocation: true
---

Check for a pending execution state file at `docs/plans/.pending-execution.json` in the current working directory.

**If the file exists:**
1. Read the file and extract `projectRoot`, `planPath`, and `skill` fields
2. Construct the absolute plan path: `<projectRoot>/<planPath>`
3. Delete the state file (cleanup before proceeding)
4. Announce: "Launching execution of [absolute-plan-path] using [skill]"
5. Invoke the skill specified in the `skill` field (e.g., `superpowers:subagent-driven-development`) with the absolute plan path

**Example state file content:**
```json
{
  "projectRoot": "/Users/example/my-project",
  "planPath": "docs/plans/2026-01-11-feature-implementation.md",
  "skill": "subagent-driven-development",
  "createdAt": "2026-01-11T15:30:00Z"
}
```

**If the file does not exist:**
Display this error message:

"No pending execution found.

To queue an execution:
1. Run `/brainstorm` or `/write-plan` to create an implementation plan
2. Choose 'Subagent-Driven' when prompted for execution approach
3. Run `/clear` then `/launch-execution`

Or invoke directly:
`/superpowers:subagent-driven-development docs/plans/<your-plan>.md`"
