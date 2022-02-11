#!/bin/bash
CURRENT_DIR=$(pwd)

echo "Add cluster role to user:"
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n monitoring
echo

echo "Get the default ingress controller domain:"
OCP_DOMAIN=$(oc -n openshift-ingress-operator get ingresscontrollers default -o json | jq -r '.status.domain')
echo

echo "Replace the $EXTERNAL_DOMAIN variable in both route objects:"
find $CURRENT_DIR/charts/pushgateway/ -type f -print0 | xargs -0 sed -i "s/\$EXTERNAL_DOMAIN/$OCP_DOMAIN/g"
echo

echo "Deploy pushgateway and grafana:"
helm template charts/pushgateway --namespace monitoring | oc apply -f -
oc wait --for=condition=available deploy/grafana-deployment --timeout=120s
echo

echo "Creating OCP routes:"
oc apply -n monitoring -f $CURRENT_DIR/charts/pushgateway/route-grafana-service.yaml
oc apply -n monitoring -f $CURRENT_DIR/charts/pushgateway/route-pushgateway.yaml
