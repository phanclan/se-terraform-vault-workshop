#!/bin/bash
set -x
# HashiCorp
curl -s -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  &&  unzip -qqo -d /usr/local/bin/ /tmp/terraform.zip
curl -s -o /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
  &&  unzip -qqo -d /usr/local/bin/ /tmp/vault.zip
curl -s -o /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip \
  &&  unzip -qqo -d /usr/local/bin/ /tmp/consul.zip
