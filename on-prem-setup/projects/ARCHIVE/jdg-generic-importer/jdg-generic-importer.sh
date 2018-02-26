#!/bin/bash
basedir=`dirname $0`
op=$1
cache=$2
file=$3

pushd $basedir > /dev/null

echo "  - importing or exporting KeyPairs this may take a while"
echo
echo java -jar ./target/jdg-generic-importer-full.jar $op $cache $(pwd)/$file
echo
java -jar ./target/jdg-generic-importer-full.jar $op $cache $(pwd)/$file > /dev/null

