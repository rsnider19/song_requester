#!/bin/bash
# Blocks edits to .env files containing secrets. Only .env.example is allowed.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Allow .env.example (it's committed and has no secrets)
if [[ "$BASENAME" == ".env.example" ]]; then
  exit 0
fi

# Block all other .env* files
if [[ "$BASENAME" =~ ^\.env ]]; then
  jq -n --arg fp "$FILE_PATH" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": ("Cannot edit environment file: " + $fp + ". These files contain secrets and must not be modified. Edit env/.env.example for documentation instead.")
    }
  }'
fi

exit 0
