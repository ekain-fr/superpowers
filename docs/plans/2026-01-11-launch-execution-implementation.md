# Launch Execution Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Enable fresh-context execution by preserving plan path across `/clear` via state file and `/launch-subagents-execution` command.

**Architecture:** State file in `docs/plans/.pending-execution.json` written by writing-plans skill, detected by SessionStart hook (which shows reminder), consumed and deleted by `/launch-subagents-execution` command.

**Tech Stack:** Bash (hooks), Markdown (commands/skills), JSON (state file)

---

## Task 1: Create /launch-subagents-execution Command

**Files:**
- Create: `commands/launch-subagents-execution.md`

**Step 1: Create the command file**

Create `commands/launch-subagents-execution.md` with this exact content:

```markdown
---
description: Launch queued plan execution with fresh context
disable-model-invocation: true
---

Check for a pending execution state file at `docs/plans/.pending-execution.json` in the current working directory.

**If the file exists:**
1. Read the file and extract the `planPath` and `skill` fields
2. Delete the state file (cleanup before proceeding)
3. Announce: "Launching execution of [planPath] using [skill]"
4. Invoke the skill specified in the `skill` field (e.g., `superpowers:subagent-driven-development`) with the plan path

**Example state file content:**
```json
{
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
3. Run `/clear` then `/launch-subagents-execution`

Or invoke directly:
`/superpowers:subagent-driven-development docs/plans/<your-plan>.md`"
```

**Step 2: Verify file created correctly**

Run:
```bash
cat commands/launch-subagents-execution.md
```

Expected: File contents match above with YAML frontmatter and instruction body.

**Step 3: Commit**

```bash
git add commands/launch-subagents-execution.md
git commit -m "feat: add /launch-subagents-execution command for fresh-context execution"
```

---

## Task 2: Modify SessionStart Hook to Detect Pending Execution

**Files:**
- Modify: `hooks/session-start.sh:17-47`

**Step 1: Add pending execution detection after line 15**

After the legacy skills warning block (line 15: `fi`), add this new block:

```bash

# Check for pending execution state file
pending_execution_message=""
pending_file="docs/plans/.pending-execution.json"
if [ -f "$pending_file" ]; then
    # Try jq first, fall back to grep/sed
    if command -v jq >/dev/null 2>&1; then
        plan_path=$(jq -r '.planPath' "$pending_file" 2>/dev/null)
    else
        # Fallback: extract planPath using grep/sed
        plan_path=$(grep -o '"planPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$pending_file" | sed 's/.*"planPath"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi

    if [ -n "$plan_path" ] && [ "$plan_path" != "null" ]; then
        pending_execution_message="\n\n<pending-execution>\nA plan is queued for execution: ${plan_path}\nRun /launch-subagents-execution to start implementation with fresh context.\n</pending-execution>"
    fi
fi
```

**Step 2: Add pending_execution_escaped after line 40**

After `warning_escaped=$(escape_for_json "$warning_message")`, add:

```bash
pending_escaped=$(escape_for_json "$pending_execution_message")
```

**Step 3: Include pending message in output**

Modify line 47 (the additionalContext line) to append the pending message. Change:

```bash
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_superpowers_escaped}\n\n${warning_escaped}\n</EXTREMELY_IMPORTANT>"
```

To:

```bash
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_superpowers_escaped}\n\n${warning_escaped}${pending_escaped}\n</EXTREMELY_IMPORTANT>"
```

**Step 4: Verify the script is valid**

Run:
```bash
bash -n hooks/session-start.sh && echo "Syntax OK"
```

Expected: `Syntax OK`

**Step 5: Test without state file**

Run:
```bash
cd /path/to/test/project && /path/to/hooks/session-start.sh | jq .
```

Expected: JSON output without `<pending-execution>` block.

**Step 6: Test with state file**

Run:
```bash
mkdir -p docs/plans
echo '{"planPath":"docs/plans/test.md","skill":"subagent-driven-development"}' > docs/plans/.pending-execution.json
./hooks/session-start.sh | jq -r '.hookSpecificOutput.additionalContext' | grep -A2 "pending-execution"
rm docs/plans/.pending-execution.json
```

Expected: Output contains `<pending-execution>` with the plan path.

**Step 7: Commit**

```bash
git add hooks/session-start.sh
git commit -m "feat: detect pending execution in SessionStart hook"
```

---

## Task 3: Modify writing-plans Skill for Fresh-Context Handoff

**Files:**
- Modify: `skills/writing-plans/SKILL.md:109-117`

**Step 1: Replace the "If Subagent-Driven chosen" section**

Replace lines 109-112:

```markdown
**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review
```

With:

```markdown
**If Subagent-Driven chosen:**
1. Write state file to `docs/plans/.pending-execution.json`:
   ```json
   {
     "planPath": "<the-plan-path-you-just-saved>",
     "skill": "subagent-driven-development",
     "createdAt": "<current-ISO-timestamp>"
   }
   ```
2. Display this handoff message:

   "Ready for fresh-context execution.

   Run these two commands:
   1. `/clear` - Reset context
   2. `/launch-subagents-execution` - Start implementation

   The plan path has been saved. After `/clear`, you'll be reminded to run `/launch-subagents-execution`."

3. **Stop here** - Do NOT invoke subagent-driven-development in this session (context is exhausted)
```

**Step 2: Verify the changes**

Run:
```bash
grep -A20 "If Subagent-Driven chosen" skills/writing-plans/SKILL.md
```

Expected: Shows the new state file + handoff message instructions.

**Step 3: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat: add fresh-context handoff to writing-plans skill"
```

---

## Task 4: Update Documentation

**Files:**
- Modify: `docs/plans/2026-01-11-launch-execution-design.md` (add note about gitignore)

**Step 1: Add gitignore recommendation to design doc**

Add a section at the end of the design document:

```markdown

## Recommended .gitignore Addition

Projects using this feature should add to their `.gitignore`:

```
# Superpowers pending execution state
docs/plans/.pending-execution.json
```
```

**Step 2: Commit**

```bash
git add docs/plans/2026-01-11-launch-execution-design.md
git commit -m "docs: add gitignore recommendation to design"
```

---

## Task 5: Manual Integration Test

**No files to modify - verification only**

**Step 1: Simulate the full flow**

In a test project directory:

```bash
# Create test state file
mkdir -p docs/plans
cat > docs/plans/.pending-execution.json << 'EOF'
{
  "planPath": "docs/plans/test-plan.md",
  "skill": "subagent-driven-development",
  "createdAt": "2026-01-11T15:30:00Z"
}
EOF

# Create dummy plan
echo "# Test Plan" > docs/plans/test-plan.md

# Run session-start hook and verify output
./hooks/session-start.sh | jq -r '.hookSpecificOutput.additionalContext' | grep "pending-execution" && echo "PASS: Hook detects state file"

# Clean up
rm docs/plans/.pending-execution.json docs/plans/test-plan.md
```

Expected: `PASS: Hook detects state file`

**Step 2: Verify command exists in plugin manifest auto-discovery**

Run:
```bash
ls -la commands/launch-subagents-execution.md && echo "PASS: Command file exists"
```

Expected: `PASS: Command file exists`

**Step 3: Final verification**

Run:
```bash
git log --oneline -5
```

Expected: Shows 4 commits for this feature (command, hook, skill, docs).
