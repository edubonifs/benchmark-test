#!/bin/bash
CURRENT_DIR=$(pwd)
DEFAULT_VALUES="1"
OCP_DOMAIN=$(oc -n openshift-ingress-operator get ingresscontrollers default -o json | jq -r '.status.domain')

echo -e "Tool for benchmarking OpenShift Service Mesh. The default values for benchmarking are the following: \n" ; echo "------------------"

cat $CURRENT_DIR/charts/intra-mesh_traffic/bookinfo.config

echo " " ; echo "------------------" ; echo " "

while true; do 
    read -p "Use default values? yY|nN --> " yn
    case $yn in
            [Yy]* ) echo " " ; . $CURRENT_DIR/charts/intra-mesh_traffic/bookinfo.config ; echo " " ;  break;;
            [Nn]* ) echo " " ; DEFAULT_VALUES="0" ; break;;
            * ) echo "Select yes or no";;
    esac
done

if [ $DEFAULT_VALUES -eq 0 ]; then
    echo "Introduce the following values to configure the benchmark test. " 
    echo

    read -p "Number of namespaces: " NAMESPACES
    read -p "Number of bookinfo applications per namespaces: " BOOKINFOS
    read -p "Number of bookinfo applications per namespaces to launch the benchmark against: " WRK2_BOOKINFOS
    read -p "Number of namespaces to launch the benchmark against: " WRK2_NAMESPACES
    read -p "Name of benchmark test: " WRK2_BENCHMARK_NAME
    read -p "Name of the instance to be pushed: " WRK2_APP_NAME
    read -p "Duration of the benchmark in seconds: " WRK2_BENCHMARK_DURATION
    read -p "Number of concurrent calls when made a call: " WRK2_BENCHMARK_CONNECTIONS
    read -p "Requests per second: " WRK2_BENCHMARK_REQUESTS
    read -p "Init delay in seconds: " WRK2_BENCHMARK_DELAY
fi

echo " "
echo "--> Creating namespaces for deploying the bookinfo(s) application(s): "
helm template charts/namespaces --set bookinfo.namespace=$NAMESPACES | oc apply -f -
echo " "

echo "--> Deploying the bookinfo(s) application(s): "
helm template charts/bookinfo --set bookinfo.replica=$BOOKINFOS --set bookinfo.namespace=$NAMESPACES | oc apply -f -
echo " "

echo "--> Creating Istio objects: "
helm template charts/intra-mesh_traffic/ossm --namespace benchmark --set wrk2.app.count=$WRK2_BOOKINFOS --set wrk2.app.namespace=$WRK2_NAMESPACES \
 --set benchnmark.name=$WRK2_BENCHMARK_NAME --set wrk2.app.name=$WRK2_APP_NAME --set wrk2.duration=$WRK2_BENCHMARK_DURATION \
 --set wrk2.connections=$WRK2_BENCHMARK_CONNECTIONS --set wrk2.RPS=$WRK2_BENCHMARK_REQUESTS --set wrk2.initDelay=$WRK2_BENCHMARK_DELAY | oc apply -f -
echo " "

echo "--> Executing benchmark... "
helm template charts/intra-mesh_traffic/benchmark --namespace benchmark --set wrk2.app.count=$WRK2_BOOKINFOS --set wrk2.app.namespace=$WRK2_NAMESPACES \
 --set benchnmark.name=$WRK2_BENCHMARK_NAME --set wrk2.app.name=$WRK2_APP_NAME --set wrk2.duration=$WRK2_BENCHMARK_DURATION \
 --set wrk2.connections=$WRK2_BENCHMARK_CONNECTIONS --set wrk2.RPS=$WRK2_BENCHMARK_REQUESTS --set wrk2.initDelay=$WRK2_BENCHMARK_DELAY | oc apply -f -

POD=$(oc get pod --no-headers | grep benchmark | awk '{print $1}')
oc wait --for=condition=Ready pod/$POD --timeout=-1s
oc logs -f pod/$POD -c wrk2-prometheus
oc wait --for=condition=Ready=false pod/$POD --timeout=-1s

echo " "
echo "--> Deleting benchmark resources..."
helm template charts/intra-mesh_traffic/benchmark --namespace benchmark --set wrk2.app.count=$WRK2_BOOKINFOS --set wrk2.app.namespace=$WRK2_NAMESPACES \
 --set benchnmark.name=$WRK2_BENCHMARK_NAME --set wrk2.app.name=$WRK2_APP_NAME --set wrk2.duration=$WRK2_BENCHMARK_DURATION \
 --set wrk2.connections=$WRK2_BENCHMARK_CONNECTIONS --set wrk2.RPS=$WRK2_BENCHMARK_REQUESTS --set wrk2.initDelay=$WRK2_BENCHMARK_DELAY | oc delete -f -
oc wait --for=delete pod/$POD --timeout=30s

echo " "
echo "Check the result at Grafana: https://grafana-route-monitoring.$OCP_DOMAIN/d/61uqRs-nz/wrk2-benchmark-cockpit?orgId=1"