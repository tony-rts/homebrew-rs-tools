#!/bin/bash

# Nhận các tham số từ command line
EMAIL="$1"
SERIAL_NUMBER="$2"
MAC_ADDRESS="$3"
HARDWARE_UUID="$4"
STATUS="$5"

# Kiểm tra xem đủ tham số chưa
if [ -z "$EMAIL" ] || [ -z "$SERIAL_NUMBER" ] || [ -z "$MAC_ADDRESS" ] || [ -z "$HARDWARE_UUID" ] || [ -z "$STATUS" ]; then
    echo "Usage: $0 <email> <serialNumber> <macAddress> <hardwareUUID> <status>"
    echo "Example: $0 user@example.com SN-123456 AA:BB:CC:DD:EE:FF 123e4567-e89b-12d3-a456-426614174000 ACTIVE"
    exit 1
fi

echo "📡 Đang gửi báo cáo cấu hình DNS đến server..."

# Gửi request với các tham số được truyền vào
curl -L -X POST "https://script.google.com/macros/s/AKfycbwO1gZkHfzxi4JgS94dCyCCvbTXWPNqRg7k0fpqsEKpDSOXayai0_9V7aj_Qb7d5mtCww/exec" \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"rulethesea2025!\",
    \"email\": \"$EMAIL\",
    \"serialNumber\": \"$SERIAL_NUMBER\",
    \"macAddress\": \"$MAC_ADDRESS\",
    \"hardwareUUID\": \"$HARDWARE_UUID\",
    \"status\": \"$STATUS\"
  }" \
  -s -o /dev/null
