#!/bin/bash
set -x
# VAULT_VERSION=${vault_version}
# VAULT_ZIP=vault_%${VAULT_VERSION}_linux_amd64.zip
# VAULT_URL=$${URL:-https://releases.hashicorp.com/vault/%${VAULT_VERSION}/%${VAULT_ZIP}}
# VAULT_DIR=/usr/local/bin
# VAULT_PATH=%${VAULT_DIR}/vault
# VAULT_CONFIG_DIR=/etc/vault.d
# VAULT_DATA_DIR=/opt/vault/data
# VAULT_TLS_DIR=/opt/vault/tls
# VAULT_ENV_VARS=%${VAULT_CONFIG_DIR}/vault.conf
# VAULT_PROFILE_SCRIPT=/etc/profile.d/vault.sh

# From https://github.com/phanclan/terraform-guides/blob/master/infrastructure-as-code/hashistack/templates/install-base.sh.tpl
# Install vault
echo "Downloading Vault ${vault_version}" 
[ 200 -ne $(curl --write-out %%{http_code} --silent --output /tmp/${vault_zip} ${vault_url}) ] && exit 1


#curl --silent \
#  --output /tmp/vault_1.1.3_linux_amd64.zip \
#  https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip

echo "Installing Vault"
sudo unzip -o /tmp/${vault_zip} -d ${vault_dir}
sudo chmod 0755 ${vault_path}

echo "Configuring Vault ${vault_version}"
sudo mkdir -pm 0755 ${vault_config_dir} ${vault_data_dir} ${vault_tls_dir}

echo "Start vault in dev mode."
vault server -dev -dev-root-token-id=root > /tmp/vault.log 2>&1 &
sudo tee ${vault_env_vars} > /dev/null <<ENVVARS
FLAGS=-dev -dev-ha -dev-transactional -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200
ENVVARS

echo "Set Vault profile script"
sudo tee ${vault_profile_script} > /dev/null <<EOF
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
EOF

# enable mlock 
sudo setcap cap_ipc_lock=+ep ${vault_path}

echo "Complete"