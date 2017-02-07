#!/usr/bin/env bash

source ~/stackrc

EID=$(mistral execution-list | grep -i running  | tail -1 | awk {'print $2'})
echo "mistral execution-update $EID -s ERROR"
mistral execution-update $EID -s ERROR

AEID=$(mistral action-execution-list | grep -i running | tail -1 | awk {'print $2'})
echo "mistral action-execution-update $AEID --state ERROR" 
mistral action-execution-update $AEID --state ERROR 

process=ceph
echo "killing all $process processes on all hosts"
ansible all -b -m shell -a "for pid in \$(ps axu | grep $process | grep -v grep | awk {'print \$2'}); do echo \$pid; kill \$pid; done"
