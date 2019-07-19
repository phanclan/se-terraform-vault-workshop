#!/bin/bash
apt -y update
apt install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<h1>Deployed via Terraform by ${prefix} - `hostname`</h1>" | sudo tee /var/www/html/index.html

#VAULT_VERSION=

# From https://github.com/phanclan/terraform-guides/blob/master/infrastructure-as-code/hashistack/templates/install-base.sh.tpl
apt install -qq -y wget unzip dnsutils ruby rubygems ntp git nodejs npm nginx
systemctl start ntp.service
systemctl enable ntp.service
echo "Disable reverse dns lookup in SSH"
sudo sh -c 'echo "\nUseDNS no" >> /etc/ssh/sshd_config'
sudo service ssh restart

# Install vault
mkdir -pm /etc/vault.d /opt/vault/data /opt/vault/tls
export VAULT_ADDR='http://127.0.0.1:8200'
curl --write-out %{http_code} --silent \
  --output /tmp/vault_1.1.3_linux_amd64.zip \
  https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip
sudo unzip -o /tmp/vault_1.1.3_linux_amd64.zip -d /usr/local/bin
echo "Start vault in dev mode."
vault server -dev -dev-root-token-id=root > /tmp/vault.log 2>&1 &

echo "Set Vault profile script"
PROFILE_SCRIPT=/etc/profile.d/vault.sh
sudo tee $PROFILE_SCRIPT > /dev/null <<EOF
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
EOF
# enable mlock 
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault