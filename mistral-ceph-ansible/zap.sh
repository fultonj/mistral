#!/usr/bin/env bash
ansible osds -b -m shell -a "for d in `echo /dev/vd{b,c,d,e,f}`; do sgdisk -Z \$d; sgdisk -g \$d; done; partprobe"
