#!/bin/bash
# Generates PNG graphs from results/ using gnuplot.
# Install gnuplot on CentOS 8: sudo dnf install gnuplot -y
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS="$SCRIPT_DIR/results"

command -v gnuplot &>/dev/null || {
    echo "gnuplot not found. Install: sudo dnf install gnuplot -y"
    exit 1
}

# Check required files exist
for f in seq_cpu par_cpu seq_disk par_disk; do
    [[ -f "$RESULTS/${f}.dat" ]] || {
        echo "Missing $RESULTS/${f}.dat — run run_all.sh first"
        exit 1
    }
done

gnuplot << EOF
set terminal png size 900,600 font "DejaVu Sans,11"
set xlabel "N (number of tasks)"
set ylabel "Time (seconds)"
set grid
set key top left

# --- Graph 1: CPU, 1 processor ---
set output "$RESULTS/graph_cpu_1cpu.png"
set title "CPU-bound tasks, 1 CPU: Sequential vs Parallel"
plot "$RESULTS/seq_cpu.dat" using 1:2 with linespoints lw 2 pt 7 title "Sequential", \
     "$RESULTS/par_cpu.dat" using 1:2 with linespoints lw 2 pt 5 title "Parallel"

# --- Graph 2: Disk, 1 processor ---
set output "$RESULTS/graph_disk_1cpu.png"
set title "Disk I/O tasks, 1 CPU: Sequential vs Parallel"
plot "$RESULTS/seq_disk.dat" using 1:2 with linespoints lw 2 pt 7 title "Sequential", \
     "$RESULTS/par_disk.dat" using 1:2 with linespoints lw 2 pt 5 title "Parallel"

EOF

echo "Graphs saved:"
echo "  $RESULTS/graph_cpu_1cpu.png"
echo "  $RESULTS/graph_disk_1cpu.png"
echo ""
echo "After switching VM to 2 CPUs, rename current .dat files (e.g. seq_cpu_1cpu.dat),"
echo "re-run run_all.sh, then run plot_2cpu.sh"
