#!/usr/bin/env bash

WORKFLOW='ansible-test'
date > /tmp/file.txt
cp -f hello_playbook.yaml /tmp/

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
# mistral execution-get-output $UUID
