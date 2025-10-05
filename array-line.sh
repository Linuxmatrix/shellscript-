#!/bin/bash

filename="dns/var/named/ext/db.localhost.com"

# List of hostnames and IPs to remove
declare -A entries_to_remove=(
[";capitalvdmp"]="192.224.36.1"
[";capitalvdms"]="192.168.12.2"
[";capitalvdms2"]="192.224.36.3"
[";capitaldpm"]="192.224.36.10"
[";capitaldpps"]="192.168.12.11"
[";capitalddyp"]="192.224.36.15"
[";capitalddys"]="192.168.12.16"
[";capitaltyyc1"]="192.224.36.17"
[";capitaltyyc2"]="192.168.12.18"
[";capitalddt"]="192.224.36.20"
[";capitalcups"]="192.168.12.21"
[";capitalcti"]="192.224.36.25"

)


# Check if file exists
if [[ ! -f "$filename" ]]; then
  echo " Error: File '$filename' not found."
  exit 1
fi

# Backup original
timestamp=$(date +%Y%m%d-%H%M%S)
backup_file="/tmp/$(basename "$filename").bak.$timestamp"
cp "$filename" "$backup_file"

# Use awk to remove lines matching any hostname + IP
awk -v IGNORECASE=1 -v OFS="\t" -v ORS="\n" '
BEGIN {
  # Define lines to skip (hostname -> IP)
 skip[";capital-vdmp"]="192.224.36.1"
skip[";capitalvdms"]="192.168.12.2"
skip[";capitalvdms2"]="192.224.36.3"
skip[";capitaldpm"]="192.224.36.10"
skip[";capitaldpps"]="192.168.12.11"
skip[";capitalddyp"]="192.224.36.15"
skip[";capitalddys"]="192.168.12.16"
skip[";capitaltyyc1"]="192.224.36.17"
skip[";capitaltyyc2"]="192.168.12.18"
skip[";capitalddt"]="192.224.36.20"
skip[";capitalcups"]="192.168.12.21"
skip[";capitalcti"]="192.224.36.25"
}
{
  host=$1
  ip=$NF
  if (host in skip && skip[host] == ip) {
    next
  }
  print $0
}
' "$filename" > temp_cleaned.txt

# Replace the original with the cleaned version
mv temp_cleaned.txt "$filename"

echo " Cleaned file saved as '$filename'"
echo " Backup saved at '$backup_file'"
