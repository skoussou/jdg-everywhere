#!/bin/sh
DEMO="JBoss EAP SSO & JDG Http Session Externalization Demo"
AUTHORS="Serhat Dirik"
PROJECT="git@github.com:serhat-dirik/eap-sso.git"
PRODUCT="JBoss EAP & Data Grid"
VERSION=7.1
TARGET=$(pwd)/target
#INSTALL_DIR=$(pwd)/install
INSTALL_DIR=$(cd $(pwd) && cd ../on-prem-setup/installs && pwd)
EAP_PACK=jboss-eap-7.0.0.zip
JDG_PACK=jboss-datagrid-7.1.0-server.zip
EAP_HOME1=$TARGET/eap7-1
EAP_HOME2=$TARGET/eap7-2
EAP_TMP=$TARGET/jboss-eap-7.0
JDG_HOME=$TARGET/jboss-datagrid-7.1.0-server
CONFIG_DIR=$(pwd)/configuration
PRJ_DIR=$(pwd)/project

##############################################

# wipe screen.
clear

echo
echo "###################################################"
echo "##                                                  "
echo "##  Setting up the ${DEMO}                          "
echo "##  This demo is brought to you by ${AUTHORS}		                                "
echo "##                                                  "
echo "##  Source Code : ${PROJECT}                                      "
echo "##                                                  "
echo "####################################################"
echo

#command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.
echo "Installs "
echo "$(ls $INSTALL_DIR)  "
echo " can be found at $INSTALL_DIR"
echo

if [ -r $INSTALL_DIR/$EAP_PACK ] || [ -L $INSTALL_DIR/$EAP_PACK ]; then
	echo "  - JBoss EAP install packs are present..."
	echo
else
	echo "  - Need to download $EAP_PACK package from the Customer Portal"
	echo "  - and place it in the $INSTALL_DIR directory to proceed..."
	echo
	exit
fi

if [ -r $INSTALL_DIR/$JDG_PACK ] || [ -L $INSTALL_DIR/$JDG_PACK ]; then
	echo "  - JBoss JDG install packs are present..."
	echo
else
	echo "  - Need to download $JDG_PACK package from the Customer Portal"
	echo "  - and place it in the $INSTALL_DIR directory to proceed..."
	echo
	exit
fi

#If JDG/EAP is running stop it
echo "  - Stopping any running JBoss Data Grid (JDG) instances"
echo
jps -lm | grep jboss-datagrid | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null

echo "  - Stopping any running JBoss Enterprise Application Platform (JBoss EAP) instances"
echo
jps -lm | grep jboss-eap | grep -v grep | awk '{print $1}' | xargs kill  > /dev/null

# Remove the old target directory, if it exists.
if [ -x $TARGET ]; then
	echo "  - removing existing target directory..."
	echo
	rm -rf $TARGET
fi

#Install JDG
unzip -qo $INSTALL_DIR/$JDG_PACK -d $TARGET
if [ $? -ne 0 ]; then
	echo "  - Error occurred during $JDG_PACK installation!"
	exit
fi

echo
echo "  - configuring data grid ..."
echo "----------------------------------"
cp -rf $CONFIG_DIR/jdg/* $JDG_HOME/standalone/configuration

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $JDG_HOME/bin/standalone.sh

#Install EAP instance 1
unzip -qo $INSTALL_DIR/$EAP_PACK -d $TARGET

if [ $? -ne 0 ]; then
	echo Error occurred during $EAP_PACK installation!
	exit
fi
mkdir -p $EAP_HOME1
mv -f $EAP_TMP/* $EAP_HOME1
rm -rf $EAP_TMP

echo
echo "  - configuring eap instance 1 ..."
echo "----------------------------------"
echo
cp -rf $CONFIG_DIR/eap-7-1/* $EAP_HOME1/standalone/configuration/.

echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $EAP_HOME1/bin/standalone.sh

#Install EAP instance 2
unzip -qo $INSTALL_DIR/$EAP_PACK -d $TARGET
if [ $? -ne 0 ]; then
	echo Error occurred during $EAP_PACK installation!
	exit
fi
mkdir -p $EAP_HOME2
mv -f $EAP_TMP/* $EAP_HOME2
rm -rf $EAP_TMP

echo
echo "  - configuring eap instance 2 ..."
echo "----------------------------------"
cp -rf $CONFIG_DIR/eap-7-2/* $EAP_HOME2/standalone/configuration/.
echo "  - making sure standalone.sh for server is executable..."
echo
chmod u+x $EAP_HOME2/bin/standalone.sh


echo
echo "  - Building sso-demo application to EAP instances........"
echo "----------------------------------------------------------"
echo
pushd $PRJ_DIR > /dev/null
mvn -q clean install || { echo >&2 "Failed to compile the sso-demo project"; exit 3; }
popd > /dev/null
echo "COPY Binary sso-demo.war to  $INSTALL_DIR"
cp $PRJ_DIR/target/sso-demo.war $INSTALL_DIR
echo

echo
echo "  - Deploying sso-demo application to EAP instances........"
echo "----------------------------------------------------------"

cp $INSTALL_DIR/sso-demo.war $EAP_HOME1/standalone/deployments/sso-app1.war
touch $EAP_HOME1/standalone/deployments/sso-app1.war.dodeploy
cp $INSTALL_DIR/sso-demo.war $EAP_HOME2/standalone/deployments/sso-app2.war
touch $EAP_HOME2/standalone/deployments/sso-app2.war.dodeploy

echo "$JDG_HOME/bin/standalone.sh" > $TARGET/startJDG.sh

echo "$EAP_HOME1/bin/standalone.sh" > $TARGET/startEAP1.sh

echo "$EAP_HOME2/bin/standalone.sh" > $TARGET/startEAP2.sh
chmod +x $TARGET/start*.sh

echo
echo "###################################################"
echo "##"
echo "## Your demo is successfully prepared !! "
echo "## "
echo "## Now start your JBOSS Data Grid instance with:                                                   "
echo "##  $TARGET/startJDG.sh     "
echo "##"
echo "## Please make sure that JDG is up & running before starting EAP instances!"
echo "##"
echo "## You have two standalone EAP instances."
echo "## Start your JBOSS EAP instance 1 with:                                              "
echo "##  $TARGET/startEAP1.sh "
echo "##"
echo "## Start your JBOSS EAP instance 2 with: "
echo "##  $TARGET/startEAP2.sh "
echo "## "
echo "## "
echo "## Demo Pages on EAP Instances:                                                                   "
echo "## "
echo "## http://localhost:8081/sso-app1                                                                  "
echo "## http://localhost:8082/sso-app2                                                                  "
echo "## "
echo "## "
echo "## For more realistic scenario add the following domains in your /etc/hosts file"
echo "## "
echo "## 127.0.0.1   domain1.redhat.com "
echo "## 127.0.0.1   domain2.redhat.com "
echo "## "
echo "## "
echo "## http://domain1.redhat.com:8081/sso-app1                                                                  "
echo "## http://domain2.redhat.com:8082/sso-app2                                                                  "
echo "## "
echo "## Enjoy your demo !!"
echo "###################################################"
