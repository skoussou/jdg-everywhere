#!/bin/bash

basedir=`dirname $0`
onprembasedir=$(cd $basedir && cd ../on-prem-setup && pwd)

#echo $basedir
#echo "FINAL on onprembasedir=${onprembasedir}"
#exit

DEMO="JBoss Data Grid and Split Brain Demo"
AUTHORS="Stelios Kousouris Red Hat"

#SRC_DIR=$basedir/installs
#SPARK_INSTALL=spark-1.6.2-bin-hadoop2.6.tgz


# wipe screen.
clear

echo

ASCII_WIDTH=52

printf "##  %-${ASCII_WIDTH}s  ##\n" | sed -e 's/ /#/g'
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n" "Setting up the ${DEMO}"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n" "    # ####   ###   ###  ###   ###   ###"
printf "##  %-${ASCII_WIDTH}s  ##\n" "    # #   # #   # #    #      #  # #"
printf "##  %-${ASCII_WIDTH}s  ##\n" "    # ####  #   #  ##   ##    #  # #  ##"
printf "##  %-${ASCII_WIDTH}s  ##\n" "#   # #   # #   #    #    #   #  # #   #"
printf "##  %-${ASCII_WIDTH}s  ##\n" " ###  ####   ###  ###  ###    ###   ###"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n" "brought to you by,"
printf "##  %-${ASCII_WIDTH}s  ##\n" "${AUTHORS}"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n"
printf "##  %-${ASCII_WIDTH}s  ##\n" | sed -e 's/ /#/g'

echo
echo "Setting up the ${DEMO} environment..."
echo

# Check that java is installed and on the path
java -version 2>&1 | grep "java version" | grep 1.8 > /dev/null || { echo >&2 "Java 1.8 is required but not installed... aborting."; exit 1; }

# Check that maven is installed and on the path
mvn -v -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 2; }

EAP_HOME=$(cd $onprembasedir/target/jboss-eap-7* && pwd)
JDG_HOME=$(cd $onprembasedir/target/jboss-datagrid-7* && pwd)


# Check EAP at 127.0.0.1:9990 is running
printf "  "
until $($EAP_HOME/bin/jboss-cli.sh --controller=localhost:9990 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    echo "  - Waiting for EAP server to become available"
done
echo "  - EAP Status - Running"

# Check JDG nodes at 127.0.0.1:10090|10190|10290 are running
printf "  "
until $($JDG_HOME/bin/cli.sh --controller=localhost:10090 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    echo "  - Waiting for JDG Node 1 to become available"
done
echo "  - JDG Node 1 Status - Running"

printf "  "
until $($JDG_HOME/bin/cli.sh --controller=localhost:10190 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    echo "  - Waiting for JDG Node 2 to become available"
done
echo "  - JDG Node 2 Status - Running"

printf "  "
until $($JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    echo "  - Waiting for JDG Node 3 to become available"
done
echo "  - JDG Node 3 Status - Running"

echo
echo "  - Building the jdg-generic-importer project"
echo
pushd projects/jdg-generic-importer > /dev/null
mvn -q clean install || { echo >&2 "Failed to compile the jdg-generic-importer project"; exit 3; }
popd > /dev/null

echo ============================================================== 
echo TO SHOWCASE
echo ==============================================================

sleep 2

echo "Open in a browser window the following consoles"
echo
echo "at URL: http://localhost:8080/visualizer/ Select From the dropdown list Cache PartitionScenarios"
echo 
sleep 5

echo "check that there are 3 JDG Nodes at "
sleep 1
echo "127.0.0.1:13222"
sleep 1
echo "127.0.0.1:14222"
sleep 1
echo "127.0.0.1:15222"

echo
echo "Check Stats and Cache Status (Activated) at"
echo
echo "http://localhost:10090/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios"
sleep 1
echo "http://localhost:10190/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios"
sleep 1
echo "http://localhost:10290/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios"
sleep 4
echo 
echo 
echo "Check cluster status at"
echo
echo "http://localhost:10090/console/index.html#/server-groups/default"
sleep 2

echo
echo
echo "Open 3 terminals to follow JDG Nodes (1-3) logs"
echo
echo "tail -n 100 -f $JDG_HOME/standalone1/log/server.log"
echo "tail -n 100 -f $JDG_HOME/standalone2/log/server.log"
echo "tail -n 100 -f $JDG_HOME/standalone3/log/server.log"
sleep 5



echo
echo
echo
echo
echo
echo
echo
echo ============================================================== 
echo START GRID DATA ENTRY
echo ==============================================================
echo

sleep 2
$curdir=$(cd $basedir && pwd)
echo "Open Terminal at $curdir and run following JDG PUT/GET Requests"
echo
echo 
echo "check that there are NO values in the whole cluster"
echo "----------------------------------------------------------------------------------------------------"
echo
echo "java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list=127.0.0.1:11322"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
echo 
echo 
sleep 7
echo "enter k1, k2, k3 into cluster as follows ..."
echo "----------------------------------------------------------------------------------------------------"
echo
echo "java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-1:v-1 server-list=127.0.0.1:11422"
echo "java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-2:v-1 server-list=127.0.0.1:11522"
echo "java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-3:v-1 server-list=127.0.0.1:11322"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-1:v-1 server-list="127.0.0.1:11422"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-2:v-1 server-list="127.0.0.1:11522"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-3:v-1 server-list="127.0.0.1:11322"
sleep 2
echo
echo 
echo 
echo "check values are entered in the whole cluster"
echo "----------------------------------------------------------------------------------------------------"
echo
echo "java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list=127.0.0.1:11522"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
echo 
echo "Also check at http://localhost:8080/visualizer/ that values are in the nodes"
sleep 7

echo 
echo
echo
echo ============================================================== 
echo INITIATE GRID SPLIT-BRAIN
echo ==============================================================
echo
echo Adding JGROUPs diagnostics socket binding to JDG Node 3
echo "-------------------------------------------------------"
echo
$JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command="/socket-binding-group=standard-sockets/socket-binding=jgroups-diagnostics:add(port=0, multicast-address=230.0.0.4, multicast-port=7500)" | grep result | grep running > /dev/null
$JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command="/subsystem=datagrid-jgroups/stack=udp/transport=UDP:write-attribute(name=diagnostics-socket-binding, value=jgroups-diagnostics)" | grep result | grep running > /dev/null

$JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command="/subsystem=datagrid-jgroups/stack=udp/protocol=FD_ALL:write-attribute(name=properties.interval, value=2000)"  | grep result | grep running > /dev/null
$JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command="/subsystem=datagrid-jgroups/stack=udp/protocol=FD_ALL:write-attribute(name=properties.timeout, value=5000)"  | grep result | grep running > /dev/null
$JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command="/subsystem=datagrid-jgroups/stack=udp/protocol=VERIFY_SUSPECT/property=timeout:add(value=1000)"  | grep result | grep running > /dev/null

$JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command=":reload" | grep result | grep running > /dev/null


echo 
echo "----------------------------------------------------------------------------------------------------"
echo "Open Terminal at $JDG_HOME and run probe JGROUPs utility to check the UDP stack and cause split-brain"
echo "----------------------------------------------------------------------------------------------------"
echo
echo
echo "Using probe Check current JGROUPs configuration (Requires jgroups-diagnostics to be setup, see $JDG_HOME/standalone3/configuration/clustered.xml"
echo "----------------------------------------------------------------------------------------------------"
echo "java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost protocols"
java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost print-protocols
echo
echo
echo
echo 
sleep 2
echo "Insert DISCARD protocol & check protocol stack"
echo "-----------------------------------------------"
echo
echo "java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP"
java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP
echo
echo
echo "java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost protocols"
java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost print-protocols
sleep 2
echo
echo
echo
echo "Set for JDG Node 3 to discard all mesages and CLUSTER To split"
echo "----------------------------------------------------------"
echo
echo "java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true"
java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true
echo
echo

sleep 5

echo
echo
echo ============================================================== 
echo CHECK SPLIT-BRAIN
echo "Check at http://localhost:8080/visualizer/ and consoles that cluster has split"
echo "Check at http://localhost:10290/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios cache status (DEGRADED)"
echo ==============================================================
echo
sleep 7
echo
echo
echo "Try to modify values to split cluster"
echo "-----------------------------------------------"
echo
echo "Node 3 changes"
echo "--------------"
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-2:v-3 server-list="127.0.0.1:11522"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-2:v-3 server-list="127.0.0.1:11522"
sleep 3
echo
echo
echo
echo "Node 2 changes"
echo "--------------"
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-1:v-2 server-list="127.0.0.1:11422"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-1:v-2 server-list="127.0.0.1:11422"
sleep 3
echo
echo
echo "Node 1 changes"
echo "--------------"
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-2:v-4 server-list="127.0.0.1:11322"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-2:v-4 server-list="127.0.0.1:11322"
sleep 3
echo
echo
echo "Node 3 changes"
echo "--------------"
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-5:v-1 server-list="127.0.0.1:11322"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar command-line k-5:v-1 server-list="127.0.0.1:11322"
sleep 3
echo
echo
echo "check values are entered in the either side of the split cluster"
echo "----------------------------------------------------------------"
echo
echo
echo "Node 1"
echo "-------"
echo
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
sleep 3
echo
echo
echo "Node 2"
echo "-------"
echo
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"
sleep 3
echo
echo
echo "Node 3"
echo "-------"
echo
echo java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
sleep 3


echo
echo
echo 
echo ==============================================================
echo REMERGE SPLIT CLUSTER
echo ==============================================================
echo "Eventually re-merge the cluster by executing java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=false"
java -classpath $JDG_HOME/modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=false

COUNTER=0
         while [  $COUNTER -lt 20 ]; do
              sleep 1
              printf "."
              let COUNTER=COUNTER+1 
         done

echo "check values are entered in the either side of the split cluster"
echo "----------------------------------------------------------------"
echo
echo
echo "Node 1"
echo "-------"
echo
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
sleep 3
echo
echo
echo "Node 2"
echo "-------"
echo
echo java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"
sleep 3
echo
echo
echo "Node 3"
echo "-------"
echo
echo java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
java -jar ./projects/jdg-generic-importer/target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
sleep 3

#c) /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/bin
#     ./cli.sh --controller=127.0.0.1:10090 -c
#     ./cli.sh --controller=127.0.0.1:10190 -c
#     ./cli.sh --controller=127.0.0.1:10290 -c
#     :reload (when changing configurations

#d) /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/bin
#   PROBE UTILITY
#   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP
#   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true
#   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=false
#   or   
#   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP
#   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true
#   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=false

#e) consoles
#   http://localhost:8080/visualizer/
#   http://localhost:10090/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios
#   http://localhost:10190/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios
#   http://localhost:10290/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios
#   http://localhost:10090/console/index.html#/server-groups/default
#   http://localhost:10290/console/index.html#/server-groups/default





















