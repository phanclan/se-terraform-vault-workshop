#!/bin/bash
set -x
apt-get update
apt-get install -y jq unzip resolvconf make tree nginx \
  ntp \
  nodejs npm ruby rubygems
echo "<h1>You are on `hostname` - ${prefix}</h1>" | sudo tee /var/www/html/index.html
sudo sh -c 'echo "\nUseDNS no" >> /etc/ssh/sshd_config'
sudo service ssh restart