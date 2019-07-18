#!/bin/bash
apt -y update
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Deployed via Terraform by ${prefix} - `hostname`</h1>" | sudo tee /var/www/html/index.html

# From https://github.com/phanclan/terraform-guides/blob/master/infrastructure-as-code/hashistack/templates/install-base.sh.tpl
apt install -qq -y wget unzip dnsutils ruby rubygems ntp git nodejs npm nginx
systemctl start ntp.service
systemctl enable ntp.service
echo "Disable reverse dns lookup in SSH"
sudo sh -c 'echo "\nUseDNS no" >> /etc/ssh/sshd_config'
sudo service ssh restart