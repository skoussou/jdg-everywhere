# SPARK/JDG Analytics DEMO 

This demo shows how to JBoss Data Grid integration with Spark is work. It also uses Zeppelin to show nice reports.

## Setup
--------------
To setup the infrastructure for the demo download the follwoing files to the *installs* directory:

* [spark-1.6.2-bin-hadoop2.6.tgz](http://www.apache.org/dyn/closer.lua/spark/spark-1.6.2/spark-1.6.2-bin-hadoop2.6.tgz)

## Pre-Requisites
--------------
1. *on-prem-setup* script _*./init-onprem.sh*_ under directory *on-prem-setup* must have run to start EAP & JDG Nodes
2. script above must have be running *jdg-everywhere/on-prem-setup/support/jboss-eap-7-visualizer-config.cli_* generating *PartitionScenarios* cache


## Run the demo

The following scripts have been provided to run the demo and check results at http://localhost:8080/visualizer/ caches
- HighestAnalyticsStore
- KeyWordAnalyticsStore

* Kick-off Spark installation & Start the spark nodes

$ ./0-setup-spark-binaries.sh

* Import Data & run analytics

$ ./1-import-data-run-analytics.sh

* Stop Spark Nodes

$ ./2-stop-spark-nodes.sh


