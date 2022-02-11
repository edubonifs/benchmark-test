#!/bin/bash
CURRENT_DIR=$(pwd)

TOKEN=$(oc sa get-token grafana-serviceaccount -n monitoring | tr -d "\n")

helm template charts/datasource --namespace monitoring --set grafana.token=$TOKEN | oc apply -f -



