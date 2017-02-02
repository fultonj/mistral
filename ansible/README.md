Mistral and Ansible
===================

- These are my experiments with [mistral-ansible-actions](https://github.com/d0ugal/mistral-ansible-actions).
- I have tested them on a CentOS7 undercloud deployed by [tripleo-quickstart](https://github.com/openstack/tripleo-quickstart)
- Install mistral-ansible-actions with [init.sh](https://github.com/fultonj/mistral/tree/master/ansible/init.sh) [This does a hack to `/home/mistral` to install stack's SSH keys]
- Build the ansible inventory based on undercloud nova-list with [ansible-inventory.sh](https://github.com/fultonj/mistral/tree/master/ansible/ansible-inventory.sh)
- Create and run the workflow with [ansible-test.sh](https://github.com/fultonj/mistral/tree/master/ansible/ansible-test.sh)
- Edit [ansible-test.yaml](https://github.com/fultonj/mistral/tree/master/ansible/ansible-test.yaml) and re-run ansible-test.sh as needed
- If it works it should like the output from [ansible-test_session.txt](https://github.com/fultonj/mistral/tree/master/ansible/ansible-test_tession.txt.yaml)

For the impatient
-----------------
```
./init.sh
./ansible-inventory.sh
./ansible-test.sh
```
