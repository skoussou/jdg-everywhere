#!/bin/bash

basedir=`dirname $0`
onprembasedir=$(cd $basedir && cd ../on-prem-setup && pwd)

#echo $basedir
#echo "FINAL on onprembasedir=${onprembasedir}"
#exit

DEMO="JBoss Data Grid and Spark Analytics Demo"
AUTHORS="Thomas Qvarnstrom, Cojan van Ballegooijen, Stelios Kousouris Red Hat"
SRC_DIR=$basedir/installs

SPARK_INSTALL=spark-1.6.2-bin-hadoop2.6.tgz


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

# Verify that necesary files are downloaded
for DOWNLOAD in ${SOFTWARE[@]}
do
	if [[ -r $SRC_DIR/$DOWNLOAD || -L $SRC_DIR/$DOWNLOAD ]]; then
			echo $DOWNLOAD are present...
			echo
	else
			echo You need to download $DOWNLOAD from the Customer Support Portal
			echo and place it in the $SRC_DIR directory to proceed...
			echo
			exit
	fi
done


echo "  - Stopping any running Apache Spark slave instances"
echo
jps -lm | grep org.apache.spark.deploy.worker.Worker | grep -v grep | awk '{print $1}' | xargs kill > /dev/null

echo "  - Stopping any running Apache Spark master instances"
echo
jps -lm | grep org.apache.spark.deploy.master.Master | grep -v grep | awk '{print $1}' | xargs kill > /dev/null

#If JDG is running stop it
#echo "  - Stopping any running JBoss Data Grid (JDG) instances"
#echo
#jps -lm | grep jboss-datagrid | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null

#echo "  - Stopping any running JBoss Enterprise Application Platform (JBoss EAP) instances"
#echo
#jps -lm | grep jboss-eap | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null


sleep 2

# Create the target directory if it does not already exist.
if [ ! -d target ]; then
# 		echo "  - deleting existing target directory..."
# 		echo
# 		rm -rf target

		echo "  - creating the target directory..."
		echo
		mkdir target
fi

# Unzip the maven repo files
echo "  - Installing Apache Spark"
echo
tar -zxf $SRC_DIR/$SPARK_INSTALL -C target > /dev/null

SPARK_HOME=$(cd target/spark-* && pwd)
#EAP_HOME=$(cd $onprembasedir/target/jboss-eap-7* && pwd)

echo SPARK_HOME installed at $SPARK_HOME
#echo EAP_HOME installed at $EAP_HOME

echo "  - Starting Apache Spark master on localhost"
echo

pushd target/spark-1.6* > /dev/null
sbin/start-master.sh --webui-port 7080 -h localhost > /dev/null &
popd > /dev/null

echo "  - Starting Apache Spark slave localhost"
echo

pushd target/spark-1.6* > /dev/null
sbin/start-slave.sh spark://localhost:7077 > /dev/null &
popd > /dev/null

echo "  - Building the stackexchange project"
echo
pushd projects/stackexchange > /dev/null
mvn -q clean install || { echo >&2 "Failed to compile the stackexchange project"; exit 3; }
popd > /dev/null

# echo "  - Importing historical posts, this may take a while"
# echo
# java -jar projects/stackexchange/importer/target/stackexchange-importer-full.jar $(pwd)/projects/stackexchange/Posts.xml 

# echo "  - Importing users/blog authors, this may take a while"
# echo
# java -jar projects/stackexchange/importer/target/stackexchange-importer-full.jar $(pwd)/projects/stackexchange/Users.xml 

# echo "  - Submitting analytics job to spark master"
# echo
# $SPARK_HOME/bin/spark-submit --master spark://127.0.0.1:7077 --class org.jboss.datagrid.demo.stackexchange.RunAnalytics projects/stackexchange/spark-analytics/target/stackexchange-spark-analytics-full.jar

# echo "  - Waiting for EAP to become available"
# printf "  "
# until $($EAP_HOME/bin/jboss-cli.sh -c --controller=localhost:9990 --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
# do
#     sleep 1
#     printf "."
# done
# echo

# RELY on project being in place by on-prem-setup.sh
#echo "  - Deploy jdg-visualizer application"
#echo
#pushd projects/jdg-visualizer > /dev/null
#mvn -q wildfly:deploy
#popd > /dev/null






