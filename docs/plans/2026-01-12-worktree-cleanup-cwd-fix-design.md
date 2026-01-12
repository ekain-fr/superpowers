# Worktree Cleanup CWD Fix

**Issue:** [#238](https://github.com/obra/superpowers/issues/238)
**Date:** 2026-01-12

## Problem

The `/finish` workflow fails when Claude's working directory is inside the worktree being removed. Git returns: `fatal: cannot remove worktree '<path>': '<path>' is the current working directory`

## Solution

Before running `git worktree remove`, detect if the current directory is inside the target worktree. If so, navigate to the equivalent path in the main worktree (falling back to repo root if that path doesn't exist).

**Example:**
- Current: `/project/.worktrees/feature-auth/src/components/`
- After cleanup: `/project/src/components/` (if exists) or `/project/` (fallback)

## Implementation

Replace Step 5 in `finishing-a-development-branch` skill with:

```markdown
### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

```bash
CURRENT_DIR="$(pwd)"
WORKTREE_PATH="<worktree-path>"

# Navigate out if inside the worktree
if [[ "$CURRENT_DIR" == "$WORKTREE_PATH"* ]]; then
  RELATIVE_PATH="${CURRENT_DIR#$WORKTREE_PATH}"
  REPO_ROOT="$(git worktree list | head -1 | awk '{print $1}')"
  TARGET_PATH="$REPO_ROOT$RELATIVE_PATH"
  if [ -d "$TARGET_PATH" ]; then
    cd "$TARGET_PATH"
  else
    cd "$REPO_ROOT"
  fi
fi

# Now safe to remove
git worktree remove "$WORKTREE_PATH"
```

**Never use `--force`** - if removal fails, the worktree has uncommitted changes or other issues that need manual resolution.

**For Option 3:** Keep worktree.
```

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Not inside worktree | Skip navigation, proceed to remove |
| Inside worktree root | Navigate to repo root |
| Equivalent path exists | Navigate to equivalent path |
| Equivalent path doesn't exist | Fall back to repo root |

## Testing

1. Run `/finish` from worktree root
2. Run `/finish` from subdirectory inside worktree
3. Run `/finish` from new directory that doesn't exist on main
4. Run `/finish` from main worktree (not inside the feature worktree)

## Files to Modify

- `skills/finishing-a-development-branch/SKILL.md` - Update Step 5
