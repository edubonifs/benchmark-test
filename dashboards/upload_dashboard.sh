#!/bin/bash

set -x
OCP_DOMAIN=$(oc -n openshift-ingress-operator get ingresscontrollers default -o json | jq -r '.status.domain')
API_KEY=$(curl --silent https://admin:redhat@grafana-route-monitoring.$OCP_DOMAIN/api/auth/keys -H 'content-type: application/json' --data-raw '{"name":"benchmark","role":"Admin","secondsToLive":604800}' | jq -r '.key')

[ $# -lt 1 ] && {
    echo
    echo "$0 - Upload a Grafana dashboard back-up (JSON file) to Grafana" 
    echo "Usage: $0 <dashboard-file>"
    echo
    exit 1
}

dashboard="$1"

echo "Uploading dashboard file $dashboard"

out=$(mktemp)

cat  "$dashboard" \
         | jq '. * {overwrite: true, dashboard: {id: null}}' \
         | curl -X POST \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $API_KEY" \
                http://grafana-service-monitoring.$OCP_DOMAIN/api/dashboards/import -d @- | tee $out

echo -e "\nDashboard available at grafana-service-monitoring.$OCP_DOMAIN/$(cat "$out" | jq -r '.importedUrl')"

rm -f "$out"
