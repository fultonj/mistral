Mistral 101
===========

This is my crash-course in Mistral for people familiar with
TripleO and Ansible. It's basically an aggregation of parts of the
[upstream documenation](http://docs.openstack.org/developer/mistral/), 
[d0ugal's blog](http://www.dougalmatthews.com/), and another 
[crash-course](https://etherpad.openstack.org/p/tripleo-mistral-crash-course-december-2016).

Installation
------------
- Install an undercloud (e.g. use [tripleo-quickstart](http://docs.openstack.org/developer/tripleo-quickstart) or [OSPd](https://access.redhat.com/documentation/en/red-hat-openstack-platform/10/paged/director-installation-and-usage))
- SSH into the undercloud as the stack user and `source ~/stackrc`
- If `mistral --version` doesn't look something like it does below, fix the undercloud

```
[stack@undercloud 101]$ mistral --version
mistral 2.1.2
[stack@undercloud 101]$ 
```

Overview
--------
- Mistral is OpenStack's [Workflow](https://en.wikipedia.org/wiki/Workflow) service
- Describe a series of _tasks_ in yaml and Mistral will coordinate them (usually) _asynchronously_ (a specific task begins only after indication that the preceding task has been completed)
- Mistral tracks state and can manage long running processes
- Mistral natively speaks all OpenStack APIs available in the OpenStack python client
- TripleO manages OpenStack with OpenStack so Mistral fits that goal well
- TripleO's Workflow is to deploy OpenStack and it uses Mistral
- TripleO's API can be thought of as Mistral; e.g. the TripleO-UI uses it that way
- An experimental project exists to call [Ansible from Mistral](https://github.com/d0ugal/mistral-ansible-actions)
- [Mistral Docs](http://docs.openstack.org/developer/mistral/overview.html) 

Hello World
-----------
Borrowing from [d0ugal's example](http://www.dougalmatthews.com/2016/Nov/18/mistral-workflow-engine),
download [hello_world.yaml](https://github.com/fultonj/mistral/blob/master/101/hello_world.yaml).

- Register the workflow `mistral workflow-create hello_world.yaml`
- Now that it's stored, trigger it by name `mistral execution-create hello_world`
- Save the UUID in a variable `UUID=<...>`
- Check on the status of the workflow `mistral execution-get $UUID`
- Get the output of the workflow `mistral execution-get-output $UUID`
- Look for your workflow in the list of others `mistral execution-list`
- Make a small change to hello_world.yaml update it `mistral workflow-update hello_world.yaml`
- Re-run your modified copy (note that the previous execution is saved)

Compare your output to [hello_session.txt](https://github.com/fultonj/mistral/blob/master/101/hello_session.txt).

Terms
-----
- [Workflow](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#workflows) 
  : A set of tasks, e.g. everything under `hello_world`
- [Task](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#tasks) 
  : A set of actions, e.g. `say_hello` was the only task. 
- [Action](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#actions)
  : A set of built-in functions within a task to do useful things,
  `std.echo output="Hello Workflow!"`. Other actions besides std.echo are std.http, std.ssh, std.fail, etc. 
- [Workbook](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#workbooks) 
  : A yaml file which which may contain a set of workflows (a set of
  tasks (a set of actions)), e.g. the [hello_world.yaml](https://github.com/fultonj/mistral/blob/master/101/hello_world.yaml) file. 
- [Execution](http://docs.openstack.org/developer/mistral/terminology/executions.html) 
  : An _instance_ of the objects above. After defining a workflow, you
  can tell Mistral to _execute_ it. Each execution is stored and can
  be seen with `mistral execution-list`. An execution is how Mistral
  tracks the _state_ of an action, task, or workflow, e.g. `mistral 
  mistral execution-create hello_world`. 

Actions
-------
- Workflows, Tasks, Workbooks, and Executions let you organize your _Actions_. 
- Actions are where the power comes from
- The [System](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#system-actions) actions include std.echo, std.fail, std.email, std.ssh, [std.http](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#std-http), [std.javascript](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#std-javascript)
- [Ad-hoc actions](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#ad-hoc-actions) are just wrappers around System actions
- Actions can be run direclty on the command line, e.g. `mistral run-action std.echo '{"output": "Hello Workflow!"}'`.

OpenStack Actions
-----------------
- All calls made by OpenStack's python-client are [available](https://github.com/openstack/mistral/blob/master/mistral/actions/openstack/mapping.json) as Mistral actions. 
- Compare `mistral action-list | grep cinder` to `mistral action-list | grep nova`
- Run the command `mistral run-action neutron.list_networks`
- Look at the output of `mistral action-get nova.servers_create`
- [See](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#yaml-example) how to launch a Nova instance with Mistral 

Workflow Input and Viewing Actions
----------------------------------
- [Example from the docs](http://docs.openstack.org/developer/mistral/quickstart.html#write-a-workflow) on viewing actions and passing input to workflows.
- [input_action_details.yaml](https://github.com/fultonj/mistral/blob/master/101/input_action_details.yaml) 
- [input_action_details_session.txt](https://github.com/fultonj/mistral/blob/master/101/input_action_details_session.txt)


Flow Control and Using Workbooks
--------------------------------
- [d0ugal's flow control example](http://www.dougalmatthews.com/2017/Jan/09/mistral-flow-control)
- [flow_control.yaml](https://github.com/fultonj/mistral/blob/master/101/flow_control.yaml) 
- [flow_control_session.txt](https://github.com/fultonj/mistral/blob/master/101/flow_control_session.txt)


TripleO Actions and Workbooks
-----------------------------
- See `mistral action-list | grep tripleo`
- TripleO comes with its [Mistral Actions](https://github.com/openstack/tripleo-common/tree/master/tripleo_common/actions) 
- TripleO comes with its [Mistral Workbooks](https://github.com/openstack/tripleo-common/tree/master/workbooks)
- It's also possible to [embed Mistral Workflows in THT](https://review.openstack.org/#/c/404499/6/extraconfig/tasks/tendrl-workflow.yaml)

Zaqar
-----
- The [Zaqar](https://wiki.openstack.org/wiki/Zaqar#Zaqar) queuing service is not a replacement for RabbitMQ; it's a queue for cloud users not cloud operators similar to Amzon's SQS. 
- Zaqar was [changed](https://specs.openstack.org/openstack/zaqar-specs/specs/newton/mistral-notifications.html) to allow a message to a Zaqar queue to trigger a Mistral workflow.
- Each TripleO workflow creates a Zaqar queue to send progress
  information back to the client (CLI or web UI). See [diagram](https://raw.githubusercontent.com/fultonj/mistral/master/101/shardys_mistral_tripleo_slide.png)
- TripleO's workflows post messages to the 'tripleo' Zaqar queue; e.g. see [scale.yaml](https://github.com/openstack/tripleo-common/blob/156d2c/workbooks/scale.yaml#L31)
- If a failed workflow appears in `mistral execution-list`, check that Zaqar is running (`sudo systemctl | grep zaqar`) and the logs `/var/log/mistral/{engine.log,executor.log}`
- Workflows can be paused to wait for user input before being sent down the Zaqar queue as per [d0ugal's interactive workflow example](http://www.dougalmatthews.com/2017/Jan/31/interactive-mistral-workflows-over-zaqar)

Extending TripleO's Actions
---------------------------
- You can [write your own](http://docs.openstack.org/developer/mistral/developer/creating_custom_action.html) custom Mistral actions in Python
- [Example](https://review.openstack.org/#/c/413229) of adding a workflow to TripleO to configure part of Swift
- See how these Python files hook into [setup.cfg](https://github.com/openstack/tripleo-common/blob/master/setup.cfg#L62)
- Restart Mistral to run your action as described in [Action Development](https://github.com/openstack/tripleo-common#action-development) after writing your actions as described below.
```
git clone https://git.openstack.org/openstack/tripleo-common.git
cd tripleo-common/tripleo_common/actions
git checkout -b my_action
vim my_action.py
vim ../../setup.cfg
```


