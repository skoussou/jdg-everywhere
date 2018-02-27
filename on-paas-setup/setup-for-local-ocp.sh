#!/usr/bin/env bash

echo 'pulling Docker images locally'
docker pull registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift
docker pull registry.access.redhat.com/jboss-datagrid-6/datagrid65-openshift
docker pull registry.access.redhat.com/jboss-datagrid-7/datagrid71-openshift
docker pull registry.access.redhat.com/jboss-eap-7/eap71-openshift
docker pull registry.access.redhat.com/openshift3/ose:v3.7.23

oc login -u system:admin

echo "importing imagestreams to the Openshift namespace"
oc create -f ./installs/application-templates/jboss-image-streams.json -n openshift
oc get imagestream -n openshift


echo  "importing templates to the Openshift namespace"
oc create -f ./installs/application-templates/datagrid/datagrid65-basic.json -n openshift
oc create -f ./installs/application-templates/datagrid/datagrid71-basic.json -n openshift
oc create -f ./installs/application-templates/./eap/eap71-basic-s2i.json -n openshift  

oc login -u developer
