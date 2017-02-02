#!/usr/bin/env bash

source ~/stackrc
EXISTS=$(mistral workflow-list | grep ansible-test | wc -l)
if [[ $EXISTS -gt 0 ]]; then
   mistral workflow-update ansible-test.yaml
else
   mistral workflow-create ansible-test.yaml    
fi
mistral execution-create ansible-test
UUID=$(mistral execution-list | grep ansible-test | awk {'print $2'} | tail -1)
mistral execution-get $UUID
mistral execution-get-output $UUID
