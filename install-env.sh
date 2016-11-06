#!/bin/bash
sudo apt-get update
echo "Installing  git apache2 php php-curl php-mysql package"
echo
sudo apt-get install -y git apache2 php php-curl php-mysql php7.0-xml
echo "Installing libapache2-mod-php"
echo
sudo apt-get install libapache2-mod-php7.0
echo "Downloading git repo of week-10-Cloud-544"
sudo git clone https://github.com/rshirke/week10ITMD544.git
echo "Installing composer package"
export COMPOSER_HOME=/root && /usr/bin/composer.phar self-update 1.0.0-alpha11
curl -sS https://getcomposer.org/installer | php
echo "Download aws sdk for php"
php composer.phar require aws/aws-sdk-php
echo "Start Apache2 Service"
sudo service apache2 restart
echo "Copying web pages and resources to /var/www/html path"
sudo cp -rp /week10ITMD544/switchonarex.png /var/www/html/
sudo cp -rp /vendor /var/www/html/
sudo cp -rp /week10ITMD544/index.php /var/www/html/
echo "Install env script completed"
