#!/bin/bash

# Google DNS
PRIMARY="8.8.8.8"
SECONDARY="8.8.4.4"

echo "🌐 Đang cấu hình tất cả interface mạng về Google DNS..."

# Duyệt từng interface, bỏ qua dòng có dấu *
networksetup -listallnetworkservices | tail -n +2 | grep -v "^\*" | while IFS= read -r interface; do
    # Bỏ qua Thunderbolt
    if [[ "$interface" == *"Thunderbolt"* ]]; then
        echo "ℹ️ Bỏ qua interface: $interface (không cần cấu hình DNS)"
        continue
    fi

    echo "----------------------------------------"
    echo "🔧 Interface: $interface"

    result=$(sudo networksetup -setdnsservers "$interface" $PRIMARY $SECONDARY 2>&1)

    if [[ $? -eq 0 ]]; then
        echo "✅ Đã cấu hình DNS thành: $PRIMARY $SECONDARY"
    else
        echo "❌ Lỗi khi cấu hình DNS:"
        echo "$result"
    fi
done

echo "🎉 Hoàn tất cấu hình DNS Google cho tất cả interface."
