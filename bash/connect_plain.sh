#!/bin/bash

# Source the base script to load machine details
# shellcheck source=/dev/null
source "$(dirname "$0")/connect_base.sh"

# Construct the hostname for the target machine
HOSTNAME="$MACHINE_NAME.$DOMAIN"

## Uncomment below if setup does not need usernames
# HOSTNAME="$MACHINE_NAME"

# Construct the SSH command with automatic host key acceptance
SSH_COMMAND="ssh -o StrictHostKeyChecking=no $USER@$HOSTNAME"

## Uncomment below if setup does not need usernames
# SSH_COMMAND="ssh -o StrictHostKeyChecking=no $HOSTNAME"

# Print the SSH command
echo "Connecting to: $HOSTNAME"

# Execute the SSH command
eval "$SSH_COMMAND"
