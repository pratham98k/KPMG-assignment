We need to write code that will query the meta data of an instance within AWS and provide a
json formatted output. The choice of language and implementation is up to you.
Bonus Points
The code allows for a particular data key to be retrieved individually
Hints
·         Aws Documentation (https://docs.aws.amazon.com/)
·         Azure Documentation (https://docs.microsoft.com/en-us/azure/?product=featured)
·         Google Documentation (https://cloud.google.com/docs)



Answer:

AWS

AWS EC2 Instance Metadata

It allows AWS EC2 instance to learn about themselves. without using an IAM role for that purpose.

The URL is ``` http://169.254.169.254/latest/meta-data/ ```

this URL will work from an EC2 instance.

Metadata = Info about the EC2 instance.

Userdata = launch script script of EC2 instance.


  We will get Version of api calls ``` curl http://169.254.169.254/ ```


``` curl http://169.254.169.254/latest/ ```

we will get dynamic, meta-data, Userdata

``` curl http://169.254.169.254/latest/meta-data/```

We will get multiple options :)

 
 Lets tery to get public IP ``` curl http://169.254.169.254/latest/meta-data/public-ipv4 ```

  ``` curl http://169.254.169.254/latest/meta-data/iam/info  ```

 IAM instance profile  ``` curl http://169.254.169.254/latest/meta-data/iam/info ```


 ``` http://169.254.169.254/latest/meta-data/iam/security-credentials/MyFirstEC2Role ```


AZURE

retrieve all metadata for an instance

``` curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq ```

Retriving network interface for instance in json format.

 ``` curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/?api-version=2021-01-01" | jq ```



