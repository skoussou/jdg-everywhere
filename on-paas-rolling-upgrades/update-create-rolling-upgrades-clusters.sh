#!/usr/bin/env bash

USE_KUBE_PING=$1

echo '======================================'
echo ' Create SOURCE CLUSTER JDG-65 Cluster'
echo '======================================'
echo 
echo 'oc new-app --template=datagrid65-basic -p APPLICATION_NAME=jdg65-cluster -p INFINISPAN_CONNECTORS=rest -p CACHE_NAMES=carcache,stringCache,clustercache -e CLUSTERCACHE_CACHE_TYPE=replicated'
oc new-app --template=datagrid65-basic -p APPLICATION_NAME=jdg65-cluster -p INFINISPAN_CONNECTORS=rest -p CACHE_NAMES=carcache,stringCache,clustercache -e CLUSTERCACHE_CACHE_TYPE=replicated -l app=jdg65-cluster

echo
echo '======================================'
echo ' Create the Target JDG-71 Cluster'
echo '======================================'

if [ -z "$USE_KUBE_PING"]; then
  echo
  echo "------------------------------------------------------------------------------------------------------------------------------------------------------------"
  echo "WARNING: Using openshift.DNS_PING. To use openshift.KUBE_PING run this script with a parameter (eg. ./update-create-rolling-upgrades-clusters.sh KUBE_PING)"
  echo "------------------------------------------------------------------------------------------------------------------------------------------------------------"
  echo
  echo 'oc new-app --template=datagrid71-basic -p APPLICATION_NAME=jdg71-cluster -p INFINISPAN_CONNECTORS=rest -p CACHE_NAMES=carcache,stringCache,clustercache -e CLUSTERCACHE_CACHE_TYPE=replicated -p MEMCACHED_CACHE=""'
  oc new-app --template=datagrid71-basic -p APPLICATION_NAME=jdg71-cluster -p INFINISPAN_CONNECTORS=rest -p CACHE_NAMES=carcache,stringCache,clustercache -e CLUSTERCACHE_CACHE_TYPE=replicated -p MEMCACHED_CACHE="" -l app=jdg71-cluster
else 
  echo
  echo "------------------------------------------------------------"
  echo " CLUSTERING discovery in JDG on OCP provided via KUBE_PING"
  echo "------------------------------------------------------------"
  oc policy add-role-to-user view system:serviceaccount:$(oc project -q):default -n $(oc project -q)
  oc policy add-role-to-user view system:serviceaccount:$(oc project -q):eap-service-account -n $(oc project -q)
  echo 'oc new-app --template=datagrid71-basic -p APPLICATION_NAME=jdg71-cluster -p INFINISPAN_CONNECTORS=rest -p CACHE_NAMES=carcache,stringCache,clustercache -e CLUSTERCACHE_CACHE_TYPE=replicated -p MEMCACHED_CACHE="" -e JGROUPS_PING_PROTOCOL=openshift.KUBE_PING -e OPENSHIFT_KUBE_PING_LABELS=app=jdg71-cluster -e OPENSHIFT_KUBE_PING_NAMESPACE=jdg-rest-rolling-upgrade-demo -l app=jdg71-cluster  -l app=jdg71-cluster'
  oc new-app --template=datagrid71-basic -p APPLICATION_NAME=jdg71-cluster -p INFINISPAN_CONNECTORS=rest -p CACHE_NAMES=carcache,stringCache,clustercache -e CLUSTERCACHE_CACHE_TYPE=replicated -p MEMCACHED_CACHE="" -e JGROUPS_PING_PROTOCOL=openshift.KUBE_PING -e OPENSHIFT_KUBE_PING_LABELS=app=jdg71-cluster -e OPENSHIFT_KUBE_PING_NAMESPACE=jdg-rest-rolling-upgrade-demo -l app=jdg71-cluster  -l app=jdg71-cluster
fi

echo
echo 'Create Remote Server Settings for each of the caches (carcache,stringCache,clustercache) from JDG-71 Cluster to JDG-65 Cluster'

