#!/usr/bin/env bash

LABEL=$1

echo "Deleting object with label ${LABEL}"
oc delete all -l $LABEL
