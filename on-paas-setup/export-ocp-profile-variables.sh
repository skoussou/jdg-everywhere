#!/usr/bin/env bash

OCP_PROFILE_NAME=$1
OCP_PROFILE_BASE_DIR=$2

#######################################
# USAGE 
#
# source export-ocp-profile-variables.sh BRMS-ON-OCP /home/stkousso/Stelios/sw10/PAAS/Training/OCP-Storage/oc/profiles
#
#######################################
export OCPprofileDataDir=$OCP_PROFILE_BASE_DIR/$OCP_PROFILE_NAME/data
export OCPprofileConfigDir=$OCP_PROFILE_BASE_DIR/$OCP_PROFILE_NAME/config


echo $OCP_PROFILE_NAME 'OCP Profile Data stored at' $OCPprofileDataDir
echo $OCP_PROFILE_NAME 'OCP Profile Config for stored at' $OCPprofileConfigDir

echo 'Also running command: iptables -F'
iptables -F
