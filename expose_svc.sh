#!/bin/bash
oc adm policy add-cluster-role-to-user cluster-monitoring-view -z grafana-serviceaccount -n grafana
oc expose svc/grafana-service -n monitoring
oc expose svc/pushgateway -n monitoring
