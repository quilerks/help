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
#password