#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

CURRENT=$(cat $2)
OTHER=$(cat $3)

$SCRIPT_DIR/src/main.exe "$CURRENT" "$OTHER" > $2

exit 0