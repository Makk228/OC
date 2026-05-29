#!/bin/bash
# Master experiment runner.
# Runs all 4 experiments (seq_cpu, par_cpu, seq_disk, par_disk) for N=1..20,
# 10 repetitions each, saves averaged results to results/.
#
# Usage:
#   bash run_all.sh              — run all 4 experiments
#   bash run_all.sh cpu          — run only CPU experiments
#   bash run_all.sh disk         — run only disk experiments
#
# Tune these if calibrate.sh shows times outside 2-3 seconds:
DISK_LINES=5000   # lines per data file for disk tasks
REPEATS=10        # repetitions per (N, mode) combination
MAX_N=20          # maximum parallelism / task count

export DISK_LINES

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS="$SCRIPT_DIR/results"
mkdir -p "$RESULTS"

# ------------------------------------------------------------------ helpers --

measure_time() {
    # Prints elapsed real seconds for running: bash <script> <arg>
    local script=$1
    local arg=$2
    LC_NUMERIC=C TIMEFORMAT='%R'
    { time bash "$script" "$arg" > /dev/null ; } 2>&1
}

run_experiment() {
    local label=$1    # e.g. "seq_cpu"
    local runner=$2   # path to seq_cpu.sh / par_cpu.sh etc.
    local needs_reset=${3:-0}   # 1 if disk files must be reset before each run
    local outfile="$RESULTS/${label}.dat"

    echo ""
    echo "========================================="
    echo " Experiment: $label"
    echo "========================================="
    > "$outfile"

    for ((n = 1; n <= MAX_N; n++)); do
        raw_times=""
        for ((r = 1; r <= REPEATS; r++)); do
            if [[ "$needs_reset" == "1" ]]; then
                bash "$SCRIPT_DIR/reset_files.sh" > /dev/null
            fi
            t=$(measure_time "$runner" "$n")
            raw_times="$raw_times $t"
            printf "  N=%-2d  run=%-2d  time=%s s\n" "$n" "$r" "$t"
        done

        avg=$(awk -v times="$raw_times" 'BEGIN {
            n = split(times, a, " ")
            s = 0; cnt = 0
            for (i = 1; i <= n; i++) {
                if (a[i] != "") { s += a[i]; cnt++ }
            }
            if (cnt > 0) printf "%.4f", s / cnt
            else print "0"
        }')
        echo "$n $avg" >> "$outfile"
        echo "  --> N=$n  average=$avg s"
    done

    echo "  Saved: $outfile"
}

# ------------------------------------------------------------------ prepare --

MODE=${1:-all}

if [[ "$MODE" == "all" || "$MODE" == "disk" ]]; then
    echo "Preparing data files (DISK_LINES=$DISK_LINES)..."
    bash "$SCRIPT_DIR/prepare_files.sh" "$DISK_LINES"
fi

# -------------------------------------------------------------------- run ---

if [[ "$MODE" == "all" || "$MODE" == "cpu" ]]; then
    run_experiment "seq_cpu" "$SCRIPT_DIR/seq_cpu.sh" 0
    run_experiment "par_cpu" "$SCRIPT_DIR/par_cpu.sh" 0
fi

if [[ "$MODE" == "all" || "$MODE" == "disk" ]]; then
    run_experiment "seq_disk" "$SCRIPT_DIR/seq_disk.sh" 1
    run_experiment "par_disk" "$SCRIPT_DIR/par_disk.sh" 1
fi

# ------------------------------------------------------------------ summary --

echo ""
echo "========================================="
echo " All experiments done. Results:"
echo "========================================="
for f in "$RESULTS"/*.dat; do
    echo ""
    echo "--- $(basename "$f") ---"
    echo "  N   avg_time(s)"
    cat "$f"
done

echo ""
echo "To build graphs run:  bash plot.sh"
