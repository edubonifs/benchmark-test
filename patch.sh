#!/bin/bash
oc get deploy -A -l app.kubernetes.io/managed-by=Helm -o yaml | oc neat > patch/deployments.yaml
kustomize build patch/ > patch/out_actual.yaml
oc apply -f patch/out_actual.yaml
