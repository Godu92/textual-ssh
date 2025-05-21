#!/bin/bash

# Source the base script to load machine details
# shellcheck source=/dev/null
source "$(dirname "$0")/connect_base.sh"

# Retrieve password from .env
PASSWORD=$(load_password)

# Construct the hostname for the target machine
HOSTNAME="$MACHINE_NAME.$DOMAIN"

# Remove the existing host key from ~/.ssh/known_hosts
ssh-keygen -R "$HOSTNAME"

# Construct the SSH command with automatic host key acceptance
SSH_COMMAND="sshpass -p '$PASSWORD' ssh -o StrictHostKeyChecking=no $USER@$HOSTNAME"

# Print the SSH command and password
echo "Connecting to: $USER@$HOSTNAME"
echo "Password: $PASSWORD"

# Execute the SSH command
eval "$SSH_COMMAND"
