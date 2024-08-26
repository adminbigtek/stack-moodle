#!/bin/bash

# Thiết lập các biến
PHP_VERSION="8.1"

# Định nghĩa màu sắc cho thông báo
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Hàm để hiển thị thông báo với màu sắc
function echo_success {
    echo -e "${GREEN}✅ $1${NC}"
}

function echo_error {
    echo -e "${RED}❌ $1${NC}"
}

function echo_info {
    echo -e "${YELLOW}ℹ️ $1${NC}"
}

# Xóa tệp kiểm tra cấu hình PHP
echo_info "Xóa tệp kiểm tra cấu hình PHP..."
sudo rm -f /var/www/html/info.php
if [ $? -eq 0 ]; then
    echo_success "Đã xóa tệp kiểm tra cấu hình PHP."
else
    echo_error "Có lỗi khi xóa tệp kiểm tra cấu hình PHP."
fi
echo

# Gỡ bỏ các gói PHP và module liên quan
echo_info "Gỡ bỏ các gói PHP $PHP_VERSION và các module liên quan..."
sudo apt-get remove --purge -y php${PHP_VERSION}* libapache2-mod-php${PHP_VERSION} libapache2-mod-fcgid > /dev/null 2>&1
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get autoclean > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã gỡ bỏ PHP $PHP_VERSION và các module liên quan."
else
    echo_error "Có lỗi khi gỡ bỏ PHP $PHP_VERSION và các module liên quan."
fi
echo

# Xóa repository của PHP
echo_info "Xóa repository của PHP..."
sudo add-apt-repository -r -y ppa:ondrej/php > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã xóa repository của PHP."
else
    echo_error "Có lỗi khi xóa repository của PHP."
fi
echo

# Gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM
echo_info "Gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM..."
sudo sed -i '/<FilesMatch \.php$>/,/<\/FilesMatch>/d' /etc/apache2/sites-available/000-default.conf > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM."
else
    echo_error "Có lỗi khi gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM."
fi
echo

# Tắt các module của Apache2 đã kích hoạt
echo_info "Tắt các module của Apache2..."
sudo a2dismod ssl headers proxy_fcgi setenvif > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã tắt các module của Apache2."
else
    echo_error "Có lỗi khi tắt các module của Apache2."
fi
echo

# Vô hiệu hóa và gỡ bỏ Apache2
echo_info "Vô hiệu hóa và gỡ bỏ Apache2..."
sudo systemctl stop apache2 > /dev/null 2>&1
sudo systemctl disable apache2 > /dev/null 2>&1
sudo apt-get remove --purge -y apache2 > /dev/null 2>&1
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get autoclean > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã vô hiệu hóa và gỡ bỏ Apache2."
else
    echo_error "Có lỗi khi vô hiệu hóa và gỡ bỏ Apache2."
fi
echo

# Xóa các file cấu hình còn sót lại
echo_info "Xóa các file cấu hình còn sót lại của Apache2 và PHP..."
sudo rm -rf /etc/apache2 /etc/php${PHP_VERSION} /var/lib/apache2 /var/log/apache2 /var/log/php${PHP_VERSION}
if [ $? -eq 0 ]; then
    echo_success "Đã xóa các file cấu hình còn sót lại."
else
    echo_error "Có lỗi khi xóa các file cấu hình còn sót lại."
fi
echo

echo_success "Hoàn tất quá trình gỡ bỏ các gói và cấu hình."
