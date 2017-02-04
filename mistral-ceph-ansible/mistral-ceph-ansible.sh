#!/usr/bin/env bash
# Filename:                mistral-ceph-ansible.sh
# Description:             prep and run ceph-ansible
# Time-stamp:              <2017-02-04 16:16:49 jfulton> 
# -------------------------------------------------------
PREP=1
RUN=1
WORKFLOW='mistral-ceph-ansible'
# -------------------------------------------------------
if [ $PREP -eq 1 ]; then
    if [ ! -d ceph-ansible ]; then
	echo "ceph-ansible is missing please run init.sh"
	exit 1
    fi
    if [ -d /tmp/ceph-ansible ]; then
	rm -rf /tmp/ceph-ansible
    fi
    cp -r ceph-ansible /tmp/
    cp /tmp/ceph-ansible/site.yml.sample /tmp/ceph-ansible/site.yml
    cp /tmp/ceph-ansible/group_vars/mons.yml.sample /tmp/ceph-ansible/group_vars/mons.yml
    # copy in all.yml and osds.yml
    cp group_vars/* /tmp/ceph-ansible/group_vars/
    sudo chown -R mistral:mistral /tmp/ceph-ansible/
fi
# -------------------------------------------------------
if [ $RUN -eq 1 ]; then
    source ~/stackrc
    EXISTS=$(mistral workflow-list | grep $WORKFLOW | wc -l)
    if [[ $EXISTS -gt 0 ]]; then
	mistral workflow-update $WORKFLOW.yaml
    else
	mistral workflow-create $WORKFLOW.yaml    
    fi
    mistral execution-create $WORKFLOW
    UUID=$(mistral execution-list | grep $WORKFLOW | awk {'print $2'} | tail -1)
    mistral execution-get $UUID
    echo "Getting output for the following tasks in workflow $WORKFLOW"
    mistral task-list $UUID
    for TASK_ID in $(mistral task-list $UUID | awk {'print $2'} | egrep -v 'ID|^$'); do
	mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
    done
fi
