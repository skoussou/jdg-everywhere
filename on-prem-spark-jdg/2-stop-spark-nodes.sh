#!/bin/bash

echo "  - Stopping any running Apache Spark slave instances"
echo
jps -lm | grep org.apache.spark.deploy.worker.Worker | grep -v grep | awk '{print $1}' | xargs kill > /dev/null

echo "  - Stopping any running Apache Spark master instances"
echo
jps -lm | grep org.apache.spark.deploy.master.Master | grep -v grep | awk '{print $1}' | xargs kill > /dev/null
