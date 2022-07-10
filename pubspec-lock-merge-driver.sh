#!/bin/bash
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

SCRIPT_DIR=$(dirname "$0")

CURRENT=$(cat $2)
OTHER=$(cat $3)

printf "\n${YELLOW}WARN conflict A git conflict was detected in pubspec.lock. Attempting to auto-resolve.${NC}\n"

$SCRIPT_DIR/src/main.exe "$CURRENT" "$OTHER" > $2

exit 0