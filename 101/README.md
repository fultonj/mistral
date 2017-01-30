Mistral 101
===========

This is my crash-course in Mistral for people familiar with
TripleO and Ansible. It borrows from other intros
([e.g. d0ugal's blog](http://www.dougalmatthews.com/)), while
focusing on writing a simple workflow that might help someone 
who's goal is to write larger workflow for TripleO to do something 
extra. 

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
- [Docs](http://docs.openstack.org/developer/mistral/overview.html) 

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
  A set of tasks. E.g. everything under `hello_world`

- [Task](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#tasks) 
  A set of actions. E.g. `say_hello` was the only task. 

- [Action](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#actions)
  A set of built-in functions to do useful things; e.g. std.echo, std.http, std.ssh, std.fail
  [All calls made by OpenStack's python-client are available as Mistral actions!](https://github.com/openstack/mistral/blob/master/mistral/actions/openstack/mapping.json)
  E.g. `std.echo output="Hello Workflow!"` Actions can be run on the
  command line alone, e.g. `mistral run-action std.echo '{"output":
  "Hello Workflow!"}'`.

- [Workbook](http://docs.openstack.org/developer/mistral/dsl/dsl_v2.html#workbooks) -
  A yaml file which which may contain a set of workflows (a set of
  tasks (a set of actions)). E.g. the [hello_world.yaml](https://github.com/fultonj/mistral/blob/master/101/hello_world.yaml) file. 

- [Execution](http://docs.openstack.org/developer/mistral/terminology/executions.html) -
  An _instance_ of the objects above. After defining a workflow, you
  can tell Mistral to _execute_ it. Each execution is stored and can
  be seen with `mistral execution-list`. An execution is how Mistral
  tracks the _state_ of an action, task, or workflow. E.g. `mistral 
  mistral execution-create hello_world`. 


Exercise
--------

- Complete the http://docs.openstack.org/developer/mistral/quickstart.html
