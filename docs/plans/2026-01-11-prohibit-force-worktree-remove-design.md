# Design: Prohibit --force in git worktree remove

**Date:** 2026-01-11
**Status:** Draft
**Skill:** finishing-a-development-branch

## Problem Statement

When executing the `finishing-a-development-branch` skill, Claude sometimes adds the `--force` flag to `git worktree remove` commands. This causes:

1. **Safety Net plugin blocks the command** - The operation fails, breaking the workflow
2. **Potential data loss** - `--force` removes worktrees even with uncommitted changes, which could silently destroy work

The current skill does not explicitly use `--force`, but also does not prohibit it. Claude may add `--force` as a "helpful" addition when the basic command fails.

## Root Cause

The skill's Step 5 (Cleanup Worktree) shows:

```bash
git worktree remove <worktree-path>
```

Without explicit prohibition, Claude may:
- Add `--force` when removal fails (e.g., if still in the worktree directory)
- Assume force is acceptable for cleanup operations

## Proposed Solution

Add explicit prohibitions in three locations within `finishing-a-development-branch/SKILL.md`:

### 1. Step 5: Cleanup Worktree

Add explicit prohibition immediately after the command:

```markdown
If yes:
```bash
git worktree remove <worktree-path>
```

**Never use `--force`** - if removal fails, the worktree has uncommitted changes or other issues that need manual resolution.
```

### 2. Red Flags Section (Never list)

Add to existing "Never" list:

```markdown
- Use `--force` with `git worktree remove` (blocked by Safety Net)
```

### 3. Common Mistakes Section

Add new entry:

```markdown
**Using --force on worktree removal**
- **Problem:** Forces removal even when worktree has uncommitted work
- **Fix:** Never use --force; resolve underlying issue manually if removal fails
```

## Design Rationale

### Why three locations?

1. **Step 5** - In-context reminder at point of use
2. **Red Flags** - Quick reference for prohibited actions
3. **Common Mistakes** - Explains why this matters (educational)

### Why not just fix if removal fails?

The skill should not attempt automatic recovery because:
- Uncommitted changes indicate user intent that we shouldn't override
- Being in the worktree directory requires user to navigate out
- Other issues may require investigation

Manual resolution ensures the user is aware of and approves any data loss.

## Implementation

Single file change: `skills/finishing-a-development-branch/SKILL.md`

### Changes Summary

| Section | Change |
|---------|--------|
| Step 5: Cleanup Worktree (after line 148) | Add prohibition note |
| Red Flags → Never (after line 185) | Add bullet point |
| Common Mistakes (after line 176) | Add new mistake entry |

## Testing

Verify by reviewing the skill and confirming:
1. Prohibition is clear in Step 5
2. Red Flags lists `--force` as prohibited
3. Common Mistakes explains the issue

## Rollout

1. Implement changes in fix branch
2. Commit with descriptive message
3. Create PR for review
