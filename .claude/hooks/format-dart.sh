#!/bin/bash
# Auto-formats Dart files after edits using the project's FVM-managed Dart SDK.
# Skips generated files (they have their own formatting).

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only format .dart files
if [[ ! "$FILE_PATH" =~ \.dart$ ]]; then
  exit 0
fi

# Skip generated files — they'll be regenerated anyway
if [[ "$FILE_PATH" =~ \.(g|freezed|gen)\.dart$ ]]; then
  exit 0
fi

# Format the file using FVM's dart formatter
if command -v fvm &>/dev/null; then
  fvm dart format --line-length 120 "$FILE_PATH" 2>/dev/null
elif command -v dart &>/dev/null; then
  dart format --line-length 120 "$FILE_PATH" 2>/dev/null
fi

exit 0
