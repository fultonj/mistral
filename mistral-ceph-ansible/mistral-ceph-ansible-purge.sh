#!/usr/bin/env bash
# Filename:                mistral-ceph-ansible.sh
# Description:             prep and run ceph-ansible
# Time-stamp:              <2017-02-07 13:19:21 jfulton> 
# -------------------------------------------------------
RUN=1
WORKFLOW='mistral-ceph-ansible-purge'
# -------------------------------------------------------
if [ ! -f /tmp/ceph-ansible/purge-cluster.yml ]; then
  # workaround since this playbook expects files in parent directory
  sudo ln -s /tmp/ceph-ansible/infrastructure-playbooks/purge-cluster.yml /tmp/ceph-ansible/
fi

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

    # to make following up easier:
    echo "UUID: $UUID"
    echo "TASK_ID: $TASK_ID"
    echo $TASK_ID > TASK_ID
fi

echo "It is OK for the last task called [purge fetch directory for localhost] to fail."
echo "It is because the mistral user cannot sudo; fine by me"
