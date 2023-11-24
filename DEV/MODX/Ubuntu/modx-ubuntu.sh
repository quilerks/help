#Ubuntu 22
# Обновляем пакеты системы
apt-get update
apt-get upgrade

#ставим nginx
apt install -y nginx

# Установка без указания версии php (можно явно указать у отдельных пакетов php7.4)
apt -y install software-properties-common
add-apt-repository ppa:ondrej/php
apt install -y php7.4-common php7.4-cli php7.4-curl php7.4-json php7.4-gd php7.4-mysql php7.4-xml php7.4-zip php7.4-fpm php7.4-mbstring php7.4-bcmath php-pear

# Ставим mariadb (он же в прошлом mysql). В инструкции было раньше 10.3
apt install -y mariadb-server-10.6

#Добавляем нового пользователя в систему, под которым будет работать наш проект
groupadd www-site
useradd -d /home/site -s /bin/bash -g www-site site
usermod -a -G www-site site
usermod -a -G sudo site
passwd site
#password abcCBA123

#прописываем конфиг для php-fpm
#не забываем поменять sitenamecom на свой сайт, например onlinerby
#не забываем поменять site-name.com на свой сайт, например onliner.by
#так же рекомендую разобраться что за настройки прописываются и скорректировать их под свой сервер и нагрузку проекта
echo "
[sitenamecom]
listen = /run/php/php-sitenamecom.sock
listen.mode = 0666
user = site
group = www-site

php_admin_value[upload_tmp_dir] = /home/site/site-name.com/tmp
php_admin_value[error_log] = /home/site/site-name.com/www/server-logs/php_errors.log;
php_admin_value[date.timezone] = Europe/Minsk
php_admin_value[post_max_size] = 512M
php_admin_value[upload_max_filesize] = 512M
php_admin_value[cgi.fix_pathinfo] = 0
php_admin_value[short_open_tag] = On
php_admin_value[memory_limit] = 512M
php_admin_value[session.gc_probability] = 1
php_admin_value[session.gc_divisor] = 100
php_admin_value[session.gc_maxlifetime] = 28800;

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 2
pm.max_spare_servers = 4
" > /etc/php/7.4/fpm/pool.d/site-name.com.conf
