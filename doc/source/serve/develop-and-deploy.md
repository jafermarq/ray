(serve-develop-and-deploy)=

# Develop and deploy an ML application

This section will walk you through the flow for developing a Ray Serve application locally and deploying it in production. It will cover

* Converting a Machine Learning model into a Ray Serve application
* Testing the application locally
* Building Serve config files for production deployment
* Deploying Ray Serve in production

## Converting a Model into a Ray Serve application

First, let's take a look at our text-translation model. Here's its code:

```{literalinclude} ../serve/doc_code/getting_started/models.py
:start-after: __start_translation_model__
:end-before: __end_translation_model__
:language: python
```

The Python file, called `model.py`, uses the `Translator` class to translate English text to French.

- The `self.model` variable inside `Translator`'s `__init__` method
  stores a function that uses the [t5-small](https://huggingface.co/t5-small)
  model to translate text.
- When `self.model` is called on English text, it returns translated French text
  inside a dictionary formatted as `[{"translation_text": "..."}]`.
- The `Translator`'s `translate` method extracts the translated text by indexing into the dictionary.

You can copy-paste this script and run it locally. It translates `"Hello world!"`
into `"Bonjour Monde!"`.

```console
$ python model.py

Bonjour Monde!
```

Let's convert this model into a Ray Serve application with FastAPI. For other HTTP options, please look at [Set Up FastAPI and HTTP](serve-set-up-fastapi-http). These are the 3 changes we need:
1. Import Ray Serve and Fast API dependencies
2. Add decorators for serve deployment with FastAPI - `@serve.deployment` and `@serve.ingress(app)`
3. `bind` our `Translator` deployment to arguments that will be passed into its constructor

```{literalinclude} ../serve/doc_code/develop_and_deploy/model_deployment_with_fastapi.py
:start-after: __deployment_start__
:end-before: __deployment_end__
:language: python
```

You will notice that there are properties being configured for the deployment, such as `num_replicas` and `ray_actor_options`. These help configure the number of copies of our deployment and the resource requirements per copy. For a complete guide on the configurable parameters on a deployment, please check out [configuring a serve deployment](serve-configure-deployment).

## Testing a Ray Serve application locally

To test locally, we run the script with the `serve run` CLI command. This command takes in an import path formatted as `module:application`. Make sure to run the command from a directory containing a local copy of this script saved as `model.py`, so it can import the application:

```console
$ serve run model:translator_app
```

This command will run the `translator_app` application and then block, streaming logs to the console. It can be killed with `Ctrl-C`, which will tear down the application.

We can now test our model over HTTP. It can be reached at the following URL by default:

```
http://127.0.0.1:8000/
```

We'll send a POST request with JSON data containing our English text. Here's a client script that requests a translation for "Hello world!":

```{literalinclude} ../serve/doc_code/develop_and_deploy/model_deployment_with_fastapi.py
:start-after: __client_function_start__
:end-before: __client_function_end__
:language: python
```

While a Ray Serve application is deployed, you can use the `serve status` CLI command to check the status of the applications and deployments. For more details on the output format of `serve status`, please look at [Inspecting Serve in production guide](serve-in-production-inspecting).

```console
$ serve status
name: default
app_status:
  status: RUNNING
  message: ''
  deployment_timestamp: 1687415211.531879
deployment_statuses:
- name: default_Translator
  status: HEALTHY
  message: ''
```

## Building Serve config files for production deployment

In order to deploy serve applications in production, you need to first generate a serve config YAML file. This can be done using the `serve build` CLI command that takes as input the import path and can be saved to an output file using the `-o` flag. All deployment properties can be specified in the serve config files.

```console
$ serve build model:translator_app -o config.yaml
```

This is what the serve config file will look like:

```
# This file was generated using the `serve build` command on Ray v2.5.1.

import_path: model:translator_app

runtime_env: {}

host: 0.0.0.0

port: 8000

deployments:

- name: Translator
  num_replicas: 2
  ray_actor_options:
    num_cpus: 0.2
    num_gpus: 0.0
```

You can also use the serve config file with `serve run` for local testing, for example:

```console
$ serve run config.yaml
```

For more details, please look at [Serve Config Files](serve-in-production-config-file)

## Deploying Ray Serve in production

We recommend deploying the Ray Serve application in production on Kubernetes using the [KubeRay](kuberay) operator. The YAML file generated before can be copied directly into the Kubernetes configuration. KubeRay supports zero-downtime upgrades, status reporting and fault tolerance for your production application. Please check out the [deploying on Kubernetes](serve-in-production-kubernetes) guide for more information. For production usage, we also recommend setting up [head node fault tolerance](serve-e2e-ft-guide-gcs).

## Monitoring a Ray Serve cluster

You can use the Ray dashboard to get a high-level overview of your Ray cluster and Ray Serve application's states. This is available both during local testing as well on a remote cluster in production. Ray Serve provides some in-built metrics and logging as well as utilities for adding custom metrics and logs in your application. For production deployments, we recommend exporting logs and metrics to your observability platforms. Please look at the [monitoring guide](serve-monitoring) for more details. 


