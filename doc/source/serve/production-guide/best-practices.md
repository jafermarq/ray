(serve-best-practices)=

# Best practices

This section summarizes the best practices when deploying to production using the Serve CLI:

* Use `serve run` to manually test and improve your deployment graph locally.
* Use `serve build` to create a Serve config file for your deployment graph.
    * Put your deployment graph's code in a remote repository and manually configure the `working_dir` or `py_modules` fields in your Serve config file's `runtime_env` to point to that repository.
* Use `serve status` to track your Serve application's health and deployment progress.
* Use `serve config` to check the latest config that your Serve application received. This is its goal state.
* Make lightweight configuration updates (e.g. `num_replicas` or `user_config` changes) by modifying your Serve config file and redeploying it with `serve deploy`.

(serve-in-production-inspecting)=

## Inspecting the application with `serve config` and `serve status`

The Serve CLI also offers two commands to help you inspect your Serve application in production: `serve config` and `serve status`.
If you're working with a remote cluster, `serve config` and `serve status` also offer an `--address/-a` argument to access your cluster. Check out [the VM deployment guide](serve-in-production-remote-cluster) for more info on this argument.

`serve config` gets the latest config file the Ray cluster received. This config file represents the Serve application's goal state. The Ray cluster will constantly attempt to reach and maintain this state by deploying deployments, recovering failed replicas, and more.

Using the `fruit_config.yaml` example from [an earlier section](fruit-config-yaml):

```console
$ ray start --head
$ serve deploy fruit_config.yaml
...

$ serve config
import_path: fruit:deployment_graph

runtime_env: {}

deployments:

- name: MangoStand
  num_replicas: 2
  route_prefix: null
...
```

`serve status` gets your Serve application's current status. It's divided into two parts per application: the `app_status` and the `deployment_statuses`.

The `app_status` contains three fields:
* `status`: a Serve application has four possible statuses:
    * `"NOT_STARTED"`: no application has been deployed on this cluster.
    * `"DEPLOYING"`: the application is currently carrying out a `serve deploy` request. It is deploying new deployments or updating existing ones.
    * `"RUNNING"`: the application is at steady-state. It has finished executing any previous `serve deploy` requests, and it is attempting to maintain the goal state set by the latest `serve deploy` request.
    * `"DEPLOY_FAILED"`: the latest `serve deploy` request has failed.
* `message`: provides context on the current status.
* `deployment_timestamp`: a unix timestamp of when Serve received the last `serve deploy` request. This is calculated using the `ServeController`'s local clock.

The `deployment_statuses` contains a list of dictionaries representing each deployment's status. Each dictionary has three fields:
* `name`: the deployment's name.
* `status`: a Serve deployment has three possible statuses:
    * `"UPDATING"`: the deployment is updating to meet the goal state set by a previous `deploy` request.
    * `"HEALTHY"`: the deployment is at the latest requests goal state.
    * `"UNHEALTHY"`: the deployment has either failed to update, or it has updated and has become unhealthy afterwards. This may be due to an error in the deployment's constructor, a crashed replica, or a general system or machine error.
* `message`: provides context on the current status.

You can use the `serve status` command to inspect your deployments after they are deployed and throughout their lifetime.

Using the `fruit_config.yaml` example from [an earlier section](fruit-config-yaml):

```console
$ ray start --head
$ serve deploy fruit_config.yaml
...

$ serve status
app_status:
  status: RUNNING
  message: ''
  deployment_timestamp: 1655771534.835145
deployment_statuses:
- name: MangoStand
  status: HEALTHY
  message: ''
- name: OrangeStand
  status: HEALTHY
  message: ''
- name: PearStand
  status: HEALTHY
  message: ''
- name: FruitMarket
  status: HEALTHY
  message: ''
- name: DAGDriver
  status: HEALTHY
  message: ''
```

For Kubernetes deployments with KubeRay, there's closer integrations of `serve status` with Kubernetes. Please check out the guide for [getting the status of serve applications in Kubernetes](serve-getting-status-kubernetes).

`serve status` can also be used with KubeRay ({ref}`kuberay-index`), a Kubernetes operator for Ray Serve, to help deploy your Serve applications with Kubernetes. There's also work in progress to provide closer integrations between some of the features from this document, like `serve status`, with Kubernetes to provide a clearer Serve deployment story.