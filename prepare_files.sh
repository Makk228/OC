#!/bin/bash
# Creates 20 data files for disk I/O experiments.
# Each file contains LINES sequential integers (1, 2, 3, ...).
# Tune LINES so that disk_task.sh on one file takes ~2-3 seconds on your VM.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINES=${1:-5000}

mkdir -p "$SCRIPT_DIR/data"

for i in $(seq 1 20); do
    seq 1 "$LINES" > "$SCRIPT_DIR/data/file_${i}.txt"
done

echo "Created 20 files with $LINES lines each in $SCRIPT_DIR/data/"
echo "Run: bash calibrate.sh  to tune LINES for your machine"
