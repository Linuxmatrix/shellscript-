#!/bin/bash

declare OUTPUT="disk_report.csv"
declare MAX_JOBS=5
declare SERVER

# Initialize output CSV
echo "Hostname,Disk_Size/Used/Avail,Usage%,Largest_Non_OS_File_Size,Largest_Non_OS_File_Path" > "$OUTPUT"

# Limit parallel SSH jobs
function wait_for_jobs() {
  while [ "$(jobs -rp | wc -l)" -ge "$MAX_JOBS" ]; do
    sleep 1
  done
}

# Loop through servers from servers.txt
while read -r SERVER; do
  wait_for_jobs

  echo " Checking $SERVER ..."

  {
    ssh -o ConnectTimeout=10 \
        -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "$SERVER" bash -s << EOF

      # Convert bytes to human-readable format
      bytes_to_human() {
        local bytes=\$1
        local unit="B"
        local value=\$bytes

        if (( bytes >= 1099511627776 )); then
          value=\$(awk "BEGIN {printf \"%.2f\", \$bytes/1099511627776}")
          unit="TiB"
        elif (( bytes >= 1073741824 )); then
          value=\$(awk "BEGIN {printf \"%.2f\", \$bytes/1073741824}")
          unit="GiB"
        elif (( bytes >= 1048576 )); then
          value=\$(awk "BEGIN {printf \"%.2f\", \$bytes/1048576}")
          unit="MiB"
        elif (( bytes >= 1024 )); then
          value=\$(awk "BEGIN {printf \"%.2f\", \$bytes/1024}")
          unit="KiB"
        fi

        echo "\${value}\${unit}"
      }

      declare HOST
      HOST=\$(hostname)

      # Get root filesystem disk info (works on LVM or normal)
      declare FS SIZE USED AVAIL USEP
      read FS SIZE USED AVAIL USEP < <(df -Ph | awk '\$6 == "/" {print \$1, \$2, \$3, \$4, \$5}')

      # Find largest non-OS file >1GB under root (excluding system dirs)
      declare LARGEST_FILE_INFO
      LARGEST_FILE_INFO=\$(timeout 60 find / -xdev \\
        \( -path /proc -o -path /sys -o -path /dev -o -path /run -o -path /tmp \\
           -o -path /boot -o -path /var/lib -o -path /var/cache -o -path /usr \\
           -o -path /lib -o -path /lib64 \) -prune -o -type f -size +1G \\
        -printf '%s %p\n' 2>/dev/null | sort -nr | head -n1)

      declare LARGEST_FILE_BYTES=""
      declare LARGEST_FILE_PATH=""
      declare LARGEST_FILE_HR="0B"

      if [[ -n "\$LARGEST_FILE_INFO" ]]; then
        LARGEST_FILE_BYTES=\$(echo "\$LARGEST_FILE_INFO" | awk '{print \$1}')
        LARGEST_FILE_PATH=\$(echo "\$LARGEST_FILE_INFO" | cut -d' ' -f2-)
        LARGEST_FILE_HR=\$(bytes_to_human "\$LARGEST_FILE_BYTES")
      fi

      echo "\$HOST,\$SIZE/\$USED/\$AVAIL,\$USEP,\$LARGEST_FILE_HR,\$LARGEST_FILE_PATH"

EOF
  } >> "$OUTPUT" 2>> "error_${SERVER}.log" && echo " $SERVER: Success" || echo "a $SERVER: Failed (see error_${SERVER}.log)" &

done < servers.txt

wait

echo ""
echo " All done! Report saved to: $OUTPUT"
echo " Preview:"
column -t -s',' "$OUTPUT"
