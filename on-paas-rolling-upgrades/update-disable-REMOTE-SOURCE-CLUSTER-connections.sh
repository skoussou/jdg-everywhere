#!/usr/bin/env bash

export JDG71_POD=$(oc get pods -o name | grep -Po "[^/]+$" | grep "jdg71" | grep -v "deploy")

oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache clustercache,upgrade --disconnectsource=rest'
oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache stringCache,upgrade --disconnectsource=rest'
oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh -c --commands='cd /subsystem=datagrid-infinispan/cache-container=clustered, cache carcache,upgrade --disconnectsource=rest'
