#!/bin/bash
basedir=`dirname $0`


DEMO="Setting Up JDG On Premise 3-Node Cluster and EAP for User End Apps"
AUTHORS="Stelios Kousouris Red Hat"
SRC_DIR=$basedir/installs

#SPARK_INSTALL=spark-1.6.2-bin-hadoop2.6.tgz
JDG_INSTALL=jboss-datagrid-7.1.0-server.zip
EAP_INSTALL=jboss-eap-7.0.0.zip

SOFTWARE=($JDG_INSTALL $EAP_INSTALL)


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


#If JDG is running stop it
echo "  - Stopping any running JBoss Data Grid (JDG) instances"
echo
jps -lm | grep jboss-datagrid | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null

echo "  - Stopping any running JBoss Enterprise Application Platform (JBoss EAP) instances"
echo
jps -lm | grep jboss-eap | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null


sleep 2

# Create the target directory if it does not already exist.
if [ ! -d target ]; then
   echo "  - creating the target directory..."
   echo
   mkdir target
fi

# Unzip the maven repo files
echo "  - Installing JDG"
JDG_EXISTS=$(cd target && find -name jboss-datagrid-7*)
echo JDG_EXISTS=$JDG_EXISTS
if [ -z JDG_EXISTS ]; then
   echo
   unzip -q -d target $SRC_DIR/$JDG_INSTALL
else
   echo "  - JDG already installed at $JDG_EXISTS"
fi

JDG_HOME=$(cd target/jboss-datagrid-7* && pwd)

echo "  - Configuring JDG"
echo
$JDG_HOME/bin/add-user.sh -s -u admin -p admin-123
$JDG_HOME/bin/add-user.sh -a -u admin -p admin-123 -r ApplicationRealm -s
#$JDG_HOME/bin/cli.sh --file=support/datagrid-setup.cli > /dev/null

echo
echo
echo "*************************************"
echo " Following command should be run in each project to setup relevant caches OR ALL Possible known caches added here"
echo "$JDG_HOME/bin/cli.sh --file=support/datagrid-setup-standalone.cli > /dev/null"
echo "*************************************"
$JDG_HOME/bin/cli.sh --file=support/datagrid-setup-standalone.cli > /dev/null

if [ ! -d $JDG_HOME/standalone1 ]; then
   echo "  - creating new JDG Runtime directory...standalone1"
   cp -r $JDG_HOME/standalone $JDG_HOME/standalone1
fi
if [ ! -d $JDG_HOME/standalone2 ]; then
   echo "  - creating new JDG Runtime directory...standalone2"
   cp -r $JDG_HOME/standalone $JDG_HOME/standalone2
fi
if [ ! -d $JDG_HOME/standalone3 ]; then
   echo "  - creating new JDG Runtime directory...standalone3"
   cp -r $JDG_HOME/standalone $JDG_HOME/standalone3
fi


echo "  - Starting JDG"
echo

pushd target/jboss-datagrid-7*/bin > /dev/null
export JAVA_OPTS="-Xms128m -Xmx384m -Xss2048k"
#./domain.sh > /dev/null &
./standalone.sh -c clustered.xml -Djboss.server.base.dir=$JDG_HOME/standalone1 -Djboss.node.name=jdg-1 -Djboss.socket.binding.port-offset=100 -Djgroups.bind_addr=127.0.0.1 -Djava.net.preferIPv4Stack=true > /dev/null &
./standalone.sh -c clustered.xml -Djboss.server.base.dir=$JDG_HOME/standalone2 -Djboss.node.name=jdg-2 -Djboss.socket.binding.port-offset=200 -Djgroups.bind_addr=127.0.0.1 -Djava.net.preferIPv4Stack=true > /dev/null &
./standalone.sh -c clustered.xml -Djboss.server.base.dir=$JDG_HOME/standalone3 -Djboss.node.name=jdg-3 -Djboss.socket.binding.port-offset=300 -Djgroups.bind_addr=127.0.0.1 -Djava.net.preferIPv4Stack=true > /dev/null &
popd > /dev/null


echo "  - Waiting for server1 to become available"
printf "  "
until $($JDG_HOME/bin/cli.sh --controller=localhost:10090 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    printf "."
done

echo
echo "  - Waiting for server2 to become available"
printf "  "
until $($JDG_HOME/bin/cli.sh --controller=localhost:10190 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    printf "."
done
echo

echo "  - Waiting for server3 to become available"
printf "  "
until $($JDG_HOME/bin/cli.sh --controller=localhost:10290 -c --command=":read-attribute(name=server-state)" | grep result | grep running > /dev/null)
do
    sleep 1
    printf "."
done
echo

# echo "  - waiting for all servers to become available"
# until $($JDG_HOME/bin/cli.sh -c --command="/host=master/server=server-one:read-attribute(name=server-state)" | grep result | grep running > /dev/null)
# do
#     sleep 1
#     printf "."
# done
# until $($JDG_HOME/bin/cli.sh -c --command="/host=master/server=server-two:read-attribute(name=server-state)" | grep result | grep running > /dev/null)
# do
#     sleep 1
#     printf "."
# done
# until $($JDG_HOME/bin/cli.sh -c --command="/host=master/server=server-three:read-attribute(name=server-state)" | grep result | grep running > /dev/null)
# do
#     sleep 1
#     printf "."
# done

echo "  - Installing JBoss EAP"
echo

EAP_EXISTS=$(cd target && find -name jboss-datagrid-7*)
echo EAP_EXISTS=$EAP_EXISTS
if [ -z EAP_EXISTS ]; then
   echo
   unzip -q -d target $SRC_DIR/$EAP_INSTALL
else
   echo "  - EAP already installed at $EAP_EXISTS"
fi


EAP_HOME=$(cd target/jboss-eap-7* && pwd)


if [ -z EAP_EXISTS ]; then
  echo "  - Configuring JBoss EAP"
  echo
  $EAP_HOME/bin/add-user.sh -s -u admin -p admin-123 -s
  $EAP_HOME/bin/add-user.sh -a -u admin -p admin-123 -r ApplicationRealm -s
  $EAP_HOME/bin/jboss-cli.sh --file=support/jboss-eap-7-visualizer-config.cli  > /dev/null || { echo >&2 "Failed to configure JBoss EAP 7. Aborting"; exit 7; }
fi

echo "  - Starting JBoss EAP"
echo
export JAVA_OPTS="-Xms256m -Xmx1024m"
pushd target/jboss-eap-7*/bin > /dev/null
./standalone.sh -b 0.0.0.0  -Djdg.visualizer.jmxUser=admin -Djdg.visualizer.jmxPass=admin-123 -Djdg.visualizer.serverList=localhost:11322\;localhost:11422\;localhost:11522 > /dev/null &
popd > /dev/null

echo "  - Building the jdg-visualizer project"
echo
pushd projects/jdg-visualizer > /dev/null
mvn -q clean install || { echo >&2 "Failed to compile the jdg-visualizer project"; exit 3; }
popd > /dev/null

echo "  - Deploy jdg-visualizer application"
echo
pushd projects/jdg-visualizer > /dev/null
mvn -q wildfly:deploy
popd > /dev/null

echo "  - Deploy visualizer application"
echo
pushd projects/stackexchange/visualizer > /dev/null
mvn -q wildfly:deploy
popd > /dev/null
