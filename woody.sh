#!/bin/bash
sudo apt update
sudo apt install nginx unzip -y
cd /tmp
wget https://www.free-css.com/assets/files/free-csstemplates/download/page294/woody.zip
unzip woody.zip
sudo mv carpenter-website-template/ /var/www/html/woody