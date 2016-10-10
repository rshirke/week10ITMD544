#!/bin/bash

echo "Hello" > /home/ubuntu/hello.txt

sudo apt-get update -y
sudo apt-get install -y apache2

sudo systemctl enable apache2
sudo systemctl start apache2

git clone https://github.com/rshirke/boostrap-website.git
sudo mv /var/www/html/index.html /var/www/html/index1.html
sudo cp -R /boostrap-website/* /var/www/html/
#sudo cp -R /boostrap-website/js/ /var/www/html/
#sudo cp /boostrap-website/program.html /var/www/html/
#sudo cp /boostrap-website/index.html /var/www/html/


