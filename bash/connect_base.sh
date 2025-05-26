#!/bin/bash

# Determine the directory where the script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default configuration file
DEFAULT_CONFIG_FILE="example"

# Function to load the password from .env
load_password() {
  if [[ -f "$SCRIPT_DIR/.env" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env"
    echo "$PASSWORD"
  else
    echo "Error: .env file not found. Please create it with a PASSWORD variable."
    exit 1
  fi
}

# Function to display help text
display_help() {
  echo "Usage: ./connect [config_file] <domain> <machine_type>"
  echo ""
  echo "Example machine types (from default config):"
  jq -r '(.machines | to_entries[] | .key + ": " + .value)' "$SCRIPT_DIR/$DEFAULT_CONFIG_FILE.json" | column -t
  echo ""
  echo "Example domains (from default config):"
  jq -r '(.domains | to_entries[] | .key + ": " + .value)' "$SCRIPT_DIR/$DEFAULT_CONFIG_FILE.json" | column -t
  echo ""
  echo "# Optional: Specify a custom config file (e.g., ./connect db east production)"
  echo "Available configuration files (*Note:* .json is auto appended, just use name):"
  ls "$SCRIPT_DIR"/*.json 2>/dev/null | xargs basename -a | sed 's/\.json$//'
  echo ""
  echo "Example: ./connect db east"
}

# Check if arguments are provided
if [ "$#" -lt 1 ]; then
  display_help
  exit 1
fi

# Extract arguments
# Use the first argument as config file, or fallback to DEFAULT_CONFIG_FILE
CONFIG_FILE="$SCRIPT_DIR/${1:-$DEFAULT_CONFIG_FILE}.json"
DOMAIN="${2-NONE}"
MACHINE_TYPE="${3-NONE}"

# Validate if the specified config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  exit 1
fi

# Extract machines and domains using jq
machines=$(jq -r '(.machines | to_entries[] | .key + "\t|\t" + .value)' "$CONFIG_FILE")
domains=$(jq -r '(.domains | to_entries[] | .key + "\t|\t" + .value)' "$CONFIG_FILE")

# Combine headers and data for machines and domains
machine_data=$(
  printf "Key\t|\tValue\n"
  echo "$machines"
)
domain_data=$(
  printf "Key\t|\tValue\n"
  echo "$domains"
)

# Use paste to merge machines and domains side by side
combined_data=$(paste -d '\t' <(echo "$machine_data") <(echo "$domain_data"))

# Format the combined data as a table using column
table_format=$(echo "$combined_data" | column -t -s $'\t')

# Validate machine type and domain using jq
VALID_MACHINE_TYPES=$(jq -r '.machines | keys[]' "$CONFIG_FILE" | grep "$MACHINE_TYPE")
VALID_DOMAINS=$(jq -r '.domains | keys[]' "$CONFIG_FILE" | grep "$DOMAIN")

if [ -z "$VALID_MACHINE_TYPES" ] || [ -z "$VALID_DOMAINS" ]; then
  echo "Invalid machine type or domain. Use './connect' for help."
  echo "You entered: machine='$MACHINE_TYPE' | domain='$DOMAIN'"
  echo "Found: machine='$VALID_MACHINE_TYPES' | domain='$VALID_DOMAINS'"
  echo "From file: '$CONFIG_FILE'"
  printf "Machines:\t|\tDomains:\n"
  echo "--------------------------------------------------"
  echo "$table_format"
  exit 1
fi

# Retrieve values from the JSON
USER=$(jq -r '.user' "$CONFIG_FILE")
DOMAIN=$(jq -r --arg domain "$DOMAIN" '.domains[$domain]' "$CONFIG_FILE")
MACHINE_NAME=$(jq -r --arg machine "$MACHINE_TYPE" '.machines[$machine]' "$CONFIG_FILE")

# Export variables for use by child scripts
export USER
export DOMAIN
export MACHINE_NAME
export CONFIG_FILE
