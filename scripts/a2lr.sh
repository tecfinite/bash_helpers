#!/bin/bash

################################################################################
# Apache Log Retrieval Script
#
# This Bash script is designed to fetch Apache logs based on specified filters.
# It supports retrieving logs from the access log or error log file. The user
# can filter logs by type, status code, or within a specified range.
#
# Usage:
#   - To fetch logs from the access log:   ./apache_log_retrieval.sh -a <filter>
#   - To fetch logs from the error log:    ./apache_log_retrieval.sh -e <filter>
#
# Options:
#   -a       Fetch logs from the access log
#   -e       Fetch logs from the error log
#
# Filter Syntax:
#   - Use '*' to fetch all logs.
#   - Provide a numeric status code to fetch logs of a specific type.
#   - Use '<' followed by a number to fetch logs greater than that number.
#   - Provide two numbers separated by '<' to fetch logs within a range.
#
# Example:
#   - ./apache_log_retrieval.sh -a 404
#   - ./apache_log_retrieval.sh -e "*"
#   - ./apache_log_retrieval.sh -a "200 < 500"
#
# Author: Tecfinite
# Date: 18-10-2021
################################################################################

# Define the path to your Apache access log file
access_log="/var/log/apache2/access.log"

# Define the path to your Apache error log file
error_log="/var/log/apache2/error.log"


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# ! DO NOT CHANGE THE NEXT LINES !
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


# Check if the log file exists
check_log_file() {
  local log_file="$1"

  if [[ ! -f "$log_file" ]]; then
    echo "Log file not found: $log_file"
    exit 1
  fi
}

# Function to fetch Apache logs based on log file and filter input
fetch_apache_logs() {
  local log_file="$1"
  local filter="$2"
  local logs

  check_log_file "$log_file"

  if [[ "$filter" == "*" ]]; then
    # Fetch all logs
    logs=$(cat "$log_file")
  elif [[ "$filter" =~ ^[0-9]+$ ]]; then
    # Fetch logs of a specific type
    logs=$(grep " $filter " "$log_file")
  elif [[ "$filter" =~ ^[0-9]+[[:space:]]*"<" ]]; then
    # Fetch logs greater than a specific type
    local greater_than=$(echo "$filter" | awk '{print $1}')
    logs=$(grep -E " ([0-9]+) " "$log_file" | awk -v gt="$greater_than" '$2 > gt')
  elif [[ "$filter" =~ ^[0-9]+[[:space:]]*"<"[[:space:]]*[0-9]+$ ]]; then
    # Fetch logs within a range
    local lower_bound=$(echo "$filter" | awk '{print $1}')
    local upper_bound=$(echo "$filter" | awk '{print $3}')
    logs=$(grep -E " ([0-9]+) " "$log_file" | awk -v lb="$lower_bound" -v ub="$upper_bound" '$2 >= lb && $2 <= ub')
  else
    echo "Invalid input: $filter"
    exit 1
  fi

  if [[ -z "$logs" ]]; then
    echo "No logs found matching the criteria: $filter"
  else
    echo "Apache logs matching the criteria: $filter"
    echo "$logs"
  fi
}

# Check if the correct number of arguments is provided
if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 [-a|-e] <filter>"
  exit 1
fi

# Parse the arguments
if [[ "$1" == "-a" ]]; then
  fetch_apache_logs "$error_log" "$2"
elif [[ "$1" == "-e" ]]; then
  fetch_apache_logs "$access_log" "$2"
else
  echo "Invalid option: $1"
  echo "Usage: $0 [-a|-e] <filter>"
  exit 1
fi
