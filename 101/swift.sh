#!/bin/bash

CON=overcloud
OBJ=swift-rings.tar.gz

WORKFLOW=tripleo.swift_rings_backup.v1.create_swift_rings_backup_container_plan
mistral execution-create $WORKFLOW  "{\"container\":\"$CON\"}" 
UUID=$(mistral execution-list | grep $WORKFLOW | awk {'print $2'} | tail -1)
echo "Waiting for workflow to finish"
while [[ $(mistral task-list $UUID | grep RUNNING | wc -l) -gt 0 ]]; do
    sleep 2;
done
echo "Extracting URLs"
for TASK_ID in $(mistral task-list $UUID | awk {'print $2'} | egrep -v 'ID|^$'); do
    # mistral task-get $TASK_ID
    if [[ $(mistral task-get $TASK_ID | grep get_tempurl | grep -v set | wc -l) -gt 0 ]]; then
    	GET_URL=$(mistral task-get-result $TASK_ID | jq . -r) 
    	echo $GET_URL
    fi
    if [[ $(mistral task-get $TASK_ID | grep put_tempurl | grep -v set | wc -l) -gt 0 ]]; then
    	PUT_URL=$(mistral task-get-result $TASK_ID | jq . -r) 
    	echo $PUT_URL
    fi
    #mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
done
CON="$CON-swift-rings"

# echo "uploading file /tmp/foo to $CON and calling it $OBJ with swift client"
# echo "i am foo" > /tmp/foo
# swift upload $CON /tmp/foo --object-name $OBJ
# echo ""

# echo "downloading foo with swift client"
# swift download $CON $OBJ --output /tmp/foo-down
# cat /tmp/foo-down
# echo ""

RAN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

echo "Creating file $OBJ"
echo "i am bar $RAN" > $OBJ
ls -l $OBJ
cat $OBJ
echo ""

echo "uploading file $OBJ to $CON with CURL"
echo "-----"
curl -i -X PUT -T $OBJ $PUT_URL
echo "-----"
echo ""
rm -f $OBJ

echo "downloading foo with curl and tempurl"
echo "-----"
curl -i -S -X GET $GET_URL 
echo "-----"
echo ""
