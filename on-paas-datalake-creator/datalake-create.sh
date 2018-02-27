#!/usr/bin/env bash

APP_NAME=$1
NAMESPACE=$2

# defining namespace

if [ -z "$NAMESPACE" ]
then
NAMESPACE=$(oc project -q)
echo Warning: Namespace found empty, to setting current project name $NAMESPACE
echo
fi

echo Creating KUBERNETES REST API required View access for Clustering
echo policy add-role-to-user view system:serviceaccount:$NAMESPACE:default -n $NAMESPACE
oc policy add-role-to-user view system:serviceaccount:$NAMESPACE:default -n $NAMESPACE

echo oc policy add-role-to-user view system:serviceaccount:$NAMESPACE:eap-service-account -n $NAMESPACE
oc policy add-role-to-user view system:serviceaccount:$NAMESPACE:eap-service-account -n $NAMESPACE

oc process -f datagrid71-partition-KUBE-PING.json -p APPLICATION_NAME=$APP_NAME -p CACHE_NAMES=carcache,stringCache -p INFINISPAN_CONNECTORS=hotrod,rest -p OPENSHIFT_KUBE_PING_NAMESPACE=myproject -l application=$APP_NAME | oc create -n $NAMESPACE -f -
