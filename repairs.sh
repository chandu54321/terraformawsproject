#!/bin/bash
sudo apt update
sudo apt install nginx unzip -y
cd /tmp
wget https://www.free-css.com/assets/files/free-csstemplates/download/page296/inance.zip
unzip inance.zip
sudo mv inance-html/ /var/www/html/repairs