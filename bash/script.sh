#!/bin/bash

# Checks if a file is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <logfile>"
  exit 1
fi

logfile=$1

# Checks if the file exists
if [ ! -f "$logfile" ]; then
  echo "Log file not found!"
  exit 1
fi

# Extract IP addresses, count their occurrences, and sort in descending order
awk '{print $2}' "$logfile" | sort | uniq -c | sort -nr
