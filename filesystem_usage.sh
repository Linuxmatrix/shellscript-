#!/bin/bash

# Get the root filesystem usage percentage
USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# Set the threshold for usage
THRESHOLD=75

# Print the hostname
HOSTNAME=$(hostname)

# Check if the usage is greater than the threshold
if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "Warning: [$HOSTNAME] Root filesystem usage is at ${USAGE}% which is above the threshold of ${THRESHOLD}%."

    # Find and list large files (greater than 100MB) in the root filesystem
    echo "Finding large files in the root filesystem on [$HOSTNAME]:"
    find / -xdev -type f -size +400M -exec ls -lh {} \; 2>/dev/null | awk -v host="$HOSTNAME" '{ print host ": " $9 ": " $5 }'
else
    echo "[$HOSTNAME] Root filesystem usage is at ${USAGE}%, which is within the safe limit."
fi
