#!/bin/bash

NUM=1
SNAPSHOTTER=""
OUTPUT_DIR=""

usage() {
    echo "Usage: $0 -i|--images <images_name> [-n|--num <num>] [-s|--snapshotter <snapshotter>] -o|--output <output_dir>"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--images) images_name="$2"; shift ;;
        -n|--num) NUM="$2"; shift ;;
        -s|--snapshotter) SNAPSHOTTER="--snapshotter $2"; shift ;;
        -o|--output) OUTPUT_DIR="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

if [[ -z "$images_name" || -z "$OUTPUT_DIR" ]]; then
    usage
fi

if [[ "$OUTPUT_DIR" == "/root" || "$OUTPUT_DIR" == "/home" ]]; then
    echo "Error: Specified output directory is not allowed."
    exit 1
fi

if [[ -d "$OUTPUT_DIR" ]]; then
    rm -rf "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

CPU_COUNT=$(nproc)

start_container_and_collect_logs() {
    local i=$1
    local CPU_BIND=$(( (i - 1) % CPU_COUNT ))
    local LOG_FILE="$OUTPUT_DIR/nerdctl_container_$i.log"

    # Start the container and capture its ID
    CONTAINER_ID=$(nerdctl --insecure-registry run -d $SNAPSHOTTER --cpuset-cpus="$CPU_BIND" "$images_name")

    echo "Started container $i with ID $CONTAINER_ID on CPU $CPU_BIND. Logs will be written to $LOG_FILE."

    # Wait for the container to finish and collect logs
    nerdctl wait "$CONTAINER_ID"
    nerdctl logs "$CONTAINER_ID" > "$LOG_FILE" 2>&1

    # Remove the container
    nerdctl rm "$CONTAINER_ID"

    echo "Container $i finished. Logs collected in $LOG_FILE"
}

# Start containers and collect logs in parallel
for ((i=1; i<=NUM; i++)); do
    start_container_and_collect_logs $i &
done

# Wait for all background processes to finish
wait

echo "All containers have finished and logs collected."
