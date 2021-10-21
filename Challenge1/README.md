
## Goal is to create secure three tier application infrastructure architecture in Azure.

Below are list of resources are used in this architecture.

Resource Group,
Application gateway,
VM (Ubuntu 16.04 LTS) Apache, PHP,
managed MYsql DB,
Keyvault - store DB password, Ubuntu Admin public key and private key.

Note: application gateway having capablity to provide layer 7 loadbalancing and provide functionality to configure SSL cert and Web application firewall.

In this demo single VM is added behind application gateway, But we can add virtual machine scale sets to serve application demand.

digram can be found https://app.cloudskew.com/viewer/97df19e7-ec4a-4c7b-9122-bd78e4c31670

![Image](https://github.com/pratham98k/KPMG-assignment/blob/main/Challenge1/KPMG-assignment-diagram/three-tier-application-architecture.JPG)



To provision this infracture Terraform (Infrastructure as code) is used with latest Version 1.x 

Install the Azure CLI & Terraform 1.x 

Using your CLI, run ``` az login ```

1. Run ``` terraform init ```
2. Run ``` terraform plan ```
3. Run ``` terraform apply -auto-approve ```

Based on requirment variables can updated variables.auto.tfvars

You're done!

Below is Snapshoot of Resource Group created created in Azure Cloud

![Image](https://github.com/pratham98k/KPMG-assignment/blob/main/Challenge1/KPMG-assignment-diagram/Resource-group.JPG)


deployed sample application can be accessed using Curl 


![Image](https://github.com/pratham98k/KPMG-assignment/blob/main/Challenge1/KPMG-assignment-diagram/app-hello.JPG)