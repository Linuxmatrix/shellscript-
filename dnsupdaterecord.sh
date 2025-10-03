#!/bin/bash
 
# Define the input file and the column number to extract
INPUT_FILE="test.txt"
COLUMN_NUMBER=1  # Change this to the column number you want to extract
 
# Extract values from the specified column and store them in an array
VALUES=($(awk -v col=$COLUMN_NUMBER '{print $col}' $INPUT_FILE))
 
# Iterate over the array and find files with matching names
for VALUE in "${VALUES[@]}"; do
    echo "Searching for files with name: $VALUE"
 
    # Find the file with the matching name
    file=$(grep -r "db.$VALUE" /home/deranguh/DNS/dns/var/named/sm/ext/ | grep -v "sm.ext.zones" | head -n 1 | cut -d ":" -f1)
 
    if [ -n "$file" ]; then
        echo "File found: $file"
 
        # Append data from the input file to the found file
        awk -v value="$VALUE" '$1 == value {print substr($0, length(value) + 2)}' "$INPUT_FILE" >> "$file"
 
        # Output the first column and the output file name
        echo "First Column (used as filename): $VALUE"
        echo "Data appended to: $file"
    else
        echo "No matching file found for: $VALUE"
    fi
done
