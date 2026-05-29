#!/bin/bash
# Runs N disk_task.sh tasks SEQUENTIALLY. Each works on its own separate file.
# Usage: bash seq_disk.sh <N>
N=${1:-1}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for ((i = 1; i <= N; i++)); do
    bash "$SCRIPT_DIR/disk_task.sh" "$SCRIPT_DIR/data/file_${i}.txt"
done
