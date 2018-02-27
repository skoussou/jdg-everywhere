#!/usr/bin/env bash

#CACHE_NAMES_LIST=$1
#SOURCE_CLUSTER=$2

#if [ -z "$CACHE_NAMES_LIST" ]
#then
#CACHE_NAMES_LIST=carcache,stringCache,clustercache
#echo Warning: CACHE_NAMES_LIST found empty, to setting  $CACHE_NAMES_LIST
#echo
#fi

#if [ -z "$SOURCE_CLUSTER" ]
#then
#SOURCE_CLUSTER=jdg65-cluster
#echo Warning: CACHE_NAMES_LIST found empty, to setting  $SOURCE_CLUSTER
#echo
#fi



echo
echo '========================================================='
echo ' MODIFY TARGET CLUSTER caches to point to SOURCE CLUSTER'
echo '========================================================='
mkdir -p update-cache
cat << \EOD > ./update-cache/add-rest-store-to-cache.sh
#!/bin/bash

export JDG_CONF=/opt/datagrid/standalone/configuration/clustered-openshift.xml
export REST_SERVICE=jdg65-cluster
export CACHE_NAMES_LIST=carcache,stringCache,clustercache
export SOURCE_CLUSTER=jdg65-cluster
read -r -d '' REST_STORE_ELEM_ORIG << EOV
<rest-store path="/rest/cachename" shared="true" purge="false" passivation="false">
<connection-pool connection-timeout="60000" socket-timeout="60000" tcp-no-delay="true"/>
<remote-server outbound-socket-binding="remote-store-rest-server"/>
</rest-store>
EOV

declare -a CACHE_NAMES=("carcache" "stringCache" "clustercache")

for CACHE in "${CACHE_NAMES[@]}"
do
  echo "CACHE: ${CACHE}"
  echo "LINK to SOURCE CLUSTER (${REST_SERVICE})"
  # Replace 'cachename' with actual cachename
  REST_STORE_ELEM=${REST_STORE_ELEM_ORIG//cachename/${CACHE}}
  # echo ${CACHE} .... $REST_STORE_ELEM
  # Replace newline character with newline and two tabs (in escaped form)
  export REST_STORE_ELEM=${REST_STORE_ELEM//$'\n'/\\n\\t\\t}
  #echo ${CACHE} .... APPLY ... ${REST_STORE_ELEM}
  # sed pattern to locate cache definition

  PATTERN="<replicated-cache name=\"${CACHE}\""
  #MATCHES="TEST"
  #echo "PATTERN=${PATTERN}"
  #echo grep -r "\"${PATTERN}"\" $JDG_CONF
  #grep -r "\"${PATTERN}"\" $JDG_CONF
  #MATCHES=${grep -r "${PATTERN}" $JDG_CONF}
  #echo "MATCHES=${MATCHES}"

  #if grep -Fxq "${PATTERN}" ${JDG_CONF}
  #echo '---------------'
  #ls -la ${JDG_CONF}
  #PATTERN_FIND="\"<replicated-cache name=\\\"${CACHE}\"\\"\"
  #echo "PATTERN_FIND=${PATTERN_FIND}"
  #echo grep -r "\"<replicated-cache name=\\\"${CACHE}\"\\"\" ${JDG_CONF}
  #echo 1.
  #grep -r "\"<replicated-cache name=\\\"${CACHE}\"\\"\" /opt/datagrid/standalone/configuration/clustered-openshift.xml
  #echo 2.
  #grep -r "${PATTERN_FIND}" /opt/datagrid/standalone/configuration/clustered-openshift.xml
  #echo '---------------'
  #MATCHES=${grep -r "<replicated-cache name=\"clustercache\"" $JDG_CONF}
  #MATCHES=$(grep -r "<replicated-cache name=\"clustercache\"" $JDG_CONF )
  #MATCHES=$(grep -r "${PATTERN_FIND}" $JDG_CONF )
  #echo "------> ${MATCHES}"
 
  #if [ -z "$MATCHES" ]
  #echo $CACHE
  if [[ $CACHE != 'clustercache' ]];
  then
    DIST_CACHE_PATTERN="\(<distributed-cache[[:space:]]name=\"${CACHE}\"[^<]\+\)\(</distributed-cache>\)"
    # Add REST store definition to cache entry
    sed -i "s#${DIST_CACHE_PATTERN}#\1\n\t\t${REST_STORE_ELEM}\n\2#g" $JDG_CONF
    echo "--------------------"
    echo DIST sed -i "s#${DIST_CACHE_PATTERN}#\1\n\t\t${REST_STORE_ELEM}\n\2#g"
    echo "--------------------"
  else
    REPL_CACHE_PATTERN="\(<replicated-cache[[:space:]]name=\"${CACHE}\"[^<]\+\)\(</replicated-cache>\)"
    # Add REST store definition to cache entry
    sed -i "s#${REPL_CACHE_PATTERN}#\1\n\t\t${REST_STORE_ELEM}\n\2#g" $JDG_CONF
    echo "--------------------"
    echo REPL "s#${REPL_CACHE_PATTERN}#\1\n\t\t${REST_STORE_ELEM}\n\2#g"
    echo "--------------------"
  fi
done


# sed pattern to locate host / port settings for REST connector
REST_HOST_PATTERN="\(<remote-destination host=\"\)remote-host\(\" port=\"8080\"/>\)"
# Set host value to point to the Source Cluster
sed -i "s#${REST_HOST_PATTERN}#\1${REST_SERVICE}\2#g" $JDG_CONF
EOD

export JDG71_POD=$(oc get pods -o name | grep -Po "[^/]+$" | grep "jdg71" | grep -v "deploy")
echo 
echo "Move & Run Script to TARGET CLUSTER pod ${JDG71_POD}"
echo "oc rsync --no-perms=true update-cache/ $JDG71_POD:/tmp"
oc rsync --no-perms=true update-cache/ $JDG71_POD:/tmp
echo "oc rsh $JDG71_POD /bin/bash /tmp/add-rest-store-to-cache.sh"
oc rsh $JDG71_POD /bin/bash /tmp/add-rest-store-to-cache.sh

echo
echo "Check changes on /opt/datagrid/standalone/configuration/clustered-openshift.xml"
oc rsh $JDG71_POD cat /opt/datagrid/standalone/configuration/clustered-openshift.xml

oc rsh $JDG71_POD /opt/datagrid/bin/cli.sh --connect ':reload'

echo 'TARGET synced with SOURCE CLUSTER caches'
