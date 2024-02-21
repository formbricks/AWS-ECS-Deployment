# Webapp Infrastructure

This folder contains the Terraform code to deploy the webapp containers via ECS Fargate workload. The AWS resources created by the script are:

* ECS Service with the following config:
	* Always runs two of tasks.
	* Task execution IAM roles are created to access secrets manager.
	* ECS service is also registered in CloudMap to make it discoverable by DNS.

* Tasks for ECS service, which will be deployed in private subnets.

* ALB: We are using an Application Load Balancer (ALB) to distribute traffic evenly among containers in the three availability zones.
	* Key attributes for ALB:
		* ALB security group - allows ingress from any IP address to port 80 and allows all egress.
		* ALB subnet - ALB is created in a public subnet.
		* Listener - listens on port 80 for HTTP protocol.
	* ALB has delete protection enabled, but it is disabled for the test workload.
	* By default, the ALB supports HTTP. To enable HTTPS support with ALB, uncomment the code inside the `alb` resource in `main.tf` and update the `certificate_arn` value for the HTTPS listener.
	You can read more about this at:
		- [Create HTTPS Listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
		- [ALB Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)

* Task security group: allows ingress for TCP from the ALB security group to the container service port (3000) and allows all egress.

## Auto Scaling Configuration

The ECS webapp service is configured with auto scaling, allowing it to dynamically adjust the number of instances based on demand. The minimum capacity is set to 2 instances, while the maximum capacity is set to 6 instances.

For more information on changing the scaling behavior, refer to the [Auto Scaling Configuration](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service) documentation.



## Deployment

1. First deploy the core-infra for dev.
2. Add access key to the shell.
	 ```shell
	 export AWS_ACCESS_KEY_ID=
	 export AWS_SECRET_ACCESS_KEY=


## Using AWS Secrets Manager
The ECS webapp service is configured with auto scaling, allowing it to dynamically adjust the number of instances based on demand. The minimum capacity is set to 2 instances, while the maximum capacity is set to 6 instances.

For more information on changing the scaling behavior, refer to the [Auto Scaling Configuration](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service) documentation.