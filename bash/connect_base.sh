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
  echo "Usage: ./connect <machine_type> <domain> [config_file]"
  echo ""
  echo "Available machine types (from default config):"
  jq -r '(.machines | to_entries[] | .key + ": " + .value)' "$SCRIPT_DIR/$DEFAULT_CONFIG_FILE.json" | column -t
  echo ""
  echo "Available domains (from default config):"
  jq -r '(.domains | to_entries[] | .key + ": " + .value)' "$SCRIPT_DIR/$DEFAULT_CONFIG_FILE.json" | column -t
  echo ""
  echo "# Optional: Specify a custom config file (e.g., ./connect db east production)"
  echo "Available configuration files (*Note:* .json is auto appended, just use name):"
  ls "$SCRIPT_DIR"/*.json 2>/dev/null | xargs basename -a | sed 's/\.json$//'
  echo ""
  echo "Example: ./connect db east"
}

# Check if arguments are provided
if [ "$#" -lt 2 ]; then
  display_help
  exit 1
fi

# Extract arguments
MACHINE_TYPE="$1"
DOMAIN="$2"
# Use the third argument as config file, or fallback to DEFAULT_CONFIG_FILE
CONFIG_FILE="$SCRIPT_DIR/${3:-$DEFAULT_CONFIG_FILE}.json"

# Validate if the specified config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  exit 1
fi

# Validate machine type and domain using jq
VALID_MACHINE_TYPES=$(jq -r '.machines | keys[]' "$CONFIG_FILE" | grep "$MACHINE_TYPE")
VALID_DOMAINS=$(jq -r '.domains | keys[]' "$CONFIG_FILE" | grep "$DOMAIN")
 
# Print message if invalid
if [ -z "$VALID_MACHINE_TYPES" ] || [ -z "$VALID_DOMAINS" ]; then
  echo "Invalid machine type or domain. Use './connect' for help."
  echo "You entered: machine='$MACHINE_TYPE' | domain='$DOMAIN'"
  echo "Found: machine='$VALID_MACHINE_TYPES' | domain='$VALID_DOMAINS'"
  echo "From file: '$CONFIG_FILE'"
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
