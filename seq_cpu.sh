#!/bin/bash
# Runs N compute.sh tasks SEQUENTIALLY. Each next starts after the previous finishes.
# Usage: bash seq_cpu.sh <N>
N=${1:-1}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for ((i = 1; i <= N; i++)); do
    bash "$SCRIPT_DIR/compute.sh" "$i" > /dev/null
done
