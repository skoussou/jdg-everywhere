#!/usr/bin/env bash

APP_NAME=$1
NAMESPACE=$2

if [ -z "$NAMESPACE" ]; then
  NAMESPACE=$(oc project -q)
  echo Warning: Namespace found empty, to setting current project name $NAMESPACE
  echo
fi


echo Scaling up ${APP_NAME} in Namespace ${NAMESPACE}
echo oc scale --replicas=3  dc/$(oc get dc --namespace=$NAMESPACE | grep ${APP_NAME}  | awk '{print $1}') --namespace=$NAMESPACE
oc scale --replicas=3  dc/$(oc get dc --namespace=$NAMESPACE | grep ${APP_NAME}  | awk '{print $1}') --namespace=$NAMESPACE

