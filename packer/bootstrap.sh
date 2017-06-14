#!/bin/bash

curl -s -o /tmp/ansible-playbook https://katch-sre.s3.amazonaws.com/tools/ansible/ansible-playbook.pex
if [[ $? -ne 0 ]]; then
  echo "Error downloading ansible-playbook PEX"
  exit 1
fi

# Install OpenSSL Development files for Ansible vault
sudo yum update
sudo yum install -y openssl-devel.x86_64

sudo mv /tmp/ansible-playbook /usr/bin/ansible-playbook

sudo chmod +x /usr/bin/ansible-playbook
