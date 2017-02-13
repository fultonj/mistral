#!/usr/bin/env bash

if [ ! -d /home/stack/oooq ]; then
    echo "/home/stack/oooq is missing please install with:"
    echo "git clone https://github.com/fultonj/oooq.git /home/stack/oooq"
fi

if [ ! -d /home/stack/mistral/mistral-ceph-ansible ]; then
    echo "/home/stack/mistral/mistral-ceph-ansible is missing please install with:"
    echo "git clone https://github.com/fultonj/mistral.git /home/stack/mistral"
fi

echo "Install OpenStack"
date 
pushd /home/stack/oooq
bash deploy-mistral-ceph-hci.sh
popd

echo "Install Ceph with Mistral/ceph-ansible"
date
pushd /home/stack/mistral/mistral-ceph-ansible
bash mistral-ceph-ansible.sh
echo "Restart OpenStack services which use Ceph"
date
bash connect_osp_ceph.sh
echo "Test connection between Ceph and OpenStack"
date
bash sanity-check.sh 
popd
