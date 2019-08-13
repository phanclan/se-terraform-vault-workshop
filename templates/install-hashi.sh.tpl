#!/bin/bash
set -x
# HashiCorp
curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  &&  unzip -qqo -d /usr/local/bin/ /tmp/terraform.zip
curl -s -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
  &&  unzip -qqo -d /usr/local/bin/ /tmp/vault.zip
curl -s -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
  &&  unzip -qqo -d /usr/local/bin/ /tmp/consul.zip

# Install vault
mkdir -pm /etc/vault.d /opt/vault/data /opt/vault/tls
export VAULT_ADDR='http://127.0.0.1:8200'
echo "Start vault in dev mode."
vault server -dev -dev-root-token-id=root > /tmp/vault.log 2>&1 &
# enable mlock 
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

echo "Set Vault profile script"
PROFILE_SCRIPT=/etc/profile.d/vault.sh
sudo tee $PROFILE_SCRIPT > /dev/null <<EOF
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
EOF