(serve-configure-deployment)=

# Configuring a Ray Serve deployment

These are all the properties available on a Ray Serve deployment. This is also available in the [API reference](../serve/api/doc/ray.serve.deployment_decorator.rst)

The following can be configured through either the serve config file or on the `@serve.deployment` decorator:

- `name` - Name uniquely identifying this deployment within the application. If not provided, the name of the class or function is used.
- `num_replicas` - The number of replicas to run that handle requests to this deployment. Defaults to 1.
- `route_prefix` - Requests to paths under this HTTP path prefix are routed to this deployment. Defaults to ‘/{name}’. This can only be set for the ingress (top-level) deployment of an application.
- `ray_actor_options` - Options to be passed to the Ray actor decorator, such as resource requirements. Valid options are accelerator_type, memory, num_cpus, num_gpus, object_store_memory, resources, and runtime_env. For more details - [Resource management in Serve](serve-cpus-gpus)
- `max_concurrent_queries` - The maximum number of queries that are sent to a replica of this deployment without receiving a response. Defaults to 100. This may be an important parameter to check for [performance tuning](serve-perf-tuning).
- `autoscaling_config` - Parameters to configure autoscaling behavior. If this is set, num_replicas cannot be set. For more details on all configurable parameters for autoscaling - [Ray Serve Autoscaling](ray-serve-autoscaling). 
- `health_check_period_s` - How often the health check is called on the replica. Defaults to 10s. The health check is by default a no-op actor call to the replica, but you can define your own as a “check_health” method that raises an exception when unhealthy.
- `health_check_timeout_s` - How long to wait for a health check method to return before considering it failed. Defaults to 30s.
- `graceful_shutdown_wait_loop_s` - Duration that replicas wait until there is no more work to be done before shutting down.
- `graceful_shutdown_timeout_s` - Duration that a replica can be gracefully shutting down before being forcefully killed.
- `is_driver_deployment` - [EXPERIMENTAL] when set, exactly one replica of this deployment runs on every node (like a daemon set).

The following can be configured through the serve config files only:
- `user_config` -  Config to pass to the reconfigure method of the deployment. This can be updated dynamically without restarting the replicas of the deployment. The user_config must be fully JSON-serializable. For more details - [Serve User Config](serve-user-config). 



