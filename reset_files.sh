#!/bin/bash
# Restores data files to their original state before each disk experiment run.
# Must be called before every measurement of disk tasks.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINES=${DISK_LINES:-5000}

for i in $(seq 1 20); do
    seq 1 "$LINES" > "$SCRIPT_DIR/data/file_${i}.txt"
done
