#!/usr/bin/env bash

FORK=0
HACK=1

if [ $FORK -eq 1 ]; then
    # (OLD) use fork given https://github.com/d0ugal/mistral-ansible-actions/pull/1
    git clone https://github.com/fultonj/mistral-ansible-actions.git
    sudo rm -Rf /usr/lib/python2.7/site-packages/mistral_ansible*
    pushd mistral-ansible-actions
    sudo python setup.py install
    popd
else
    sudo yum install -y python-pip
    sudo pip install mistral-ansible-actions;
fi    
sudo mistral-db-manage populate;
sudo systemctl restart openstack-mistral*;
mistral action-list | grep ansible

echo "Try these:"
echo "  mistral action-get ansible"
echo "  mistral action-get ansible-playbook"

if [ $HACK -eq 1 ]; then
    # use this workaround for now
    id mistral
    if [ ! -d /home/mistral ]; then
	sudo mkdir /home/mistral
    fi
    sudo chown mistral:mistral /home/mistral/
    sudo cp -r ~/.ssh/ /home/mistral/
    sudo chown -R mistral:mistral /home/mistral/.ssh/
fi
