#!/bin/bash
# Calibration script: measures how long one CPU and one disk task takes.
# Run this BEFORE run_all.sh to tune ITERS and DISK_LINES.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Calibrating CPU task (compute.sh) ==="
echo "Measuring time for compute.sh with seed=1..."
{ TIMEFORMAT='%R'; time bash "$SCRIPT_DIR/compute.sh" 1 > /dev/null ; } 2>&1 | \
    awk '{printf "  CPU task time: %s seconds\n", $1}'
echo "  Target: 2-3 seconds. Adjust ITERS in compute.sh if needed."
echo ""

echo "=== Calibrating Disk task (disk_task.sh) ==="
DISK_LINES=${DISK_LINES:-5000}
echo "Measuring time for disk_task.sh with $DISK_LINES lines..."
mkdir -p "$SCRIPT_DIR/data"
seq 1 "$DISK_LINES" > "$SCRIPT_DIR/data/calib_test.txt"
{ TIMEFORMAT='%R'; time bash "$SCRIPT_DIR/disk_task.sh" "$SCRIPT_DIR/data/calib_test.txt" ; } 2>&1 | \
    awk '{printf "  Disk task time: %s seconds\n", $1}'
rm -f "$SCRIPT_DIR/data/calib_test.txt"
echo "  Target: 2-3 seconds. Adjust DISK_LINES in run_all.sh if needed."
echo ""
echo "Calibration done."
