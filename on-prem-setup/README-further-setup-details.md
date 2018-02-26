ISSUES
================================
Cluster not forming and getting errors

2018-02-06 12:03:28,732 ERROR [org.jgroups.protocols.UDP] (jgroups-6,jdg-1) JGRP000029: jdg-1: failed sending message to cluster (84 bytes): java.io.IOException: Network is unreachable, headers: STABLE: [STABILITY] view-id= [jdg-1|0], TP: [cluster_name=cluster]

SOLUTION: added JGRoups bind address in all JDG servers startup -Djgroups.bind_addr=127.0.0.1

 1008  ./standalone.sh -c clustered.xml -Djboss.server.base.dir=../standalone1 -Djboss.node.name=jdg-1 -Djboss.socket.binding.port-offset=100 -Djgroups.bind_addr=127.0.0.1 -Djava.net.preferIPv4Stack=true > /dev/null &
 1009  ./standalone.sh -c clustered.xml -Djboss.server.base.dir=../standalone2 -Djboss.node.name=jdg-2 -Djboss.socket.binding.port-offset=200 -Djgroups.bind_addr=127.0.0.1 -Djava.net.preferIPv4Stack=true > /dev/null &
 1010  ./standalone.sh -c clustered.xml -Djboss.server.base.dir=../standalone3 -Djboss.node.name=jdg-3 -Djboss.socket.binding.port-offset=300 -Djgroups.bind_addr=127.0.0.1 -Djava.net.preferIPv4Stack=true > /dev/null 


================================
UTILITIES: PROBE

Use Probe.sh from inside the JDG JAR
java -classpath ./system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe --help

To access STACK need to enable diagnostics (https://developer.jboss.org/thread/232631) so added 
<transport type="UDP" socket-binding="jgroups-udp" diagnostics-socket-binding="jgroups-diagnostics"/>

...

<socket-binding name="jgroups-diagnostics" port="0" multicast-address="230.0.0.4" multicast-port="7500"/>


#Find all datagrid processes
jps -lm | grep jboss-datagrid | grep -v grep | awk '{print $1}'

================================
Using probe.sh to create SPLIT BRAIN

# get all members in the cluster
java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost addrs

# print current member protocols
java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost print-protocols

#1 (215 bytes):
local_addr=jdg-3 [ip=127.0.0.1:55500, version=4.0.1.Final (Schiener Berg), cluster=cluster, 1 mbr(s)]
protocols=UDP
PING
MERGE3
FD_SOCK
FD_ALL
VERIFY_SUSPECT
NAKACK2
UNICAST3
STABLE
GMS
UFC
MFC
FRAG3
FORK


# add in the stack for this member DISCARD protocol
java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP

#1 (215 bytes):
local_addr=jdg-3 [ip=127.0.0.1:55500, version=4.0.1.Final (Schiener Berg), cluster=cluster, 1 mbr(s)]
protocols=UDP
DISCARD
PING
MERGE3
FD_SOCK
FD_ALL
VERIFY_SUSPECT
NAKACK2
UNICAST3
STABLE
GMS
UFC
MFC
FRAG3
FORK


# check DISCARD protocol configuration
java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD

#1 (348 bytes):
local_addr=jdg-3 [ip=127.0.0.1:55500, version=4.0.1.Final (Schiener Berg), cluster=cluster, 3 mbr(s)]
DISCARD={after_creation_hook=null, discard_all=false, down=0.0, drop_down_multicasts=0, drop_down_unicasts=0, dropped_down_messages=0, dropped_up_messages=0, ergonomics=true, excludeItself=true, gui=false, id=26, level=null, stats=true, up=0.0}

# Set the parameter to discard ALL messages (up/down ... another option to test is to set either up or down too 100.0, also Bela said use_gui="true" and you can discard messages from a subset of the cluster member, too.)
java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true

OR (although slower it seems for FD and MERGET when set back to 0.0 to take place)
 1203  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.down=100.0
 1208  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.up=100.0



#1 (347 bytes):
local_addr=jdg-3 [ip=127.0.0.1:55500, version=4.0.1.Final (Schiener Berg), cluster=cluster, 3 mbr(s)]
DISCARD={after_creation_hook=null, discard_all=true, down=0.0, drop_down_multicasts=0, drop_down_unicasts=0, dropped_down_messages=0, dropped_up_messages=0, ergonomics=true, excludeItself=true, gui=false, id=26, level=null, stats=true, up=0.0}

# Check members again 
java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost addrs

#1 (125 bytes):
local_addr=jdg-3 [ip=127.0.0.1:55500, version=4.0.1.Final (Schiener Berg), cluster=cluster, 1 mbr(s)]
addrs=127.0.0.1:55500


PARTITION-HANDLING SCENARIOS
--------------------------------

Scenario 1:
-----------
a) create distributed cache (added to the clustered.xml of the jboss-datagrid-spark-analytics-demo) and client to add entries (imitate the importer project OR expand the UI to be able to do so (considerations on members 2 probably)
b) create partition (without partition-handling settings in cache)
c) check status of partition
d) Now update entries on the cache (only in the nodes not left the cluster) ... retrieve the value ... ie. incosistency 
e) try to also update the value in the node that is NOT part of the cluster ... retrieve the value ... ie. further incosistency
f) rejoin the cluster ... check the value (could versioned API help? ... is versioned API only working in library)

Scenario 2:
-----------
a) create distributed cache (added to the clustered.xml of the jboss-datagrid-spark-analytics-demo) WITH PARTITION HANDLING configuration and client to add entries (imitate the importer project OR expand the UI to be able to do so (considerations on members 2 probably)
b) create partition (use PROBE and then see if also can use jgroups-4.0.10.Final.jar INJECT_VIEW based on http://belaban.blogspot.ch/2018/01/injecting-split-brain-into-jgroups.html)
c) check status of partition .... what are the differences AP, CP 
   - AP .... available & partitioned ... some incosistencies will be possible ... when should you use?  (CONSOLE should show ENABLED)
   - CP ..... consistency & partitioned ... DEGRADED ... possible to READ but not to write (CONSOLE should show DEGRADED)

================================


Trying to get forced partition configuration working using protocol INJECT_VIEW based on http://belaban.blogspot.ch/2018/01/injecting-split-brain-into-jgroups.html

Bela said: 4.0.1 and 4.0.10 should be compatible, so simply replace JGroups in JDG with 4.0.10.


1. Downloaded from http://central.maven.org/maven2/org/jgroups/jgroups/4.0.10.Final/  JAR jgroups-4.0.10.Final.jar  
2. Copied it into /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/modules/system/layers/base/org/jgroups/main/module.xml jboss-datagrid-7.1.0-server/modules/system/layers/base/org/jgroups/main
where now I have 
-rw-rw-r-- 1 stkousso stkousso 2264217 Feb  7 09:11 jgroups-4.0.10.Final.jar
-rw-rw-r-- 1 stkousso stkousso 2196956 Apr  7  2017 jgroups-4.0.1.Final-redhat-1.jar
-rw-rw-r-- 1 stkousso stkousso     387 Apr  7  2017 module.xml


3. replaced in ${JDG_HOME}/module.xml jgroups-4.0.1.Final-redhat-1.jar for jgroups-4.0.10.Final.jar
<?xml version="1.0" encoding="UTF-8"?>

<module xmlns="urn:jboss:module:1.3" name="org.jgroups">

    <resources>
        <!--resource-root path="jgroups-4.0.1.Final-redhat-1.jar"/-->
        <resource-root path="jgroups-4.0.10.Final.jar"/>
    </resources>

    <dependencies>
        <module name="javax.api"/>
        <module name="org.jgroups.extension"/>
        <module name="org.jboss.sasl" services="import" />
    </dependencies>
</module>

4. 
