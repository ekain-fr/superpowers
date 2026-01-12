#!/usr/bin/env bash
# SessionStart hook for superpowers plugin

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Check if legacy skills directory exists and build warning
warning_message=""
legacy_skills_dir="${HOME}/.config/superpowers/skills"
if [ -d "$legacy_skills_dir" ]; then
    warning_message="\n\n<important-reminder>IN YOUR FIRST REPLY AFTER SEEING THIS MESSAGE YOU MUST TELL THE USER:⚠️ **WARNING:** Superpowers now uses Claude Code's skills system. Custom skills in ~/.config/superpowers/skills will not be read. Move custom skills to ~/.claude/skills instead. To make this message go away, remove ~/.config/superpowers/skills</important-reminder>"
fi

# Check for pending execution state file
pending_execution_message=""
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
pending_file="${project_dir}/docs/plans/.pending-execution.json"
if [ -f "$pending_file" ]; then
    # Try jq first, fall back to grep/sed
    if command -v jq >/dev/null 2>&1; then
        plan_path=$(jq -r '.planPath' "$pending_file" 2>/dev/null)
    else
        # Fallback: extract planPath using grep/sed
        plan_path=$(grep -o '"planPath"[[:space:]]*:[[:space:]]*"[^"]*"' "$pending_file" | sed 's/.*"planPath"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    fi

    if [ -n "$plan_path" ] && [ "$plan_path" != "null" ]; then
        pending_execution_message="\n\n<pending-execution>\nA plan is queued for execution: ${plan_path}\nRun /launch-execution to start implementation with fresh context.\n</pending-execution>"
    fi
fi

# Read using-superpowers content
using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" 2>&1 || echo "Error reading using-superpowers skill")

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

using_superpowers_escaped=$(escape_for_json "$using_superpowers_content")
warning_escaped=$(escape_for_json "$warning_message")
pending_escaped=$(escape_for_json "$pending_execution_message")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the full content of your 'superpowers:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_superpowers_escaped}\n\n${warning_escaped}${pending_escaped}\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
