#!/usr/bin/env bash

export JDG71_POD=$(oc get pods -o name | grep -Po "[^/]+$" | grep "jdg71" | grep -v "deploy")


oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache clustercache,upgrade --synchronize=rest'
oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache stringCache,upgrade --synchronize=rest'
oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache carcache,upgrade --synchronize=rest'

