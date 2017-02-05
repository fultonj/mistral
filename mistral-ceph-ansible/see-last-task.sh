#!/usr/bin/env bash
TASK_ID=$(cat TASK_ID)
mistral task-list | tail -2 | head -1
#mistral task-get $TASK_ID
mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
