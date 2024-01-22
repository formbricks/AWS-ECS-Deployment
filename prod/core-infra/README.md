
# Core Infrastructure
This folder contains the Terraform code to deploy the core infrastructure for an ECS Fargate workload. The AWS resources created by the script are:
* Networking
	 * VPC
	   * 3 public subnets, 1 per AZ. If a region has less than 3 AZs it will create same number of public subnets as AZs.
	   * 3 private subnets, 1 per AZ. If a region has less than 3 AZs it will create same number of private subnets as AZs.
	   * 3 NAT Gateways, 1 per AZ. (Redundancy)
	   * 1 Internet Gateway
	   * Associated Route Tables
* 1 ECS Cluster with AWS CloudWatch Container Insights enabled.
* CloudWatch log groups
* CloudMap service discovery namespace `prod-core-infra-service-discovery-private-dns-namespace`

# Deployment
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
## Outputs
After the execution of the Terraform code you will get an output with needed IDs and values needed as input for the next Terraform applies. 

## Cleanup
Run the following command if you want to delete all the resources created before. If you have created other blueprints and they use these infrastructure then destroy those blueprint resources first.
	```shell
	terraform destroy
	```