#!/bin/bash
# CPU-intensive algorithm: computes a heavy trigonometric series sum.
# Input: seed (1..20) — varies the computation slightly, keeps runtime stable.
# Runtime: ~2-3 sec on a typical VM (tune ITERS if needed).
ITERS=3000000
seed=${1:-1}

awk -v seed="$seed" -v iters="$ITERS" 'BEGIN {
    s = 0
    for (i = 1; i <= iters; i++) {
        x = i * seed * 1e-6
        s += sin(x) * cos(x) / (i + 1.0)
    }
    printf "seed=%s result=%.10f\n", seed, s
}'
