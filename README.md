# OpenShift Service Mesh benchmarking

We are going to deploy a benchmark for OpenShift Service Mesh. In this repository you can find a guide to install a number of bookinfo applications and run several http calls against them to create some load in the mesh.

# Prerequisites

- Openshift 4.5+ installed, with openshift servicemesh 2.0+ running.
- [Monitoring your own services feature enabled](https://docs.openshift.com/container-platform/4.5/monitoring/monitoring-your-own-services.html#setting-up-metrics-collection_monitoring-your-own-services).
- jq, oc tools

# Install Grafana and Pushgateway

To measure our benchmark, we will install a grafana with the use of a community operator, in addition to a pushgateway. We will install the pushgateway in the same namespace of the grafana instance.

## Install grafana community operator

```shell
oc new-project monitoring
```

```shell
oc apply -n monitoring -f operators/grafana/grafana-subscription.yaml
```

## Install Pushgateway and Grafana instance

The pushgateway will be the point in which we will push the metric we get when we run the benchmark. When we run the benchmark, we will specify the address of the pushgateway, for our benchmark to push the metrics. We will also deploy a servicemonitor in this namespace, with the use of this servicemonitor, thanos will scrap the metrics of this pushgateway.


```shell
./charts/pushgateway/deploy.sh
```

## Inject Grafana Data Source

We will inject a data source to the grafana. This data source will take the metrics from the servicemonitor we have created in thanos, so now we have the metrics we pushed to the pushgateway, also in grafana. We will also source some metrics from openshift-monitoring prometheus. For creating the datasource we need the token of the grafana serviceaccount, we will get it with the following command:


```shell
./charts/datasource/datasource.sh
```

## Upload Dashboard

In this step we will upload our dashboard to grafana. You will need to create an API KEY for accessing the grafana, and change the route in the example by the route in your domain

Upload the dashboard:

```shell
./dashboards/upload_dashboard.sh dashboards/grafana-wrk2-cockpit.json
```

# Use cases
This repository contemplates several possible scenarios:

1. [Intra-mesh traffic](#intra-mesh-traffic)
2. [Ingress traffic](#ingress-traffic)
3. [Ingress-intra-egress traffic](#ingress-intra-egress-traffic)

## Intra-mesh traffic
In this use case, the benchmark application will be deployed inside the mesh and will generate traffic through the bookinfo(s) application(s). __All traffic generated will be within the mesh.__

This test can be configured with the following configuration:
- Number of namespaces created in OCP and joined into the Service Mesh.
- Number of bookinfo applications deployed per namespace.
- Benchmark parameters:
  - wrk2.app.count -> number of bookinfos per namespace to launch the benchmark against.
  - wrk2.app.namespace -> number of namespaces to launch the benchmark against.
  - benchnmark.name -> name of the benchmark to be run
  - wrk2.app.name -> name of the instance to be pushed
  - wrk2.duration -> duration of the benchmark in seconds
  - wrk2.connections -> number of concurrent calls when made a call
  - wrk2.RPS -> requests per second
  - wrk2.initDelay -> initialDelay in seconds

### Run benchmark with bookinfo application

Run benchmark. Execute:
```shell
charts/intra-mesh_traffic/bookinfo.sh
```

You must see a result like this:
```
#[Mean    =       12.944, StdDeviation   =       12.861]
#[Max     =       43.840, Total count    =          100]
#[Buckets =           27, SubBuckets     =         2048]
----------------------------------------------------------
  101 requests in 10.00s, 267.86KB read
Requests/sec:     10.10
Transfer/sec:     26.77KB
Total Requests: 101
HTTP errors: 0
Requests timed out: 0
Bytes received: 274285
Socket connect errors: 0
Socket read errors: 0
Socket write errors: 0

URL call count
http://productpage-0.bookinfo-0/productpage?u=test : 15
http://productpage-0.bookinfo-0/ : 71
http://productpage-0.bookinfo-0/productpage?u=normal : 15
All done!
```

## Ingress traffic
TODO
## Ingress-intra-egress traffic
TODO