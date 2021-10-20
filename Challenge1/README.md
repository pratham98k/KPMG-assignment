
## Goal is to create three tier application architecture in Azure with secure infracture.

Below are list of resources are used in this archeture.

Resource Group
Application gateway
VM (Ubuntu 16.04 LTS) Apache, PHP
managed MYsql DB
Keyvault - store DB password, Ubuntu Admin public key and private key.

Note: application gateway having capablity to provide layer 7 loadbalancing and provide funcinility to configure SSL cert and Web application firewall.

in this demo single VM is added behind application gateway, But we can add virtual machine scale sets to serve application demand.

[![Image](https://github.com/pratham98k/KPMG-assignment/blob/main/Challenge1/KPMG-assignment-diagram/three-tier-application-architecture.JPG "Three Tier secure infra architecture approch" )



To provision this infracture Terraform (Infrastructure as code) is used with latest Version 1.x 



Below is Snapshoot of Resource Group created created in Azure Cloud

[![Image](https://github.com/pratham98k/KPMG-assignment/blob/main/Challenge1/KPMG-assignment-diagram/Resource-group.JPG)


deployed sample application can be accessed using Curl 


 [![Image](https://github.com/pratham98k/KPMG-assignment/blob/main/Challenge1/KPMG-assignment-diagram/app-hello.JPG)

 