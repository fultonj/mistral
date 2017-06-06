#!/usr/bin/env bash
# Filename:                mistral-env.sh
# Description:             explores-mistral-envs
# -------------------------------------------------------
source ~/stackrc
HELP=0
MKENV=1
RUN=1
if [[ $HELP -eq 1 ]]; then 
    for cmd in $(mistral --help | egrep environment | awk {'print $1'}); do 
	echo -e "$cmd\n<---"
	mistral $cmd; 
	echo -e "---> \n"
    done
fi

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
	mistral workflow-update mistral-env.yaml
    else
	mistral workflow-create mistral-env.yaml
    fi
    mistral execution-create $WORKFLOW '' '{"env": "my_env"}'
    UUID=$(mistral execution-list | grep $WORKFLOW | awk {'print $2'} | tail -1)
    if [ -z $UUID ]; then
	echo "Error: unable to find UUID. Exixting."
	exit 1
    fi
    TASK_ID=$(mistral task-list $UUID | awk {'print $2'} | egrep -v 'ID|^$' | tail -1)
    if [ -z $TASK_ID ]; then
	echo "Error: unable to find TASK_ID. Exixting."
	exit 1
    fi
    mistral task-get $TASK_ID
    mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
    export UUID
    export TASK_ID
fi
