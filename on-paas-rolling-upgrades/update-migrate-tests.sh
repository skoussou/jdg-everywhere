#!/usr/bin/env bash

export JDG71_POD=$(oc get pods -o name | grep -Po "[^/]+$" | grep "jdg71" | grep -v "deploy")

#oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache clustercache,get c-1' \
#oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered/replicated-cache=clustercache,get c-1' \
#| grep '"' | base64 -di; echo
#echo
#oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache clustercache,get c-2' \
#| grep '"' | base64 -di; echo
#echo
#oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache stringCache,get k-2' \
#| grep '"' | base64 -di; echo
#echo
#oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache stringCache,get k-3' \
#| grep '"' | base64 -di; echo

# TARGET CLUSTER TESTS
#=======================
echo
echo "TARGET (JDG71) CLUSTER TESTS"
echo "========================="
echo
export JDG71_ROUTE=$(oc get routes --no-headers | grep "jdg71" | tr -s ' ' | cut -d ' ' -f2)
echo '----------- RETRIEVE clustercache - keys & values -----------'
echo keys
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/clustercache
echo
echo key : c-1
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/clustercache/c-1
echo
echo key : c-2
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/clustercache/c-2
echo
echo key : c-3
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/clustercache/c-3
echo
echo '--------------------------------------------------'
echo
echo
echo '----------- RETRIEVE stringCache - keys & values -----------'
echo keys
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/stringCache
echo
echo key : c-1
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/stringCache/k-1
echo
echo key : c-2
curl -H "Accept:application/json" -X GET $JDG71_ROUTE/rest/stringCache/k-2
echo
echo '--------------------------------------------------'
