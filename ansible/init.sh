#!/usr/bin/env bash

# Install https://github.com/d0ugal/mistral-ansible-actions
sudo yum install -y python-pip
sudo pip install mistral-ansible-actions;
sudo mistral-db-manage populate;
sudo systemctl restart openstack-mistral*;
mistral action-list | grep ansible
echo "Try these:"
echo "  mistral action-get ansible"
echo "  mistral action-get ansible-playbook"

id mistral
sudo mkdir /home/mistral
sudo chown mistral:mistral /home/mistral/
sudo cp -r ~/.ssh/ /home/mistral/
sudo chown -R mistral:mistral /home/mistral/.ssh/
