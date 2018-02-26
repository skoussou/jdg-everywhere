#!/bin/bash
basedir=`dirname $0`
onprembasedir=$(cd $basedir && cd ../on-prem-setup && pwd)

pushd $basedir > /dev/null

echo "  - Starting Apache Spark master on localhost"
echo

#pushd target/spark-1.6* > /dev/null
sbin/start-master.sh --webui-port 7080 -h localhost > /dev/null &
#popd > /dev/null

#echo "  - Starting Apache Spark slave localhost"
#echo

#pushd target/spark-1.6* > /dev/null
#sbin/start-slave.sh spark://localhost:7077 > /dev/null &
#popd > /dev/null

SPARK_HOME=$(cd target/spark-* && pwd)
echo SPARK_HOME installed at $SPARK_HOME

echo "  - importing historical Posts, this may take a while"
echo
java -jar projects/stackexchange/importer/target/stackexchange-importer-full.jar $(pwd)/projects/stackexchange/Posts.xml > /dev/null

echo "  - importing historical Posts, this may take a while"
echo
java -jar projects/stackexchange/importer/target/stackexchange-importer-full.jar $(pwd)/projects/stackexchange/Users.xml > /dev/null

SPARK_HOME=$(cd target/spark-* && pwd)
echo "  - Submitting analytics job to spark master"
echo
$SPARK_HOME/bin/spark-submit --master spark://127.0.0.1:7077 --class org.jboss.datagrid.demo.stackexchange.RunAnalytics projects/stackexchange/spark-analytics/target/stackexchange-spark-analytics-full.jar "spark://127.0.0.1:7077" "127.0.0.1:11322;127.0.0.1:11422;127.0.0.1:11522"

popd > /dev/null
