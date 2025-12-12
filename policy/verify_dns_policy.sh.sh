#!/bin/bash

echo "🔐 [RS Policy] Từ tháng 12.2025, tất cả thiết bị của công ty RS bắt buộc sử dụng DNS của Google (8.8.8.8 và 8.8.4.4)."

# Bước 1: Kiểm tra trạng thái hiện tại
bash ./lib/dns/check_current_dns.sh
status=$?

# Bước 2: Nếu chưa đạt chuẩn, tiến hành sửa
RESULT="FAIL"
if [[ $status -gt 0 ]]; then
  echo
  echo "⚠️ Có $status interface chưa cấu hình đúng DNS."
  echo "🛠 Đang tiến hành cấu hình lại DNS Google cho tất cả interface..."

  bash ./lib/dns/set_google_dns_all.sh

  echo
  echo "🔁 Đang kiểm tra lại sau khi cấu hình..."

  bash ./lib/dns/check_current_dns.sh
  recheck_status=$?

  echo
  if [[ $recheck_status -eq 0 ]]; then
    echo "✅ Cảm ơn bạn đã tuân thủ chính sách DNS của RS!"
    RESULT="SUCCESS"
  else
    echo "❌ Một số interface vẫn chưa đạt yêu cầu sau khi cấu hình."
    echo "📞 Vui lòng liên hệ bộ phận kỹ thuật để được hỗ trợ."
    RESULT="FAIL"
  fi

else
  echo "✅ Thiết bị của bạn đã tuân thủ chính sách DNS."
  RESULT="SUCCESS"
fi

# Lấy thông tin email người dùng từ file cấu hình
EMAIL=$(bash ./profile/email.sh)

# Lấy thông tin thiết bị
bash ./profile/device.sh > /dev/null 2>&1
source "$HOME/.rts/device"

# Gửi báo cáo với thông tin thực tế
bash ./lib/dns/report.sh "$EMAIL" "$SERIAL_NUMBER" "$MAC_ADDRESS" "$HARDWARE_UUID" "$RESULT"
echo "📤 Báo cáo trạng thái đã được gửi về server."