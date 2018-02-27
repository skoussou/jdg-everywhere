#!/usr/bin/env bash

APP_NAME=$1
NAMESPACE=$2

# defining namespace

if [ -z "$NAMESPACE" ]; then
  NAMESPACE=$(oc project -q)
  echo Warning: Namespace found empty, to setting current project name $NAMESPACE
  echo
fi

# delete ALL generated based on label

#echo deleting datalake APP ...
echo delete all -l application=${APP_NAME} -n $NAMESPACE
oc delete all -l application=${APP_NAME} -n $NAMESPACE

echo deleting datalake APP PVC dependencies ... $(oc get pvc --namespace=$NAMESPACE | grep datagrid-claim | awk '{print $1}')
oc login -u system:admin
echo oc delete pvc $(oc get pvc --namespace=$NAMESPACE | grep datagrid-claim | awk '{print $1}')
oc delete pvc $(oc get pvc --namespace=$NAMESPACE | grep datagrid-claim | awk '{print $1}')
