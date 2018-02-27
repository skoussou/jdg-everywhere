# Http Session Demo Application

  Demo application source code

## Build  & Package for code changes

```
//Compile & package
mvn clean package
//copy
cp -f ./target/sso-demo.war ../install/.
```
## Notes
-  ```jboss.infinispan.web.remote-http``` cache is defined in jboss-web.xml for http session externalization & sharing
- ```<domain>.redhat.com</domain>''' is defined in jboss-web.xml to configuree the cookie domain
- ```localhost:11222``` is defined as remote jdg host address in web.xml to collect cache statistics
- ```httpSessionCache``` is defined as remote cache name in web.xml to collect cache statistics

