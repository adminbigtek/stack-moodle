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
    echo -e "${YELLOW}🔄 $1${NC}"
}

# Bắt đầu cài đặt
echo_info "Bắt đầu cập nhật danh sách gói..."
sudo apt-get update -qq > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Hoàn thành cập nhật danh sách gói."
else
    echo_error "Có lỗi khi cập nhật danh sách gói."
fi
echo

echo_info "Cài đặt Apache2..."
sudo apt-get install -y apache2 -qq > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Hoàn thành cài đặt Apache2."
else
    echo_error "Có lỗi khi cài đặt Apache2."
fi
echo

echo_info "Khởi động Apache2..."
sudo systemctl start apache2 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Apache2 đã được khởi động."
else
    echo_error "Có lỗi khi khởi động Apache2."
fi
echo

echo_info "Đảm bảo Apache2 khởi động cùng hệ thống..."
sudo systemctl enable apache2 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Apache2 sẽ khởi động cùng hệ thống."
else
    echo_error "Có lỗi khi cấu hình Apache2 khởi động cùng hệ thống."
fi
echo

echo_info "Kích hoạt module SSL và Headers cho Apache2..."
sudo a2enmod ssl > /dev/null 2>&1
sudo a2enmod headers > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã kích hoạt module SSL và Headers."
else
    echo_error "Có lỗi khi kích hoạt module SSL và Headers."
fi
echo

echo_info "Kích hoạt cấu hình mặc định SSL..."
sudo a2ensite default-ssl > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã kích hoạt cấu hình mặc định SSL."
else
    echo_error "Có lỗi khi kích hoạt cấu hình mặc định SSL."
fi
echo

echo_info "Kiểm tra cấu hình Apache2..."
config_test_output=$(sudo apache2ctl configtest 2>&1)
if echo "$config_test_output" | grep -q "Syntax OK"; then
    echo_success "Cấu hình Apache2 hợp lệ."
    sudo systemctl restart apache2 > /dev/null 2>&1
    echo_success "Apache2 đã được khởi động lại thành công."
else
    echo_error "Có lỗi trong cấu hình Apache2: $config_test_output"
fi
echo

echo_info "Cài đặt PHP $PHP_VERSION và các module liên quan..."
sudo apt-get install -y software-properties-common -qq > /dev/null 2>&1
export DEBIAN_FRONTEND=noninteractive
sudo add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
sudo apt-get update -qq > /dev/null 2>&1
sudo apt-get install -y php${PHP_VERSION} php${PHP_VERSION}-fpm libapache2-mod-php${PHP_VERSION} libapache2-mod-fcgid -qq > /dev/null 2>&1
sudo apt-get install -y php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql php${PHP_VERSION}-xml php${PHP_VERSION}-xmlrpc php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-imagick php${PHP_VERSION}-cli php${PHP_VERSION}-imap php${PHP_VERSION}-mbstring php${PHP_VERSION}-opcache php${PHP_VERSION}-soap php${PHP_VERSION}-zip php${PHP_VERSION}-intl php${PHP_VERSION}-redis php${PHP_VERSION}-apcu php${PHP_VERSION}-tidy -qq > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Hoàn thành cài đặt PHP $PHP_VERSION."
else
    echo_error "Có lỗi khi cài đặt PHP $PHP_VERSION và các module liên quan."
fi
echo

echo_info "Khởi động lại Apache2 sau khi cài đặt PHP $PHP_VERSION..."
sudo systemctl restart apache2 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Apache2 đã được khởi động lại."
else
    echo_error "Có lỗi khi khởi động lại Apache2."
fi
echo

echo_info "Kích hoạt các module cần thiết cho Apache2..."
sudo a2enmod proxy_fcgi setenvif > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã kích hoạt các module cần thiết cho Apache2."
else
    echo_error "Có lỗi khi kích hoạt các module cần thiết cho Apache2."
fi
echo

echo_info "Cấu hình Apache2 để sử dụng PHP-FPM..."
sudo bash -c 'cat <<EOF >> /etc/apache2/sites-available/000-default.conf
<FilesMatch \.php$>
    SetHandler "proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost/"
</FilesMatch>
EOF' > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Đã cấu hình Apache2 để sử dụng PHP-FPM."
else
    echo_error "Có lỗi khi cấu hình Apache2 để sử dụng PHP-FPM."
fi
echo

echo_info "Khởi động lại Apache2 và PHP-FPM..."
sudo systemctl restart apache2 > /dev/null 2>&1
sudo systemctl restart php${PHP_VERSION}-fpm > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Apache2 và PHP-FPM đã được khởi động lại."
else
    echo_error "Có lỗi khi khởi động lại Apache2 và PHP-FPM."
fi
echo

echo_info "Tạo tệp kiểm tra cấu hình PHP..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo_success "Tạo tệp kiểm tra cấu hình PHP hoàn tất."
else
    echo_error "Có lỗi khi tạo tệp kiểm tra cấu hình PHP."
fi
echo

echo_success "Quá trình cài đặt hoàn tất."

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
