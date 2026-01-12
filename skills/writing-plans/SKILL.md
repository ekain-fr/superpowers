---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Testing Plan Generation

**Generate alongside implementation plan:** `docs/plans/YYYY-MM-DD-<feature>-testing.md`

**Testing plan header:**

```markdown
# [Feature Name] Testing Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:testing to execute this plan.

**Goal:** [One sentence describing what testing validates]

**Max Fix Iterations:** [N from design doc]

**Source Design:** `docs/plans/YYYY-MM-DD-<feature>-design.md`

---
```

**Testing plan structure:**

```markdown
## Integration Tests

### Test 1: [Component interaction being tested]
**Files:**
- Create: `tests/integration/path/to/test.py`

**Step 1: Write the test**
[Complete test code]

**Step 2: Run test**
Run: [exact command]
Expected: PASS

---

## End-to-End Tests

### Test 1: [User flow being tested]
[Same structure as integration tests]

---

## Regression Tests

### Module: `path/to/impacted/module`
**Reason:** [Why this module might be affected]

**Step 1: Identify existing tests**
Run: [command to find tests]

**Step 2: Run regression suite**
Run: [exact command]
Expected: All PASS
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Execution Handoff

After saving both plans, offer execution choice:

**"Plans complete and saved:**
- Implementation: `docs/plans/<filename>.md`
- Testing: `docs/plans/<filename>-testing.md`

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
1. Write state file to `docs/plans/.pending-execution.json`:
   ```json
   {
     "projectRoot": "<absolute-path-to-current-working-directory>",
     "planPath": "<the-plan-path-you-just-saved>",
     "skill": "subagent-driven-development",
     "createdAt": "<current-ISO-timestamp>"
   }
   ```
   **Important:** `projectRoot` must be the absolute path to the current working directory (use cwd). This ensures the plan can be found after `/clear`.
2. Display this handoff message:

   "Ready for fresh-context execution.

   Run these two commands:
   1. `/clear` - Reset context
   2. `/launch-execution` - Start implementation

   The plan path has been saved. After `/clear`, you'll be reminded to run `/launch-execution`."

3. **Stop here** - Do NOT invoke subagent-driven-development in this session (context is exhausted)

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans
