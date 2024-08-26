#!/bin/bash

# Thiết lập các biến
PHP_VERSION="8.1"

# Cập nhật danh sách gói
sudo apt-get update

# Cài đặt Apache2
sudo apt-get install -y apache2

# Khởi động Apache2
sudo systemctl start apache2

# Đảm bảo Apache2 khởi động cùng hệ thống
sudo systemctl enable apache2

# Kiểm tra trạng thái của Apache2
sudo systemctl status apache2

# Kích hoạt module SSL và Headers cho Apache2
sudo a2enmod ssl
sudo a2enmod headers

# Kích hoạt cấu hình mặc định SSL
sudo a2ensite default-ssl

# Kiểm tra lỗi cú pháp trong cấu hình Apache
sudo apache2ctl configtest
if sudo apache2ctl configtest | grep -q "Syntax OK"; then
    sudo systemctl restart apache2
    echo "Apache2 đã được khởi động lại thành công."
else
    echo "Có lỗi trong cấu hình Apache2. Vui lòng kiểm tra lại."
fi

# Hiển thị cấu hình Apache2 chi tiết
sudo apache2ctl -S

# Cài đặt PHP 8.1 và các module liên quan
sudo apt install -y software-properties-common
export DEBIAN_FRONTEND=noninteractive
sudo add-apt-repository -y ppa:ondrej/php

sudo apt update
sudo apt install -y php${PHP_VERSION} php${PHP_VERSION}-fpm libapache2-mod-php${PHP_VERSION} libapache2-mod-fcgid
sudo apt install -y php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-xmlrpc php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-imagick php${PHP_VERSION}-cli php${PHP_VERSION}-imap php${PHP_VERSION}-mbstring php${PHP_VERSION}-opcache php${PHP_VERSION}-soap php${PHP_VERSION}-zip php${PHP_VERSION}-intl php${PHP_VERSION}-redis php${PHP_VERSION}-apcu php${PHP_VERSION}-tidy

# Khởi động lại Apache2 sau khi cài đặt PHP 8.1
sudo systemctl restart apache2

# Kích hoạt các module cần thiết cho Apache2
sudo a2enmod proxy_fcgi setenvif

# Cấu hình Apache2 để sử dụng PHP-FPM
sudo bash -c 'cat <<EOF >> /etc/apache2/sites-available/000-default.conf
<FilesMatch \.php$>
    SetHandler "proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost/"
</FilesMatch>
EOF'

# Khởi động lại Apache2 và PHP-FPM
sudo systemctl restart apache2
sudo systemctl restart php${PHP_VERSION}-fpm

# Tạo tệp kiểm tra cấu hình PHP
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

########################
### Cài đặt Mariadb ####
########################
# Bước 1: Thêm repository MariaDB
echo "Thêm repository MariaDB..."
curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version=11.4 --skip-verify

# Bước 2: Cập nhật và cài đặt MariaDB
echo "Cập nhật danh sách gói và cài đặt MariaDB..."
sudo apt update -y
sudo apt -y install mariadb-server mariadb-client

echo "Cài đặt MariaDB đã hoàn tất."
