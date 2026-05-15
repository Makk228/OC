cat > mem.bash << 'EOF'
#!/bin/bash

report_file="report.log"

: > "$report_file"

arr=()
step=0

while true
do
    arr+=(1 2 3 4 5 6 7 8 9 10)
    step=$((step + 1))

    if (( step % 100000 == 0 )); then
        echo "${#arr[@]}" >> "$report_file"
    fi
done
EOF

chmod +x mem.bash