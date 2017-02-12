#!/usr/bin/env bash

OVERALL=1
CINDER=0
GLANCE=0

source ~/overcloudrc
if [ $OVERALL -eq 1 ]; then   
    echo " --------- ceph df --------- "
    ansible mons -b -m shell -a "ceph df"
    echo " --------- ceph health --------- "
    ansible mons -b -m shell -a "ceph health"
    echo " --------- ceph pg stat --------- "
    ansible mons -b -m shell -a "ceph pg stat"
fi

if [ $CINDER -eq 1 ]; then
    echo " --------- Ceph cinder volumes pool --------- "
    ansible mons -b -m shell -a "rbd -p volumes ls -l"
    openstack volume list

    echo "Creating 20G Cinder volume"
    openstack volume create --size 20 test-volume
    sleep 30 

    echo "Listing Cinder Ceph Pool and Volume List"
    openstack volume list
    ansible $mon -b -m shell -a "rbd -p volumes ls -l"
fi

if [ $GLANCE -eq 1 ]; then
    img=cirros-0.3.4-x86_64-disk.img
    raw=$(echo $img | sed s/img/raw/g)
    url=http://download.cirros-cloud.net/0.3.4/$img
    if [ ! -f $raw ]; then
	if [ ! -f $img ]; then
	    echo "Could not find qemu image $img; downloading a copy."
	    curl -# $url > $img
	fi
	echo "Could not find raw image $raw; converting."
	qemu-img convert -f qcow2 -O raw $img $raw
    fi

    echo " --------- Ceph images pool --------- "
    echo "Listing Glance Ceph Pool and Image List"
    ansible mons -b -m shell -a "rbd -p images ls -l"
    openstack image list

    echo "Importing $raw image into Glance"
    openstack image create cirros --disk-format=raw --container-format=bare < $raw
    if [ ! $? -eq 0 ]; then 
        echo "Could not import $raw image. Aborting"; 
        exit 1;
    fi

    echo "Listing Glance Ceph Pool and Image List"
    ansible $mon -b -m shell -a "rbd -p images ls -l"
    openstack image list
fi
