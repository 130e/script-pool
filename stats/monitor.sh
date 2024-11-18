#!/usr/bin/env bash

# Default duration (in seconds)
DURATION=${2:-0}  # 0 means run forever

# Set the output log file
LOG_FILE="ss_${1:-0}.log"

# Function to check if required commands exist
check_dependencies() {
    for cmd in ss grep date; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: Required command '$cmd' not found"
            exit 1
        fi
    done
}

# Function to format and write log entry
write_log() {
    local timestamp="$1"
    local data="$2"

    if [ -z "$data" ]; then
        echo "time:$timestamp No_matching_connection:0" >> "$LOG_FILE"
    else
        echo "time:$timestamp $data" >> "$LOG_FILE"
    fi
}

# Main monitoring function
monitor_connection() {
    local start_time=$(date +%s%N)
    local end_time

    # Calculate end time if duration is specified
    if [ "$DURATION" -gt 0 ]; then
        end_time=$((start_time + (DURATION*1000000000)))
        echo "Monitoring for $DURATION seconds..."
    else
        echo "Monitoring indefinitely..."
    fi

    while true; do
        # Get current Unix timestamp in nano seconds
        # millisec: $(($(date +%s%N)/1000000))
        current_time=$(date +%s%N)

        # Check if monitoring duration has elapsed
        if [ "$DURATION" -gt 0 ] && [ "$current_time" -ge "$end_time" ]; then
            echo "Monitoring complete. Duration: $DURATION seconds"
            break
        fi

        # Run the command and capture output
        output=$(ss -it | grep -F "10.0.0.1:5257" -A 1 | grep -v -F "10.0.0.1:5257")

        # Write to log file
        write_log "$current_time" "$output"

        # Sleep for X seconds
        # sleep 0.001
    done
}

# Show usage if -h or --help is provided
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [duration_in_seconds]"
    echo "  duration_in_seconds: Optional. How long to monitor (in seconds)"
    echo "  If no duration is specified, will monitor indefinitely"
    exit 0
fi

# Validate duration if provided
if [ -n "$DURATION" ] && ! [[ "$DURATION" =~ ^[0-9]+$ ]]; then
    echo "Error: Duration must be a positive number"
    exit 1
fi

echo "Starting connection monitoring..."
echo "Logging to: $LOG_FILE"

# Check dependencies before starting
check_dependencies

# Create or clear log file
> "$LOG_FILE"

# Start monitoring with error handling
monitor_connection
