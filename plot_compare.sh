#!/bin/bash
# Generates comparison graphs: 1 CPU vs 2 CPU for each experiment type.
# Run AFTER you have collected results for both 1-CPU and 2-CPU configurations.
# Expected files in results/:
#   seq_cpu_1cpu.dat  par_cpu_1cpu.dat  seq_disk_1cpu.dat  par_disk_1cpu.dat
#   seq_cpu_2cpu.dat  par_cpu_2cpu.dat  seq_disk_2cpu.dat  par_disk_2cpu.dat
#
# How to collect 2-CPU results:
#   1. Rename current results: mv results/seq_cpu.dat results/seq_cpu_1cpu.dat  (etc.)
#   2. Shut down VM, set 2 CPUs, reboot
#   3. Run: bash run_all.sh
#   4. Rename again: mv results/seq_cpu.dat results/seq_cpu_2cpu.dat  (etc.)
#   5. Run this script.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS="$SCRIPT_DIR/results"

command -v gnuplot &>/dev/null || {
    echo "gnuplot not found. Install: sudo dnf install gnuplot -y"
    exit 1
}

for suffix in 1cpu 2cpu; do
    for kind in seq_cpu par_cpu seq_disk par_disk; do
        f="$RESULTS/${kind}_${suffix}.dat"
        [[ -f "$f" ]] || { echo "Missing: $f"; exit 1; }
    done
done

gnuplot << EOF
set terminal png size 900,600 font "DejaVu Sans,11"
set xlabel "N (number of tasks)"
set ylabel "Time (seconds)"
set grid
set key top left

# Graph 1: Sequential CPU — 1cpu vs 2cpu
set output "$RESULTS/graph1_seq_cpu.png"
set title "Exp. 1 & 3: CPU-bound, Sequential (1 CPU vs 2 CPU)"
plot "$RESULTS/seq_cpu_1cpu.dat" using 1:2 with linespoints lw 2 pt 7 title "Sequential, 1 CPU", \
     "$RESULTS/seq_cpu_2cpu.dat" using 1:2 with linespoints lw 2 pt 5 title "Sequential, 2 CPU"

# Graph 2: Parallel CPU — 1cpu vs 2cpu
set output "$RESULTS/graph2_par_cpu.png"
set title "Exp. 1 & 3: CPU-bound, Parallel (1 CPU vs 2 CPU)"
plot "$RESULTS/par_cpu_1cpu.dat" using 1:2 with linespoints lw 2 pt 7 title "Parallel, 1 CPU", \
     "$RESULTS/par_cpu_2cpu.dat" using 1:2 with linespoints lw 2 pt 5 title "Parallel, 2 CPU"

# Graph 3: Sequential Disk — 1cpu vs 2cpu
set output "$RESULTS/graph3_seq_disk.png"
set title "Exp. 2 & 4: Disk I/O, Sequential (1 CPU vs 2 CPU)"
plot "$RESULTS/seq_disk_1cpu.dat" using 1:2 with linespoints lw 2 pt 7 title "Sequential, 1 CPU", \
     "$RESULTS/seq_disk_2cpu.dat" using 1:2 with linespoints lw 2 pt 5 title "Sequential, 2 CPU"

# Graph 4: Parallel Disk — 1cpu vs 2cpu
set output "$RESULTS/graph4_par_disk.png"
set title "Exp. 2 & 4: Disk I/O, Parallel (1 CPU vs 2 CPU)"
plot "$RESULTS/par_disk_1cpu.dat" using 1:2 with linespoints lw 2 pt 7 title "Parallel, 1 CPU", \
     "$RESULTS/par_disk_2cpu.dat" using 1:2 with linespoints lw 2 pt 5 title "Parallel, 2 CPU"

EOF

echo "4 comparison graphs saved in $RESULTS/"
ls -1 "$RESULTS"/graph*.png
