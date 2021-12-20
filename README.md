# Istio Servicemesh Benchmark Openshift

# Prerequisites

## Openshift and ServiceMesh

Having Openshift 4.5+ installed with servicemesh 2.0+

## Install Grafana and Pushgateway

oc new-project monitoring

Install community operator grafana in monitoring namespace

helm template charts/pushgateway --namespace monitoring | oc apply -f -

./expose_svc.sh

oc sa get-token grafana-serviceaccount -n monitoring

helm template charts/datasource --namespace monitoring | oc apply -f -

oc -n monitoring get secret grafana-admin-credentials -o jsonpath='{.data.GF_SECURITY_ADMIN_PASSWORD}' | base64 -d && echo

Create an API Key

./dashboards/upload_dashboard.sh "[API KEY]" dashboards/grafana-wrk2-cockpit.json grafana-service-monitoring.apps.ocp.redhat.lab

## Create namespaces for deploying user applicaions

helm template charts/namespaces --set bookinfo.replica=2 --set bookinfo.namespaces=2 | oc apply -f -

## Create bookinfo applications

helm template charts/bookinfo --set bookinfo.replica=2 --set bookinfo.namespaces=2 | oc apply -f -

## Run benchmark

helm template charts/benchmark --namespace benchmark --set wrk2.app.count=2 --set wrk2.app.namespace=2 --set bechnmark.name=edu | oc apply -f -
