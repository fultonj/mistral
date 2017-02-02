Mistral and Ansible
===================

- These are my experiments with [mistral-ansible-actions](https://github.com/d0ugal/mistral-ansible-actions).
- I have tested them on a CentOS7 undercloud deployed by [tripleo-quickstart](https://github.com/openstack/tripleo-quickstart)
- Install mistral-ansible-actions with [init.sh](https://github.com/fultonj/mistral/tree/master/ansible/init.sh) [This does a hack to `/home/mistral` to install stack's SSH keys]
- Build the ansible inventory based on undercloud nova-list with [ansible-inventory.sh](https://github.com/fultonj/mistral/tree/master/ansible/ansible-inventory.sh)
- Create and run the workflow with [ansible-test.sh](https://github.com/fultonj/mistral/tree/master/ansible/ansible-test.sh)
- Edit [ansible-test.yaml](https://github.com/fultonj/mistral/tree/master/ansible/ansible-test.yaml) and re-run ansible-test.sh as needed
- If it works it should like the output from [ansible-test_session.txt](https://github.com/fultonj/mistral/tree/master/ansible/ansible-test_session.txt)

For the impatient
-----------------
```
ssh stack@undercloud
git clone https://github.com/fultonj/mistral.git
cd mistral/ansible
./init.sh
./ansible-inventory.sh
./ansible-test.sh
```

ToDo
----

1. Copying /home/stack/.ssh into /home/mistral is a hack
2. Copying playbooks into /tmp so mistral@undercloud can access them is a hack 
3. Build the Ansible Inventory with Mistral

The above issues could probably be solved by using the
[deployment plan](https://github.com/fultonj/mistral/tree/master/101#tripleo-deployment-plan).

