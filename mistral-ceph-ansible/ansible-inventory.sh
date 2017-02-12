#!/bin/bash 
# Filename:                ansible-inventory.sh
# Description:             Builds an Ansible Inventory
# Supported Langauge(s):   GNU Bash 4.2.x
# Time-stamp:              <2017-02-11 20:18:42 jfulton> 
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

HACK=1
# if there are no mons/osds, assume they are compute/control and add alias
if [ $HACK -eq 1 ]; then
    declare -A MAP=( [osds]=computes [mons]=controls )
    for K in "${!MAP[@]}"; do
	match=$(fgrep ${MAP[$K]} /tmp/inventory -A 1 | grep 192 | wc -l)
	if [ $match -gt 0 ]; then
	    line=$(grep ${MAP[$K]} /tmp/inventory -A 1 | tail -1)
	    if [[ -n $line ]] ; then
		sed -i "/$K/d" /tmp/inventory
		echo [$K] >> /tmp/inventory
		echo $line >> /tmp/inventory
		echo "" >> /tmp/inventory
	    fi
	fi
    done
fi

sudo mv /tmp/inventory /etc/ansible/hosts

ansible all -m ping
