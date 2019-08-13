#!/bin/bash
set -x
apt-get update
apt-get install -y jq unzip resolvconf make tree nginx \
  ntp \
  nodejs npm ruby rubygems
echo "<h1>You are on `hostname`</h1>" | sudo tee /var/www/html/index.html

# Docker
apt-get -y install apt-transport-https ca-certificates curl software-properties-common 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker vagrant
sudo curl -sL \
  "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
