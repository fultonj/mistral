#!/bin/bash 
# Filename:                ansible-inventory.sh
# Description:             Builds an Ansible Inventory
# Supported Langauge(s):   GNU Bash 4.2.x
# Time-stamp:              <2017-02-04 12:45:55 jfulton> 
# -------------------------------------------------------
echo "(re)building ansbile inventory"
source ~/stackrc

cat /dev/null > /tmp/inventory

declare -a TYPES
TYPES=(osd mon compute control)

for type in ${TYPES[@]}; do
    sec="[$type" 
    sec+="s]"
    echo $sec >> /tmp/inventory
    for server in $(nova list | grep ACTIVE | awk {'print $4'}); do
	if [[ $server == *"$type"* ]]; then
	    ip=$(nova list | grep $server | awk {'print $12'} | sed s/ctlplane=//g)
	    echo "$ip ansible_ssh_user=heat-admin" >> /tmp/inventory
	fi
    done
    echo "" >> /tmp/inventory
done

sudo mv /tmp/inventory /etc/ansible/hosts

ansible all -m ping
