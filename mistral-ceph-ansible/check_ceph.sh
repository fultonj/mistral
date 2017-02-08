#!/usr/bin/env bash

echo " --------- ceph df --------- "
ansible mons -b -m shell -a "ceph df"
echo " --------- ceph health --------- "
ansible mons -b -m shell -a "ceph health"
echo " --------- ceph pg stat --------- "
ansible mons -b -m shell -a "ceph pg stat"

# echo " --------- Ceph images pool --------- "
# ansible mons -b -m shell -a "rbd -p images ls -l"
# echo " --------- Ceph cinder volumes pool --------- "
# ansible mons -b -m shell -a "rbd -p volumes ls -l"
