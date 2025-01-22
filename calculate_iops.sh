#!/bin/bash

usage() {
    echo "Usage: $0 -d <log_directory>"
    exit 1
}

while getopts "d:" opt; do
    case $opt in
        d) log_dir="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ -z "$log_dir" ]; then
    usage
fi

if [ ! -d "$log_dir" ]; then
    echo "Error: Specified directory does not exist."
    exit 1
fi

# Function to remove 'k' and convert to numeric value
to_numeric() {
    echo "$1" | sed 's/k$//' | awk '{print $1}'
}

# Get all files in the directory
files=("$log_dir"/*)

# Check if there are any files
if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in the specified directory."
    exit 1
fi

# Process each file and store results
declare -A results
max_lines=0

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        values=$(grep "read: IOPS=" "$file" | sed 's/^.*read: IOPS=\|\,.*//g')
        results["$file"]="$values"
        lines=$(echo "$values" | wc -l)
        if [ $lines -gt $max_lines ]; then
            max_lines=$lines
        fi
    fi
done

# Print original values
echo "Original values:"
for file in "${!results[@]}"; do
    filename=$(basename "$file")
    echo "File: $filename"
    echo "${results[$file]}"
    echo "---"
done

# Calculate and print averages
echo "Averages:"
for ((i=1; i<=max_lines; i++)); do
    sum=0
    count=0
    for file in "${!results[@]}"; do
        value=$(echo "${results[$file]}" | sed -n "${i}p")
        if [ -n "$value" ]; then
            numeric_value=$(to_numeric "$value")
            sum=$(echo "$sum + $numeric_value" | bc)
            count=$((count + 1))
        fi
    done
    if [ $count -gt 0 ]; then
        average=$(echo "scale=2; $sum / $count" | bc)
        echo "$average"
    fi
done
