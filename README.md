# Istio Servicemesh Benchmark Openshift

We are going to deploy a benchmark for openshift service mesh, in this github I will guide to install a number of bookinfo applications and run several http calls against them to create some charge in the mesh. This is the guide to follow.

# Prerequisites

As prerequisites, you only have to have an Openshift 4.5+ installed, with openshift servicemesh 2.0+ running.

## Openshift and ServiceMesh

Having Openshift 4.5+ installed with servicemesh 2.0+

# Install Grafana and Pushgateway

To measure our benchmark, we will install a grafana with the use of a community operator, in addition to a pushgateway. We will install the pushgateway in the same namespace of the grafana.

## Install grafana community operator

```shell
oc new-project monitoring
```

Install community operator grafana in monitoring namespace

## Install Pushgateway

The pushgateway will be the point in which we will push the metric we get whe we run the benchmark. When we run the benchmark, we will specify the address of the pushgateway, for our benchmark to push the metrics. We will also deploy a servicemonitor in this namespace, with the use of this servicemonitor, thanos will scrap the metrics of this pushgateway.

```shell
helm template charts/pushgateway --namespace monitoring | oc apply -f -
```

```shell
./expose_svc.sh
```

## Inject Grafana Data Source

We will inject a data source to the grafana. This data source will take the metrics from the servicemonitor we have created in thanos, so now we have the metrics we pushed to the pushgateway, also in grafana. We will also source some metrics from openshift-monitoring prometheus. For creating the datasource we need the token of the grafana serviceaccount, we will get it with the following command:

```shell
oc sa get-token grafana-serviceaccount -n monitoring
```

We will have to pass the helm template the value of the token, for that we can include the flag "--set grafana.token" in the helm command, or put the value in the file charts/datasource/value.yaml

```shell
helm template charts/datasource --namespace monitoring | oc apply -f -
```

## Upload Dashboard

In this step we will upload our dashboard to grafana. You will need to create an API KEY for accessing the grafana, and change the route in the example by the route in your domain

Create an API Key

```shell
./dashboards/upload_dashboard.sh "[API KEY]" dashboards/grafana-wrk2-cockpit.json grafana-service-monitoring.apps.ocp.redhat.lab
```

# Deploy Applications

## Create namespaces for deploying user applicaions

With this command of helm  we will specify hoiw many user namespaces we will create in order to deploy our applications. If you edit the variable bookinfo.replicas in the command line, you will change how many namespaces will be created.

```shell
helm template charts/namespaces --set bookinfo.namespaces=2 | oc apply -f -
```

## Create bookinfo applications

With this command of helm, you will say how many bookinfo applications per namespace and in which namespaces you will created. For example setting bookinfo.replica=2 means that you will deploy two bookinfo applications per namespace, and bookinfo.namespaces, means you will deploy that number of bookinfos in two namespaces, bookinfo-0 and bookinfo-1. These namespaces must have been created before, so don't try to install bookinfo in more namespaces that you previously created.

```shell
helm template charts/bookinfo --set bookinfo.replica=2 --set bookinfo.namespaces=2 | oc apply -f -
```

## Run benchmark

Finally, we will run the benchmark. This becnhmark has some parameters:

- wrk2.app.count -> number of bookinfos per namespace to launch the benchmark against.
- wrk2.app.namespace -> number of namespaces to launch the benchmark against.
- benchnmark.name -> name of the benchmark to be run
- wrk2.app.name=edu -> name of the instance to be pushed
- wrk2.duration -> duration of the benchmark in seconds
- wrk2.connections -> number of concurrent calls when made a call
- wrk2.RPS -> requests per second
- wrk2.initDelay -> initialDelay in seconds

You can see default values in values.yaml

```shell
helm template charts/benchmark --namespace benchmark --set wrk2.app.count=2 --set wrk2.app.namespace=2 --set benchnmark.name=edu --set wrk2.app.name=edu | oc apply -f -
```

