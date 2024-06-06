#Ubuntu 22
# Обновляем пакеты системы
apt-get update
apt-get -y upgrade

#ставим nginx
apt install -y nginx

# Установка без указания версии php (можно явно указать у отдельных пакетов php7.4)
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php
apt install -y php7.4-common php7.4-cli php7.4-curl php7.4-json php7.4-gd php7.4-mysql php7.4-xml php7.4-zip php7.4-fpm php7.4-mbstring php7.4-bcmath php7.4-intl php-pear

# Ставим mariadb (он же в прошлом mysql). В инструкции было раньше 10.3 -> 10.6 -> 10.11
apt install -y mariadb-server-10.6
apt install -y mariadb-server

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
listen = /run/php/php-site-name.com.sock
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

# подготовка каталогов, которые мы использовали в настройках
mkdir /home/site
mkdir /home/site/site-name.com
mkdir /home/site/site-name.com/tmp
mkdir /home/site/site-name.com/www
mkdir /home/site/site-name.com/www/server-logs

#Конфигурирование nginx
#Открываем файл /etc/nginx/nginx.conf и в секции http дописываем:
sed '/http {/a\
    client_max_body_size 512m;' /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp
cat /etc/nginx/nginx.conf.tmp > /etc/nginx/nginx.conf
rm /etc/nginx/nginx.conf.tmp

#Для запрета обращений к сайту по IP Создаем файл /etc/nginx/conf.d/default.conf
echo "server {
    listen [::]:80;
    listen      80;
    server_name \"\";
    return      444;
}" > /etc/nginx/sites-available/00-default.conf

#удаляем стандартные конфиги, может быть default может и default.conf
rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

#делаем символическую ссылку
ln -s /etc/nginx/sites-available/00-default.conf /etc/nginx/sites-enabled/00-default.conf

#Создаем файл /etc/nginx/conf.d/site-name.com.conf (не важно, какое имя, главное - расширение .conf).
echo '' > /etc/nginx/sites-available/01-site-name.com.conf

#делаем символическую ссылку
ln -s /etc/nginx/sites-available/01-site-name.com.conf /etc/nginx/sites-enabled/01-site-name.com.conf

#Пишем для сайта следующий конфиг:
nano /etc/nginx/sites-available/01-site-name.com.conf

server {
    server_name site-name.com www.site-name.com;
    listen [::]:443 ssl;
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/site-name.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/site-name.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    access_log /home/site/site-name.com/www/server-logs/nginx_access.log;
    error_log /home/site/site-name.com/www/server-logs/nginx_error.log;
    root /home/site/site-name.com/www;
    index index.php;
    charset off;
    ssi on;
    gzip on;
    gzip_proxied any;
    gzip_comp_level 9;
    gzip_disable "msie6";
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;
    add_header Strict-Transport-Security "max-age=31536000;";
    location ~ ^/core/.* {
        deny all;
        return 403;
    }
    location / {
        try_files $uri $uri/ @rewrite;
    }
    location @rewrite {
        rewrite ^/(.*)$ /index.php?q=$1;
    }
    location ~ \.php$ {
        try_files  $uri =404;
        include fastcgi_params;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php-site-name.com.sock;
        #https://highload.today/oshibka-nginx-upstream-sent-too-big-header/
        #fastcgi_buffer_size   128k;
        #fastcgi_buffers   4 256k;
        #fastcgi_busy_buffers_size   256k;
    }
    location ~* \.(jpg|jpeg|gif|png|css|js|woff|woff2|ttf|eot|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|tar|wav|bmp|rtf|swf|ico|flv|txt|docx|xlsx|webp|svg)$ {
        try_files $uri @rewrite;
        access_log off;
        expires 100d;
        break;
    }
    location ~ /\.ht {
        deny all;
    }
    #редирект 301 с https://www.site-name.com на https://site-name.com
    if ($host = "www.site-name.com") {
        return 301 https://site-name.com$request_uri;
    }
    #редирект для двойных и более слэшей на https://site-name.com/
    if ($request_uri ~ "//") {
        return 301 https://site-name.com$uri;
    }
    #защита, когда на серваке несколько проектов. Указываем свой IP вместо 8.8.8.8
    if ($host = "8.8.8.8") {
        return 301 https://site-name.com$uri;
    }
}
server {
    listen [::]:80;
    listen 80;
    server_name site-name.com www.site-name.com;
    access_log /home/site/site-name.com/www/server-logs/nginx_access.log;
    error_log /home/site/site-name.com/www/server-logs/nginx_error.log;
    root /home/site/site-name.com/www;
    index index.php;
    #редирект 301 с http://site-name.com на https://site-name.com
    if ($host = "site-name.com") {
        return 301 https://site-name.com$request_uri;
    }
    #редирект 301 с http://www.site-name.com на https://site-name.com
    if ($host = "www.site-name.com") {
        return 301 https://site-name.com$request_uri;
    }
    #редирект для двойных и более слэшей на https://site-name.com/
    if ($request_uri ~ "//") {
        return 301 https://site-name.com$uri;
    }
    #защита, когда на серваке несколько проектов. Указываем свой IP вместо 8.8.8.8
    if ($host = "8.8.8.8") {
        return 301 https://site-name.com$uri;
    }
    return 301 https://$host$request_uri;
}

#Устанавливаем certbot для бесплатных сертификаторв
apt install -y certbot
#устанавливаем плагин для certbot
apt install -y python3-certbot-nginx
#генерируем сертификаты
certbot --nginx

#либо вручную подоменно
systemctl stop nginx
#тут выбираем standalone
certbot certonly -d site-name.com
systemctl start nginx

#ставим на cron обновление сертификата. Редактируем
nano /etc/cron.d/certbot
#и вставляем такое
0 */12 * * * root certbot -q renew --nginx

#ручная перегенерация сертификатов в последующем
certbot renew --nginx

#конфигурирования mysql
#Открываем файл /etc/mysql/my.cnf и в секции [mysqld] в конце дописываем:
nano /etc/mysql/my.cnf

[mysqld]
sql_mode=NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

#далее создадим БД для сайта
mysql
# Чтобы создать пользователя и БД: Выполнить под root-пользователем mysql
CREATE DATABASE IF NOT EXISTS change_db_name;
CREATE USER 'change_db_user'@'localhost' IDENTIFIED BY 'change_db_password';
GRANT USAGE ON *.* TO 'change_db_user'@'localhost' IDENTIFIED BY 'change_db_password' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
GRANT ALL PRIVILEGES ON `change_db_name`.* TO 'change_db_user'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit;

#установил mysqltuner для последующих корректировок mysql настроек через /etc/mysql/my.cnf
apt install -y mysqltuner

#устанавливаем
apt install -y zip

#редактируем. Я добавляю server-custom.tld
nano /etc/hostname
#редактируем: 127.0.0.1 localhost server-custom.tld
nano /etc/hosts
#меняем командой
hostname server-custom.tld
#устанавливаем
apt install -y sendmail
#настраиваем. Все время отвечаем да - Y
sendmailconfig
#корректируем. Вставляем это: sendmail_path = /usr/sbin/sendmail -t -i
nano /etc/php/7.4/fpm/php.ini
#дальше конечно лучше всего

#перезагружаем сервисы
systemctl restart php7.4-fpm
systemctl restart nginx
systemctl restart mysql
systemctl restart sendmail
#а лучше вообще ребутнуть весь сервак
reboot

#бэкапимся на старом серваке еще до настройки текущего, если есть командная строка с необходимыми правами.
#сперва чистим таблицу сессий. Бывает крайне огромной в десятки ГБ.
mysql
#выбираем свою базу
use db_name;
#очищаем таблицу сессий. У каждого проекта свой перфикс, не забывайте.
truncate prefix_session;
exit;

#создаем архивы на СТАРОМ серваке. need_folder/ - это корневая папка проекта.
#Может быть www/ или public_html/ или site-name.com/ или другое название
cd need_folder/
#удаляем папку кэша. И другие при необходимости
rm -rf core/cache/
#создаем дамп базы данных. Я обычно еще использую дату в имени файла, чтобы проще было в последующем идентифицировать
mysqldump -uuser_db -p db_name > site_name_25112023.sql
cd ..
zip -r site_name_25112023.zip site-name.com/ -x "site-name.com/core/cache/*" "site-name.com/add_folder/*"
#перемещаем для последующего скачивания
mv site_name_25112023.zip site-name.com/

#выкачиваем файлы сайта и БД (может быть всё в одном архиве) на НОВОМ серваке. Я делаю обычно так.
cd /home/site/site-name.com/www/
wget --no-check-certificate -erobots=off https://site-name-two.com/site_name_25112023.zip
wget --no-check-certificate -erobots=off https://site-name-two.com/site_name_25112023.sql

#далее
unzip site_name_25112023.zip
cd site-name.com/
mv * ../
mv .* ../
cd ../
rm -rf site-name.com/
cd ../
chown site:www-site -R www/
find www/ -type d -exec chmod 755 {} \;
find www/ -type f -exec chmod 644 {} \;
cd www/

mysql -uchange_db_user -p change_db_name < site_name_25112023.sql

#не забываем отредактировать конфиги
nano /home/site/site-name.com/www/config.core.php
nano /home/site/site-name.com/www/manager/config.core.php
nano /home/site/site-name.com/www/connectors/config.core.php
nano /home/site/site-name.com/www/core/config/config.inc.php

#не будет лишним
mysqlcheck -A -a
mysqlcheck -A -c
mysqlcheck -A -r
mysqlcheck -A -o
