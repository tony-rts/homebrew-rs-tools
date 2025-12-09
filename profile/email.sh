#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Constants
CONFIG_FILE="$HOME/.rts/config"
EMAIL_REGEX='^[A-Za-z0-9._%+-]+@rulethesea\.org$'

# Load email from config file if it exists
# Returns 0 if a valid email was loaded, 1 otherwise
load_email_from_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 1
    fi
    
    # Source the config file to load EMAIL variable
    # Use a subshell to avoid polluting current environment with other variables
    local config_email
    config_email=$(grep '^EMAIL=' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- || echo "")
    
    if [[ -z "$config_email" ]]; then
        return 1
    fi
    
    # Export to parent scope
    EMAIL="$config_email"
    return 0
}

# Validate email format
# Args: $1 - email to validate
# Returns 0 if valid, 1 if invalid
is_valid_email() {
    local email="$1"
    if [[ "$email" =~ $EMAIL_REGEX ]]; then
        return 0
    else
        return 1
    fi
}

# Interactively prompt user for email until valid input is received
prompt_for_email() {
    local input_email
    
    while true; do
        # Prompt in Vietnamese
        read -r -p "Nhập email công ty (dạng *@rulethesea.org): " input_email
        
        # Validate the input
        if is_valid_email "$input_email"; then
            EMAIL="$input_email"
            return 0
        else
            echo "Email không hợp lệ. Vui lòng nhập đúng định dạng *@rulethesea.org." >&2
        fi
    done
}

# Save email to config file
# Args: $1 - email to save
save_email_to_config() {
    local email="$1"
    
    # Ensure config directory exists
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    # Write to temporary file first for atomic operation
    local temp_file="${CONFIG_FILE}.tmp"
    echo "EMAIL=$email" > "$temp_file"
    
    # Atomically move temp file to config file
    mv "$temp_file" "$CONFIG_FILE"
}

# Main logic
main() {
    local EMAIL=""
    
    # Try to load existing email from config
    if load_email_from_config && is_valid_email "$EMAIL"; then
        # Valid email already exists in config
        echo "$EMAIL"
        exit 0
    fi
    
    # No valid email found, prompt user
    prompt_for_email
    
    # Save the valid email to config
    save_email_to_config "$EMAIL"
    
    # Output the email
    echo "$EMAIL"
    exit 0
}

# Run main function
main
