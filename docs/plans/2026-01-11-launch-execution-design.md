# Launch Execution: Fresh Context Transition Design

## Problem

After brainstorming and writing an implementation plan, 50-70% of context is consumed. Users want to execute with subagent-driven development but need fresh context for optimal performance.

Current workaround requires:
1. Starting a new Claude Code session manually
2. Remembering/copying the plan path
3. Manually invoking the skill with the correct path

This friction breaks the workflow and loses context about what to do next.

## Solution

A two-command flow that preserves the plan path across `/clear`:

1. **After planning:** Claude writes a state file with the plan path
2. **User runs `/clear`:** Fresh context, SessionStart hook reminds about pending execution
3. **User runs `/launch-execution`:** Reads state file, invokes skill, deletes state file

## Components

### State File

**Location:** `docs/plans/.pending-execution.json`

**Contents:**
```json
{
  "planPath": "docs/plans/2026-01-11-feature-name-implementation.md",
  "skill": "subagent-driven-development",
  "createdAt": "2026-01-11T15:30:00Z"
}
```

**Lifecycle:**
- Created by `writing-plans` skill when user chooses Subagent-Driven
- Read by SessionStart hook (for reminder message)
- Read and deleted by `/launch-execution` command

**Gitignore:** Should be added to project's `.gitignore` (transient workflow state).

### Writing-Plans Skill Modification

**File:** `skills/writing-plans/SKILL.md`

**Change:** Replace the "If Subagent-Driven chosen" section (lines 109-113) with:

```markdown
**If Subagent-Driven chosen:**
1. Write state file to `docs/plans/.pending-execution.json`:
   ```json
   {
     "planPath": "<saved-plan-path>",
     "skill": "subagent-driven-development",
     "createdAt": "<ISO-timestamp>"
   }
   ```
2. Display handoff message:

   "Ready for fresh-context execution.

   Run these two commands:
   1. `/clear` - Reset context
   2. `/launch-execution` - Start implementation

   The plan path has been saved. After `/clear`, you'll be reminded to run `/launch-execution`."

3. Stop here (do not invoke subagent-driven-development in this session)
```

### SessionStart Hook Modification

**File:** `hooks/session-start.sh`

**Change:** After injecting the using-superpowers skill content, add:

```bash
# Check for pending execution in current directory's docs/plans/
PENDING_FILE="docs/plans/.pending-execution.json"
if [ -f "$PENDING_FILE" ]; then
    # Try jq first, fall back to grep/sed
    if command -v jq >/dev/null 2>&1; then
        PLAN_PATH=$(jq -r '.planPath' "$PENDING_FILE" 2>/dev/null)
    else
        # Fallback: extract planPath using grep/sed (handles simple JSON)
        PLAN_PATH=$(grep -o '"planPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$PENDING_FILE" | sed 's/.*"planPath"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi

    if [ -n "$PLAN_PATH" ] && [ "$PLAN_PATH" != "null" ]; then
        echo ""
        echo "<pending-execution>"
        echo "A plan is queued for execution: $PLAN_PATH"
        echo "Run /launch-execution to start implementation with fresh context."
        echo "</pending-execution>"
    fi
fi
```

**Platform support:** Uses bash with Git Bash assumed for Windows. The grep/sed fallback handles systems without jq.

### New Command: /launch-execution

**File:** `commands/launch-execution.md`

```markdown
---
description: Launch queued plan execution with fresh context
disable-model-invocation: true
---

Check for a pending execution state file at `docs/plans/.pending-execution.json`.

**If the file exists:**
1. Read the `planPath` and `skill` fields
2. Delete the state file (cleanup)
3. Invoke the skill (e.g., `superpowers:subagent-driven-development`) with the plan path as context
4. Say: "Launching execution of [planPath] using [skill]"

**If the file does not exist:**
Display this error message:

"No pending execution found.

To queue an execution:
1. Run /brainstorm or /write-plan to create an implementation plan
2. Choose 'Subagent-Driven' when prompted
3. Run /clear then /launch-execution

Or invoke directly:
/superpowers:subagent-driven-development docs/plans/<your-plan>.md"
```

## User Flow

```
1. User: /brainstorm
   └─> Design discussion, plan written to docs/plans/2026-01-11-feature.md

2. Claude: "Which execution approach?"
   └─> User chooses: Subagent-Driven

3. Claude: Writes .pending-execution.json
   └─> "Run /clear then /launch-execution"

4. User: /clear
   └─> Fresh context
   └─> SessionStart hook: "Plan queued. Run /launch-execution"

5. User: /launch-execution
   └─> Reads + deletes state file
   └─> Invokes subagent-driven-development with plan path
   └─> Execution begins with full context budget
```

## Cleanup Scenarios

| Scenario | What happens |
|----------|--------------|
| User runs `/launch-execution` | State file deleted, execution starts |
| User runs `/clear` but not `/launch-execution` | State file remains, reminder shown on next clear |
| User starts new brainstorm cycle | State file overwritten with new plan |
| User manually deletes state file | No reminder, `/launch-execution` shows helpful error |

## Files Changed

**Create:**
- `commands/launch-execution.md`

**Modify:**
- `skills/writing-plans/SKILL.md`
- `hooks/session-start.sh`

## Design Decisions

1. **Two commands instead of auto-trigger:** User stays in control; no magic behavior
2. **State file in docs/plans/:** Lives with the plans it references; in worktree for isolation
3. **Hidden file (.pending-execution.json):** Avoids cluttering the plans folder
4. **jq with grep/sed fallback:** Handles systems without jq installed
5. **Git Bash for Windows:** Avoids maintaining separate PowerShell implementation
6. **No expiration:** State file overwritten by next brainstorm cycle; keeps logic simple

## Recommended .gitignore Addition

Projects using this feature should add to their `.gitignore`:

```
# Superpowers pending execution state
docs/plans/.pending-execution.json
```
