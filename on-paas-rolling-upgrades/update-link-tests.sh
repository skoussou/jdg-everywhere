#!/usr/bin/env bash

# SOURCE CLUSTER TESTS
#=========================
export JDG65_ROUTE=$(oc get routes --no-headers | grep "jdg65" | tr -s ' ' | cut -d ' ' -f2)
curl -X PUT -d "v-1" $JDG65_ROUTE/rest/stringCache/k-1
curl -X PUT -d "v-1" $JDG65_ROUTE/rest/stringCache/k-2
curl -X PUT -d "v-1" $JDG65_ROUTE/rest/stringCache/k-3

echo
echo "SOURCE (JDG65) CLUSTER TESTS"
echo "========================="
echo curl -X PUT -d "v-1" $JDG65_ROUTE/rest/stringCache/k-1
echo curl -X PUT -d "v-1" $JDG65_ROUTE/rest/stringCache/k-2
echo curl -X PUT -d "v-1" $JDG65_ROUTE/rest/stringCache/k-3
#echo 
echo '----------- RETRIEVE stringCache - keys -----------'
curl -H "Accept:application/json" -X GET $JDG65_ROUTE/rest/stringCache
echo
echo "--------------------------------------------------"

curl -X PUT -d "v1" $JDG65_ROUTE/rest/clustercache/c-1
curl -X PUT -d "v1" $JDG65_ROUTE/rest/clustercache/c-2
curl -X PUT -d "v1" $JDG65_ROUTE/rest/clustercache/c-3
echo
echo curl -X PUT -d "v1" $JDG65_ROUTE/rest/clustercache/c-1
echo curl -X PUT -d "v1" $JDG65_ROUTE/rest/clustercache/c-2
echo curl -X PUT -d "v1" $JDG65_ROUTE/rest/clustercache/c-3
#echo
echo '----------- RETRIEVE clustercache - keys & values --------------'
curl -H "Accept:application/json" -X GET $JDG65_ROUTE/rest/clustercache
echo
echo "key c-1: "
curl -H "Accept:application/json" -X GET $JDG65_ROUTE/rest/clustercache/c-1
echo
echo "key c-2: "
curl -H "Accept:application/json" -X GET $JDG65_ROUTE/rest/clustercache/c-2
echo
echo "key c-3: "
curl -H "Accept:application/json" -X GET $JDG65_ROUTE/rest/clustercache/c-3
echo
echo '--------------------------------------------------'

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
echo '--------------------------------------------------'

