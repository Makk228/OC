#!/bin/bash
# Runs N disk_task.sh tasks in PARALLEL. Each works on its own separate file.
# Usage: bash par_disk.sh <N>
N=${1:-1}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

pids=()
for ((i = 1; i <= N; i++)); do
    bash "$SCRIPT_DIR/disk_task.sh" "$SCRIPT_DIR/data/file_${i}.txt" &
    pids+=($!)
done

for pid in "${pids[@]}"; do
    wait "$pid"
done
