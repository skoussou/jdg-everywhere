PARTITION-HANDLING SCENARIOS
--------------------------------

cd /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/bin
export JDG_HOME=/home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server
./standalone.sh -c clustered.xml -Djboss.server.base.dir=$JDG_HOME/standalone1 -Djboss.node.name=jdg-1 -Djboss.socket.binding.port-offset=100 -Djgroups.bind_addr=127.0.0.1 > /dev/null &
./standalone.sh -c clustered.xml -Djboss.server.base.dir=$JDG_HOME/standalone2 -Djboss.node.name=jdg-2 -Djboss.socket.binding.port-offset=200 -Djgroups.bind_addr=127.0.0.1 > /dev/null &
./standalone.sh -c clustered.xml -Djboss.server.base.dir=$JDG_HOME/standalone3 -Djboss.node.name=jdg-3 -Djboss.socket.binding.port-offset=300 -Djgroups.bind_addr=127.0.0.1 > /dev/null &


$($EAP_HOME/bin/jboss-cli.sh -c --controller=localhost:9990 --command=":read-attribute(name=server-state) " | grep result | grep running > /dev/null)
cd /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-eap-7.0/bin
./standalone.sh -b 0.0.0.0  -Djdg.visualizer.jmxUser=admin -Djdg.visualizer.jmxPass=admin-123 -Djdg.visualizer.serverList=localhost:11322\;localhost:11422\;localhost:11522 > /dev/null &


Scenario 1:
-----------
a) create distributed cache 
   - added to the clustered.xml of the jboss-datagrid-spark-analytics-demo
   - it has to have the diagnostics-socket-binding="jgroups-diagnostics" enabled with appropriate port
        * To access STACK need to enable diagnostics (https://developer.jboss.org/thread/232631) so added 
        * <transport type="UDP" socket-binding="jgroups-udp" diagnostics-socket-binding="jgroups-diagnostics"/>
        * <socket-binding name="jgroups-diagnostics" port="0" multicast-address="230.0.0.4" multicast-port="7500"/>
         /] /socket-binding-group=standard-sockets/socket-binding=jgroups-diagnostics:add(port=0, multicast-address=230.0.0.4,multicast-port=7500)
         /subsystem=datagrid-jgroups/stack=udp/transport=UDP:write-attribute(name=diagnostics-socket-binding, value=jgroups-diagnostics)
         reload
   - owners = 2
   - segments = 30 (3 * 10)
   - FAILURED DETECTION/RE-MERGE maybe tuned to be a bit faster (currently takes a couple of minutes)

 and client to add entries (imitate the importer project OR expand the UI to be able to do so (considerations on members 2 probably)

ENTRIES TO ENTER
-----------------
java -jar ./target/jdg-generic-importer-full.jar command-line stelios-1:value-1 server-list="127.0.0.1:11522"
java -jar ./target/jdg-generic-importer-full.jar command-line roger-1:value-1 server-list="127.0.0.1:11522"
java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-1 server-list="127.0.0.1:11422"

java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"
java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"



b) create partition (without partition-handling settings in cache)
   - Option 1: probe.sh & DISCARD
         1. # add in the stack for this member DISCARD protocol
              java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP
         2. # Set the parameter to discard ALL messages (FASTEST It seems)
              java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true
            OR
            (up/down ... another option to test is to set either up or down too 100.0, also Bela said use_gui="true" and you can discard messages from a subset of the cluster member, too.)
          OR (although slower it seems for FD and MERGET when set back to 0.0 to take place)
            * java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.down=100.0
            * java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.up=100.0 

   - Option 2: Using INJECT_VIEW based on http://belaban.blogspot.ch/2018/01/injecting-split-brain-into-jgroups.html
--------------
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

4. Added in all clustered.xml (standalone1, standalone2, standalone3)
  <protocol type="INJECT_VIEW"/>

5. Applied VIEWS
 1243  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost member-addrs
 1245  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost print-protocols
 1246  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost op=INJECT_VIEW.injectView["jdg-1=jdg-1;jdg-2=jdg-2/jdg-3;jdg-3=jdg-2/jdg-3"]
 1247  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost member-addrs
 1248  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost print-protocols
 1249  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=INJECT_VIEW
 1250  java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost op=INJECT_VIEW.injectView["jdg-1=jdg-1;jdg-2=jdg-2/jdg-3;jdg-3=jdg-2/jdg-3"]

As probe accesses jdg-3 the changes in there are applied but although VIEW is changed based on LOGS
a) console on jdg-2, jdg-1 doesn't change (or it is too slow ... actually it seems to have changed when jdg-2/jd-3 together with some delay on jdg-2) 
b) application still shows 3 nodes

I think it may have to do with failure detection times ... try to play around with the following

:FD_SOCK(cache_max_age=10000;get_cache_timeout=1000;sock_conn_timeout=1000;client_bind_port=0;ergonomics=true;start_port=54500;port_range=50;suspect_msg_interval=5000;num_tries=3;stats=true;external_port=0;bind_addr=127.0.0.1;keep_alive=true;id=2;cache_max_elements=200)
:FD_ALL(use_time_service=true;stats=true;timeout_check_interval=5000;ergonomics=true;interval=15000;id=20;timeout=60000;msg_counts_as_heartbeat=false)
:VERIFY_SUSPECT(num_msgs=1;use_mcast_rsps=false;stats=true;ergonomics=true;bind_addr=127.0.0.1;id=11;timeout=5000;use_icmp=false)

-------------



c) check status of partition 
   - consoles
       * http://localhost:10090/console/index.html#/server-groups/default  
       * http://localhost:10190/console/index.html#/server-groups/default
       * http://localhost:10290/console/index.html#/server-groups/default
   - probe
       * java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost addrs
   - LOGS
       * /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/standalone1/log
       * /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/standalone2/log
       * /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/standalone3/log
       * tail -n 100 -f server.log







d) Now update entries on the cache (only in the nodes not left the cluster) ... retrieve the value ... ie. incosistency 
e) try to also update the value in the node that is NOT part of the cluster ... retrieve the value ... ie. further incosistency


 1255  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-3:value-1 server-list="127.0.0.1:11422"
 1256  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-3 server-list="127.0.0.1:11422"
 1257  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"

 1258  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-2 server-list="127.0.0.1:11522"
 1259  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"

 1262  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-1:value-1 server-list="127.0.0.1:11522"
 1263  java -jar ./target/jdg-generic-importer-full.jar command-line roger-1:value-1 server-list="127.0.0.1:11322"
 1264  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-1 server-list="127.0.0.1:11422"
 1265  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
 1266  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
 1267  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"
 1268  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
 1269  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
 1270  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-2 server-list="127.0.0.1:11422"
 1271  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-3:value-1 server-list="127.0.0.1:11422"


f) rejoin the cluster ... check the value (could versioned API help? ... is versioned API only working in library)

outcome 
loss of values on rejoin
loss of accuracy

Scenario 2:
-----------
a) create distributed cache (added to the clustered.xml of the jboss-datagrid-spark-analytics-demo) WITH PARTITION HANDLING configuration and client to add entries (imitate the importer project OR expand the UI to be able to do so (considerations on members 2 probably)
b) create partition (use PROBE and then see if also can use jgroups-4.0.10.Final.jar INJECT_VIEW based on http://belaban.blogspot.ch/2018/01/injecting-split-brain-into-jgroups.html)
c) check status of partition .... what are the differences  
   - AP .... available & partitioned ... some incosistencies will be possible ... when should you use?  (CONSOLE should show ENABLED)
   - CP ..... consistency & partitioned ... DEGRADED ... possible to READ but not to write (CONSOLE should show DEGRADED)

ENTRIES TO ENTER IN DEGRADED MODE
----------------------------------
  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-3:value-1 server-list="127.0.0.1:11422"
  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-3 server-list="127.0.0.1:11422"
  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"

  java -jar ./target/jdg-generic-importer-full.jar command-line stelios-2:value-2 server-list="127.0.0.1:11522"
  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"

REJOIN & Test
  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11322"
  java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11422"



TO SHOWCASE
==============================================================
Directories required
a) /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/projects/jdg-generic-importer
      Run commands such as
          java -jar ./target/jdg-generic-importer-full.jar command-line stelios-3:value-1 server-list="127.0.0.1:11422"
          java -jar ./target/jdg-generic-importer-full.jar get PartitionScenarios server-list="127.0.0.1:11522"
b) /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/standalone1/log
   /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/standalone2/log
   /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/standalone3/log
     SHOWING LOGS
         tail -n 100 -f server.log
c) /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/bin
     ./cli.sh --controller=127.0.0.1:10090 -c
     ./cli.sh --controller=127.0.0.1:10190 -c
     ./cli.sh --controller=127.0.0.1:10290 -c
     :reload (when changing configurations

d) /home/stkousso/Stelios/Projects/0041-Garanti/WorkshopIdeasMaterial/Labs/jboss-datagrid-spark-analytics-demo/target/jboss-datagrid-7.1.0-server/bin
   PROBE UTILITY
   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP
   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true
   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.10.Final.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=false
   or   
   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost insert-protocol=DISCARD=above=UDP
   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=true
   java -classpath ../modules/system/layers/base/org/jgroups/main/jgroups-4.0.1.Final-redhat-1.jar org.jgroups.tests.Probe -addr 230.0.0.4 -ttl 20 -bind_addr localhost jmx=DISCARD.discard_all=false

e) consoles
   http://localhost:8080/visualizer/
   http://localhost:10090/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios
   http://localhost:10190/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios
   http://localhost:10290/console/index.html#/containers/standalone/clustered/caches/distributed-cache/PartitionScenarios
   http://localhost:10090/console/index.html#/server-groups/default
   http://localhost:10290/console/index.html#/server-groups/default

left to do
- faster FD
- scripts to run some of these to hide JAVA Classes
- scripts for the creation of the CACHES (right now fully configured for PARTITIONING)
- DISCOVER PRIMARY OWNERS
he Cache<K,V>.values() entrySet() and keySet() methods only return the data stored locally in distribution mode, so that could be a way to obtain the information. It doesn't however distinguish between primary and backup owners. The DistributionManager (which you can obtain via the Cache.getAdvancedCache().getDistributionManager() call) has a locate method which provides the addresses of the specified keys in the cluster.

You could also use the DistExec framework to perform operations on the local data of each node.
- VISUALIZE OWNERSHIP by using HELLOWROLD?


DOCUMENTATION
====================
http://blog.infinispan.org/search/label/partition%20handling



https://access.redhat.com/solutions/420583
