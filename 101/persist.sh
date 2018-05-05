# Filename:                persist.sh
# Time-stamp:              <2018-05-04 20:38:04 fultonj> 
# -------------------------------------------------------
source ~/stackrc
WORKBOOK_DEV=1
if [[ $WORKBOOK_DEV -gt 0 ]]; then
    WORKBOOK=/home/stack/mistral/101/persist.yaml
    if [[ ! -e $WORKBOOK ]]; then
	echo "$WORKBOOK does not exist (see init.sh)"
	exit 1
    fi
    EXISTS=$(mistral workbook-list | grep persist | wc -l)
    if [[ $EXISTS -gt 0 ]]; then
	mistral workbook-update $WORKBOOK
    else
	mistral workbook-create $WORKBOOK
    fi
fi

WORKFLOW=persist.yaml.persist_fetch
mistral execution-create $WORKFLOW > /tmp/$WORKFLOW
UUID=$(grep " ID " /tmp/$WORKFLOW | head -1 | awk {'print $4'})
# UUID=$(mistral execution-list | grep $WORKFLOW | awk {'print $2'} | tail -1)
if [ -z $UUID ]; then
    echo "Error: unable to find UUID. Exixting."
    exit 1
fi

mistral task-list $UUID

echo "wait 10 seconds"
for i in `seq 1 10`; do echo -n "$i "; sleep 1; done
echo ""

for TASK_ID in $(mistral task-list $UUID | awk {'print $2'} | egrep -v 'ID|^$'); do
    echo $TASK_ID
    mistral task-get $TASK_ID > /tmp/$UUID
    if [[ $(grep make_fetch_directory /tmp/$UUID | wc -l) -gt 0 ]]; then
	TMP=$(mistral task-get-result $TASK_ID | jq .path | sed s/\"//g)
    fi
    cat /tmp/$UUID
    #mistral task-get-result $TASK_ID | jq . | sed -e 's/\\n/\n/g' -e 's/\\"/"/g'
done
rm /tmp/$UUID

ls -ld $TMP
sudo ls -l $TMP
sudo rm -rfv $TMP

openstack container list
openstack container show ceph_ansible_fetch_dir
openstack object list ceph_ansible_fetch_dir

echo "Deleting swift container: ceph_ansible_fetch_dir"
openstack container delete ceph_ansible_fetch_dir
