#!/bin/bash

# Thiết lập các biến
PHP_VERSION="8.1"

# Xóa tệp kiểm tra cấu hình PHP
echo "Xóa tệp kiểm tra cấu hình PHP..."
sudo rm -f /var/www/html/info.php
echo "Đã xóa tệp kiểm tra cấu hình PHP."

# Gỡ bỏ các gói PHP và module liên quan
echo "Gỡ bỏ các gói PHP $PHP_VERSION và các module liên quan..."
sudo apt-get remove --purge -y php${PHP_VERSION}* libapache2-mod-php${PHP_VERSION} libapache2-mod-fcgid > /dev/null 2>&1
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get autoclean > /dev/null 2>&1
echo "Đã gỡ bỏ PHP $PHP_VERSION và các module liên quan."

# Xóa repository của PHP
echo "Xóa repository của PHP..."
sudo add-apt-repository -r -y ppa:ondrej/php > /dev/null 2>&1
echo "Đã xóa repository của PHP."

# Gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM
echo "Gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM..."
sudo sed -i '/<FilesMatch \\.php\\$>/,/<\/FilesMatch>/d' /etc/apache2/sites-available/000-default.conf > /dev/null 2>&1
echo "Đã gỡ bỏ cấu hình Apache2 liên quan đến PHP-FPM."

# Tắt các module của Apache2 đã kích hoạt
echo "Tắt các module của Apache2..."
sudo a2dismod ssl headers proxy_fcgi setenvif > /dev/null 2>&1
echo "Đã tắt các module của Apache2."

# Vô hiệu hóa và gỡ bỏ Apache2
echo "Vô hiệu hóa và gỡ bỏ Apache2..."
sudo systemctl stop apache2 > /dev/null 2>&1
sudo systemctl disable apache2 > /dev/null 2>&1
sudo apt-get remove --purge -y apache2 > /dev/null 2>&1
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get autoclean > /dev/null 2>&1
echo "Đã vô hiệu hóa và gỡ bỏ Apache2."

# Xóa các file cấu hình còn sót lại
echo "Xóa các file cấu hình còn sót lại của Apache2 và PHP..."
sudo rm -rf /etc/apache2 /etc/php${PHP_VERSION} /var/lib/apache2 /var/log/apache2 /var/log/php${PHP_VERSION} /etc/apache2/sites-available/000-default.conf
echo "Đã xóa các file cấu hình còn sót lại."

echo "Hoàn tất quá trình gỡ bỏ các gói và cấu hình."
