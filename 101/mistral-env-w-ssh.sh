#!/usr/bin/env bash
# Filename:                mistral-env.sh
# Description:             explores-mistral-envs
# -------------------------------------------------------
source ~/stackrc
MKENV=1
RUN=1

if [[ $MKENV -eq 1 ]]; then 
    ENV=my_env
    EXISTS=$(mistral environment-list | grep $ENV | wc -l)
    if [[ $EXISTS -gt 0 ]]; then
	mistral environment-update -f yaml env.yaml
    else
	mistral environment-create -f yaml env.yaml
    fi
fi

if [[ $RUN -eq 1 ]]; then 
    WORKFLOW=wf
    EXISTS=$(mistral workflow-list | grep $WORKFLOW | wc -l)
    if [[ $EXISTS -gt 0 ]]; then
	mistral workflow-update mistral-env-w-ssh.yaml
    else
	mistral workflow-create mistral-env-w-ssh.yaml
    fi
    mistral execution-create $WORKFLOW '' '{"env": "my_env"}'
    UUID=$(mistral execution-list | grep $WORKFLOW | awk {'print $2'} | tail -1)
    if [ -z $UUID ]; then
	echo "Error: unable to find UUID. Exixting."
	exit 1
    fi
    for TASK_ID in $(mistral task-list $UUID | grep show | awk {'print $2'} | egrep -v 'ID|^$'); do
	echo $TASK_ID
	mistral task-get $TASK_ID
	mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
    done
fi
