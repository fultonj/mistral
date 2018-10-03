#!/bin/bash
source ~/stackrc
WORKBOOK_DEV=1
RESTORE=1

if [[ $WORKBOOK_DEV -gt 0 ]]; then
    WORKBOOK=/home/stack/mistral/101/swift-rename.yaml
    if [[ ! -e $WORKBOOK ]]; then
	echo "$WORKBOOK does not exist (see init.sh)"
	exit 1
    fi
    EXISTS=$(mistral workbook-list | grep rename.yaml | wc -l)
    if [[ $EXISTS -gt 0 ]]; then
	mistral workbook-update $WORKBOOK
    else
	mistral workbook-create $WORKBOOK
    fi

    WORKFLOW=rename.yaml.rename_fetch
    mistral execution-create $WORKFLOW > /tmp/$WORKFLOW
    UUID=$(grep " ID " /tmp/$WORKFLOW | head -1 | awk {'print $4'})
    # UUID=$(mistral execution-list | grep $WORKFLOW | awk {'print $2'} | tail -1)
    if [ -z $UUID ]; then
	echo "Error: unable to find UUID. Exixting."
	exit 1
    fi

    mistral task-list $UUID

    #N=1
    # echo "wait $N seconds"
    # for i in `seq 1 $N`; do echo -n "$i "; sleep 1; done
    # echo ""

    for TASK_ID in $(mistral task-list $UUID | awk {'print $2'} | egrep -v 'ID|^$'); do
	#echo $TASK_ID
	mistral task-get $TASK_ID > /tmp/$TASK_ID
	TASK_NAME=$(cat /tmp/$TASK_ID | grep "Name" | awk {'print $4'})
	if [[ $(echo $TASK_NAME | egrep "finish|verify_container_exists|set_vars" | wc -l) -eq 0 ]];
	then
	    echo -e "\n<!-- START --------------"
	    echo $TASK_NAME
	    cat /tmp/$TASK_ID
	    echo "get-result: "
	    mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
	    echo "get-published: "
	    mistral task-get-published $TASK_ID
	    echo -e "---- END   -------------- >"
	fi
	rm /tmp/$TASK_ID
    done
fi

if [[ $RESTORE -gt 0 ]]; then
    if [[ ! -e temporary_dir-20180831-171536.tar.gz ]]; then
	echo nothing > temporary_dir-20180831-171536.tar.gz
    fi
    echo "before..."
    swift list overcloud_ceph_ansible_fetch_dir
    echo "...changing..."
    swift delete overcloud_ceph_ansible_fetch_dir temporary_dir.tar.gz
    swift upload overcloud_ceph_ansible_fetch_dir temporary_dir-20180831-171536.tar.gz
    echo "...after"
    swift list overcloud_ceph_ansible_fetch_dir
fi
