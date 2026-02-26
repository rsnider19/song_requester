#!/bin/bash
# Auto-runs build_runner after editing Dart files that contain codegen annotations.
# Detects @freezed, @riverpod, @JsonSerializable, @DriftDatabase, etc.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only process .dart source files (not generated ones)
if [[ ! "$FILE_PATH" =~ \.dart$ ]]; then
  exit 0
fi
if [[ "$FILE_PATH" =~ \.(g|freezed|gen)\.dart$ ]]; then
  exit 0
fi

# Check if the file exists (it might be newly created)
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check if the file contains codegen annotations
if ! grep -qE '@(freezed|Freezed|riverpod|Riverpod|JsonSerializable|JsonKey|DriftDatabase|UseRowClass|TypedResult)' "$FILE_PATH" 2>/dev/null; then
  # Also check for part directives that indicate codegen
  if ! grep -qE "^part '.*\.(g|freezed)\.dart';" "$FILE_PATH" 2>/dev/null; then
    exit 0
  fi
fi

# Run build_runner from the project root
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if command -v fvm &>/dev/null; then
  cd "$PROJECT_DIR" && fvm dart run build_runner build --delete-conflicting-outputs 2>&1
elif command -v dart &>/dev/null; then
  cd "$PROJECT_DIR" && dart run build_runner build --delete-conflicting-outputs 2>&1
fi

exit 0
