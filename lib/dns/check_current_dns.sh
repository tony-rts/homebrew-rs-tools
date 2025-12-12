#!/bin/bash

REQUIRED_PRIMARY="8.8.8.8"
REQUIRED_SECONDARY="8.8.4.4"

echo "🔍 Bắt đầu kiểm tra cấu hình DNS hiện tại..."
echo

total_interfaces=0
compliant_interfaces=0
non_compliant_interfaces=0

while IFS= read -r interface; do
    # Bỏ qua interface Thunderbolt
    if [[ "$interface" == *"Thunderbolt"* ]]; then
        echo "ℹ️ Bỏ qua interface: $interface (không cần cấu hình DNS)"
        continue
    fi

    ((total_interfaces++))

    echo "----------------------------------------"
    echo "🌐 Interface: $interface"

    dns_output=$(networksetup -getdnsservers "$interface" 2>&1)

    if [[ "$dns_output" == *"There aren't any DNS Servers set on"* ]]; then
        echo "⚠️ Chưa cấu hình DNS – đang dùng DNS của nhà mạng (không đạt yêu cầu)"
        ((non_compliant_interfaces++))

    elif [[ "$dns_output" == "$REQUIRED_PRIMARY"$'\n'"$REQUIRED_SECONDARY" ]]; then
        echo "✅ DNS đã cấu hình đúng: $REQUIRED_PRIMARY và $REQUIRED_SECONDARY"
        ((compliant_interfaces++))

    else
        echo "❌ DNS không đúng chuẩn:"
        echo "$dns_output"
        ((non_compliant_interfaces++))
    fi

done < <(networksetup -listallnetworkservices | tail -n +2 | grep -v "^\*")

echo
echo "========================================"
echo "📋 BÁO CÁO TỔNG KẾT CẤU HÌNH DNS"
echo "Tổng số interface mạng:       $total_interfaces"
echo "✅ Đã cấu hình đúng DNS:       $compliant_interfaces"
echo "❌ Chưa cấu hình hoặc sai DNS: $non_compliant_interfaces"
echo "========================================"

exit $non_compliant_interfaces
