#!/bin/bash 
# Filename:                ansible-inventory.sh
# Description:             Builds an Ansible Inventory
# Supported Langauge(s):   GNU Bash 4.2.x
# Time-stamp:              <2017-02-01 17:37:55 jfulton> 
# -------------------------------------------------------
echo "(re)building ansbile inventory"
source ~/stackrc
rm /tmp/compute_ips
rm /tmp/control_ips
for ip in $(nova list | grep compute | awk {'print $12'} | grep ctlplane | sed s/ctlplane=//g); do echo "$ip ansible_ssh_user=heat-admin" >> /tmp/compute_ips; done
for ip in $(nova list | grep ceph | awk {'print $12'} | grep ctlplane | sed s/ctlplane=//g); do echo "$ip ansible_ssh_user=heat-admin" >> /tmp/ceph_ips; done
for ip in $(nova list | grep control | awk {'print $12'} | grep ctlplane | sed s/ctlplane=//g); do echo "$ip ansible_ssh_user=heat-admin" >> /tmp/control_ips; done

sudo sh -c "cat /dev/null > /etc/ansible/hosts"
sudo sh -c "echo \"[mons]\" >> /etc/ansible/hosts"
sudo sh -c "cat /tmp/control_ips >> /etc/ansible/hosts"
sudo sh -c "echo \"\" >> /etc/ansible/hosts"
sudo sh -c "echo \"[osds]\" >> /etc/ansible/hosts"
sudo sh -c "cat /tmp/ceph_ips >> /etc/ansible/hosts"
sudo sh -c "echo \"\" >> /etc/ansible/hosts"
sudo sh -c "echo \"[computes]\" >> /etc/ansible/hosts"
sudo sh -c "cat /tmp/compute_ips >> /etc/ansible/hosts"
sudo sh -c "echo \"\" >> /etc/ansible/hosts"

ansible mons -m ping
ansible osds -m ping
ansible computes -m ping
