#!/bin/bash
# Runs N compute.sh tasks in PARALLEL. All start immediately without waiting.
# Usage: bash par_cpu.sh <N>
N=${1:-1}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

pids=()
for ((i = 1; i <= N; i++)); do
    bash "$SCRIPT_DIR/compute.sh" "$i" > /dev/null &
    pids+=($!)
done

for pid in "${pids[@]}"; do
    wait "$pid"
done
