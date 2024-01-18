
# Webapp Infrastructure
This folder contains the Terraform code to deploy the webapp containers via ECS Fargate workload. The AWS resources created by the script are:

*  ECS Service with the following config:
	* Always runs three instances of tasks.
	* Task execution IAM roles are created to access secrets manager.
	* ECS service is also registered in CloudMap to make it discoverable by DNS.

* Tasks for ECS service, which will be deployed in private subnets.

* ALB: We are using Application Load Balancer for distributing traffic. This evenly distributes the traffic among containers in the three availability zones. 
	* Key attributes for ALB:
		* ALB security group - allows ingress from any IP address to port 80 and allows all egress
		* ALB subnet - ALB is created in a public subnet. 
		* Listener - listens on port 80 for protocol HTTP

* Task security group: allows ingress for TCP from the ALB security group to the container service port (3000). And allows all egress.


# Deployment
* First deploy the core-infra for dev.
* Add access key to the shell.
	```shell
	export AWS_ACCESS_KEY_ID=
	export AWS_SECRET_ACCESS_KEY=
	```
* Run Terraform init to download the providers and install the modules
	```shell
	terraform init
	```
* Review the terraform plan output, take a look at the changes that terraform will execute, and then apply them:
	```shell
	terraform plan
	terraform apply --auto-approve
	```
### Outputs
After the execution of the Terraform code you will get an ALB url as output which can be used to access the webapp on the internet.  

### Cleanup
Run the following command if you want to delete all the resources created before. If you have created other blueprints and they use these infrastructure then destroy those blueprint resources first.
	```shell
	terraform destroy
	```
 