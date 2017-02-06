Mistral triggering Ceph-Ansible POC
===================================

What?
-----

The following first goal of the project has been accomplished: 

- Use TripleO to stand up an Overlcoud (`openstack overcloud deploy ...`)
- Deploy overcloud nodes [without OpenStack services](https://github.com/fultonj/oooq/commit/2e2635f8cae347013737a89341b2cca24b68c28c)
- Use Mistral to trigger Ceph-Ansible to install Ceph on the Overcloud nodes without OpenStack services

To see how it looks when run see [session1.txt](https://github.com/fultonj/mistral/blob/master/mistral-ceph-ansible/session1.txt).

Why? 
----

Suppose I then do the following in subsequent goals: 

- [Use OS::Mistral::WorflowExecution](https://review.openstack.org/#/c/267770) to start the workflow so all I need to do is `openstack overcloud deploy ...` (Goal2)
- Use [ceph-ansible docker](https://github.com/ceph/ceph-ansible/tree/master/roles/ceph-docker-common) to deploy Ceph in containers
- Use [Containerized Compute](https://access.redhat.com/documentation/en/red-hat-openstack-platform/10/single/advanced-overcloud-customization/#sect-Configuring_Containerized_Compute_Nodes)
- Use [External Ceph](https://access.redhat.com/documentation/en/red-hat-openstack-platform/10/single/red-hat-ceph-storage-for-the-overcloud#integration) to make the overcloud talk to the CephCluster stood up on overcloud nodes without OpenStack services.

Then all I would need to do is insert [Tendrl](https://github.com/tendrl/) in between Mistral and Ceph-Ansible and I would have implemented the main goal of the spec [Integrate TripleO with Tendrl for External Storage Deployment/Management](https://review.openstack.org/#/c/387631).

Assuming the the controller portion of the spec [Deploying TripleO in Containers](https://specs.openstack.org/openstack/tripleo-specs/specs/ocata/containerize-tripleo-overcloud.html)
 is finished, then I could converge them as follows:
 
- ContainerHost{1,2,3}: 2 containers: CephMon and OpenStackController
- ContainerHost{4..N}: 2 containers: NovaCompute and CephOSD

In between the above, once Goal2 is achieved is working, I could at
least provide a dev environment for a Hackthon between TripleO'ers and
Tendrl'ers where we have TripleO standing up a Ceph Cluster not
managed by TripleO's Puppet but by something more hands-off
like a Mistral workflow. We could then work on inserting a different 
Mistral workflow which calls Tendrl instead of ceph-ansible But while 
is working is happening we would have a working example to reference
and we would be inserting into an already working larger system.

Goal1 How?
----------

- Set up TripleO-quickstart undercloud (works-for-me via [master.sh](https://github.com/fultonj/oooq/blob/master/master.sh))
- Deploy juice-boxes (works-for-me via [deploy-jeos.sh](https://github.com/fultonj/oooq/blob/master/deploy-jeos.sh))
- Run [mistral-ceph-ansible.sh](https://github.com/fultonj/mistral/blob/master/mistral-ceph-ansible/mistral-ceph-ansible.sh) which executes the workflow [mistral-ceph-ansible.yaml](https://github.com/fultonj/mistral/blob/master/mistral-ceph-ansible/mistral-ceph-ansible.yaml)

I have verified that the above works in my virtual environment. The
run takes less than 30 minutes. An example is in [session1.txt](https://github.com/fultonj/mistral/blob/master/mistral-ceph-ansible/session1.txt).

