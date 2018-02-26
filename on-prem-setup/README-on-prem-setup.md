JBoss Data Grid Demos On Premise Setups
=======================================

This directory provides a setup fo ALL On premise Demos to run with 1 EAP & 3 JDG Nodes

Setup
---------------
To setup the infrastructure for the demo download the following files to the _*installs*_ directory:

* [jboss-datagrid-7.0.0-server.zip](https://developers.redhat.com/download-manager/file/jboss-datagrid-7.0.0-server.zip)
* [jboss-eap-7.0.0.zip](https://developers.redhat.com/download-manager/file/jboss-eap-7.0.0.zip)

* Run the `init-onprem.sh` script to create the EAP & 3 JDG Nodes Setup
  * In addition, it sets up caches via *_/support/jboss-eap-7-visualizer-config.cli_* script (so put any new caches in this script)
  * In addition, it deploys the *_./projects/jdg-visualizer*_ in EAP to visualize JDG cluster

---
    $ sh init-onprem.sh
---


* Run the 'clean.sh' and follow prompts to stop servers or clean the enviroment
---
    $ sh clean.sh
---
