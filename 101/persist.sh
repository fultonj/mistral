# Filename:                persist.sh
# Time-stamp:              <2018-05-11 00:32:50 fultonj> 
# -------------------------------------------------------
source ~/stackrc
ACTIONS_DEV=0
WORKBOOK_DEV=1
# -------------------------------------------------------
if [[ $ACTIONS_DEV -gt 0 ]]; then
    echo "update mistral actions python"
    pushd /home/stack/tripleo-common
    sudo rm -Rf /usr/lib/python2.7/site-packages/tripleo_common*
    sudo python setup.py install

    sudo systemctl restart openstack-mistral-executor
    sudo systemctl restart openstack-mistral-engine
    # this loads the actions via entrypoints
    sudo mistral-db-manage populate
    # make sure the new actions got loaded

    mistral action-list | grep save_temp_dir_to_swift
    mistral action-get tripleo.files.save_temp_dir_to_swift
    mistral action-get tripleo.files.restore_temp_dir_from_swift    
    mistral action-get tripleo.files.remove_temp_dir
    popd
fi

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

echo "Was tempdir correctly populated?"
ls -ld $TMP
sudo ls -l $TMP
#sudo rm -rfv $TMP

exit 0
echo "Is fetch dir container in swift?"
openstack container list
openstack container show ceph_ansible_fetch_dir
openstack object list ceph_ansible_fetch_dir
OBJ=$(openstack object list ceph_ansible_fetch_dir -f value)

exit 0
echo "Testing $OBJ from contianer"
mkdir fetch_test
pushd fetch_test
openstack object save ceph_ansible_fetch_dir $OBJ
tar xf $OBJ
ls
for f in `ls | grep -v tar.gz`; do echo "file: $f"; echo "---"; cat $f; echo "---"; done
echo ""
popd
echo "Delete local downloaded tarball"
rm -rfv fetch_test

#echo "Delete swift container: ceph_ansible_fetch_dir"
#openstack object delete ceph_ansible_fetch_dir $OBJ
#openstack container delete ceph_ansible_fetch_dir
