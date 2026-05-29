#!/bin/bash
# Disk I/O algorithm: reads each integer from FILE one by one,
# multiplies it by 2, and appends the result to the END of the same file.
# This is intentionally I/O-intensive: each value triggers a separate write syscall.
# Usage: bash disk_task.sh <filepath>
FILE=$1

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Usage: $0 <filepath>" >&2
    exit 1
fi

total_lines=$(wc -l < "$FILE")

# Open FILE on fd 3 for sequential reading (separate from the appending write end)
exec 3< "$FILE"

for ((i = 0; i < total_lines; i++)); do
    IFS= read -r val <&3
    result=$((val * 2))
    # Each echo >> opens the file, seeks to end, writes, closes — this is the I/O load
    echo "$result" >> "$FILE"
done

exec 3<&-
