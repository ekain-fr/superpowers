# Worktree Repo Root Location

## Problem

When Claude Code starts in a subdirectory of a git repository, the `using-git-worktrees` skill creates `.worktrees/` relative to the current working directory instead of the repository root.

**Example:** Starting in `/repo/packages/frontend/` creates `/repo/packages/frontend/.worktrees/` instead of `/repo/.worktrees/`.

This causes:
- Worktrees scattered across subdirectories
- Inconsistent gitignore behavior
- Confusion about where worktrees live

## Solution

Always resolve the git repo root first using `git rev-parse --show-toplevel`, then perform all worktree operations relative to that path.

## Changes

### 1. Add repo root detection

At the start of the Directory Selection Process, detect repo root:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
```

### 2. Update path checks

All directory existence checks use repo root:

```bash
ls -d "$REPO_ROOT/.worktrees" 2>/dev/null
ls -d "$REPO_ROOT/worktrees" 2>/dev/null
```

### 3. Update gitignore verification

Check at repo root:

```bash
git check-ignore -q "$REPO_ROOT/.worktrees" 2>/dev/null
```

### 4. Update creation paths

Always create relative to repo root:

```bash
path="$REPO_ROOT/.worktrees/$BRANCH_NAME"
```

### 5. Update CLAUDE.md check

Check for CLAUDE.md at repo root:

```bash
grep -i "worktree.*director" "$REPO_ROOT/CLAUDE.md" 2>/dev/null
```

## Files to Modify

- `skills/using-git-worktrees/SKILL.md`

## Testing

1. Start Claude Code in a subdirectory of a git repo
2. Invoke the skill to create a worktree
3. Verify worktree is created at repo root, not current directory
