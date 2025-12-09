#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Constants
CONFIG_DIR="$HOME/.rts"
DEVICE_FILE="$CONFIG_DIR/device"

# Get primary MAC address from network interface
# Returns MAC address in XX:XX:XX:XX:XX:XX format
get_mac_address() {
    local mac_address=""
    
    # Try to get MAC from en0 (primary interface on macOS)
    if command -v networksetup &> /dev/null; then
        mac_address=$(networksetup -getmacaddress en0 2>/dev/null | awk '{print $3}' || echo "")
    fi
    
    # Fallback to ifconfig if networksetup didn't work
    if [[ -z "$mac_address" || "$mac_address" == "N/A" ]]; then
        mac_address=$(ifconfig en0 2>/dev/null | grep -o -E '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' | head -n1 || echo "")
    fi
    
    # If en0 failed, try to find first active interface with MAC
    if [[ -z "$mac_address" ]]; then
        for interface in en1 en2 en3; do
            mac_address=$(ifconfig "$interface" 2>/dev/null | grep -o -E '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' | head -n1 || echo "")
            if [[ -n "$mac_address" ]]; then
                break
            fi
        done
    fi
    
    if [[ -z "$mac_address" ]]; then
        echo "Error: Could not determine MAC address" >&2
        return 1
    fi
    
    # Normalize to uppercase
    echo "$mac_address" | tr '[:lower:]' '[:upper:]'
}

# Get Hardware UUID from system profiler
get_hardware_uuid() {
    local hardware_uuid=""
    
    if ! command -v system_profiler &> /dev/null; then
        echo "Error: system_profiler command not found (macOS required)" >&2
        return 1
    fi
    
    # Extract Hardware UUID from system profiler output
    hardware_uuid=$(system_profiler SPHardwareDataType 2>/dev/null | \
        grep -i "Hardware UUID" | \
        awk -F': ' '{print $2}' | \
        xargs || echo "")
    
    if [[ -z "$hardware_uuid" ]]; then
        echo "Error: Could not determine Hardware UUID" >&2
        return 1
    fi
    
    echo "$hardware_uuid"
}

# Get Serial Number from system profiler
get_serial_number() {
    local serial_number=""
    
    if ! command -v system_profiler &> /dev/null; then
        echo "Error: system_profiler command not found (macOS required)" >&2
        return 1
    fi
    
    # Extract Serial Number from system profiler output
    serial_number=$(system_profiler SPHardwareDataType 2>/dev/null | \
        grep -i "Serial Number" | \
        awk -F': ' '{print $2}' | \
        xargs || echo "")
    
    if [[ -z "$serial_number" ]]; then
        echo "Error: Could not determine Serial Number" >&2
        return 1
    fi
    
    echo "$serial_number"
}

# Write device information to config file
# Args: $1 - MAC address, $2 - Hardware UUID, $3 - Serial Number
write_device_file() {
    local mac="$1"
    local uuid="$2"
    local serial="$3"
    
    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"
    
    # Write to temporary file first for atomic operation
    local temp_file="${DEVICE_FILE}.tmp"
    
    cat > "$temp_file" << EOF
MAC_ADDRESS=$mac
HARDWARE_UUID=$uuid
SERIAL_NUMBER=$serial
EOF
    
    # Atomically move temp file to device file
    mv "$temp_file" "$DEVICE_FILE"
}

# Main logic
main() {
    local mac_address
    local hardware_uuid
    local serial_number
    
    # Collect device information
    mac_address=$(get_mac_address)
    hardware_uuid=$(get_hardware_uuid)
    serial_number=$(get_serial_number)
    
    # Validate that all values were obtained
    if [[ -z "$mac_address" ]]; then
        echo "Error: MAC address is empty" >&2
        exit 1
    fi
    
    if [[ -z "$hardware_uuid" ]]; then
        echo "Error: Hardware UUID is empty" >&2
        exit 1
    fi
    
    if [[ -z "$serial_number" ]]; then
        echo "Error: Serial Number is empty" >&2
        exit 1
    fi
    
    # Write to device file
    write_device_file "$mac_address" "$hardware_uuid" "$serial_number"
    
    # Print confirmation
    echo "Device info saved to $DEVICE_FILE"
    
    exit 0
}

# Run main function
main
