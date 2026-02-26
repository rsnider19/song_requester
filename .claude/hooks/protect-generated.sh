#!/bin/bash
# Blocks edits to generated files (*.g.dart, *.freezed.dart, *.gen.dart).
# These files are produced by build_runner and should never be hand-edited.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" =~ \.(g|freezed|gen)\.dart$ ]]; then
  # Determine the source file for a helpful message
  SOURCE_FILE="${FILE_PATH%.g.dart}"
  SOURCE_FILE="${SOURCE_FILE%.freezed.dart}"
  SOURCE_FILE="${SOURCE_FILE%.gen.dart}"
  SOURCE_FILE="${SOURCE_FILE}.dart"

  jq -n --arg fp "$FILE_PATH" --arg sf "$SOURCE_FILE" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": ("Cannot edit generated file: " + $fp + ". Edit the source file (" + $sf + ") instead, then run: fvm dart run build_runner build --delete-conflicting-outputs")
    }
  }'
fi

exit 0
