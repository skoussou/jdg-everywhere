#!/bin/bash
basedir=`dirname $0`


DEMO="JBoss Data Grid and Spark Analytics Demo"
AUTHORS="Thomas Qvarnstrom, Cojan van Ballegooijen Red Hat"
SRC_DIR=$basedir/installs

#SPARK_INSTALL=spark-1.6.2-bin-hadoop2.6.tgz
JDG_INSTALL=jboss-datagrid-7.1.0-server.zip
#ZEPPELIN_INSTALL=zeppelin-0.6.0-bin-all.tgz

SOFTWARE=($SPARK_INSTALL $JDG_INSTALL)


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
mvn -v -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

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
echo "  - stopping any running datagrid instances"
echo
jps -lm | grep jboss-datagrid | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null

echo "  - stopping any running jboss eap instances"
echo
jps -lm | grep jboss-eap | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null

sleep 2
echo

echo
echo
echo "WARNING: Answering yes to the following will now delete the on-prem-setup directories"
echo ======================================================================================
echo
echo "Do you wish to remove EAP & 3 JDG Node directories"
echo
echo "[yes/no]"
read answer
echo

if [ $answer == "yes" ]; then
  echo "You have answerd $answer to deleting EAP & 3 JDG Nodes"
  echo
  echo "Please confirm"
  echo "[yes/no]"
  read confirmation
  if [ $confirmation == "yes" ]; then
     	echo "  - deleting existing target directory..."
  	echo
      	rm -rf target
  fi
else
  echo "We will not be deleting anything"
fi
