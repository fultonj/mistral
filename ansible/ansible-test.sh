#!/usr/bin/env bash

WORKFLOW='ansible-test'

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
mistral execution-get-output $UUID
