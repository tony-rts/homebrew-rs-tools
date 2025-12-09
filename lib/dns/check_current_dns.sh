#!/bin/bash

# Script: check_current_dns.sh
# Mô tả: Kiểm tra DNS đang được cấu hình trên các interface mạng macOS

echo "🔍 Kiểm tra DNS hiện tại trên hệ thống..."

# Lấy danh sách interface mạng
interfaces=$(networksetup -listallnetworkservices | tail -n +2)

for interface in $interfaces; do
    echo "----------------------------------------"
    echo "🌐 Interface: $interface"

    # Lấy DNS đang cấu hình
    dns=$(networksetup -getdnsservers "$interface" 2>/dev/null)

    if [[ "$dns" == "There aren't any DNS Servers set on $interface" ]]; then
        echo "❌ Chưa cấu hình DNS (sử dụng mặc định từ router)"
    elif [[ "$dns" == "any DNS Servers"* ]]; then
        echo "⚠️ Không thể lấy thông tin DNS từ $interface"
    else
        echo "✅ DNS đang dùng:"
        echo "$dns"
    fi
done

echo "✅ Hoàn tất kiểm tra."
