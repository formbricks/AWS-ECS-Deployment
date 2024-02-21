# Webapp Infrastructure for Formbricks

This folder houses Terraform code responsible for deploying webapp containers using an ECS Fargate workload. The AWS resources created include:

* **ECS Service:**
    * Maintains a consistent running state of two tasks.
    * Task execution IAM roles facilitate secure access to Secrets Manager.
    * CloudMap registration for service discovery via DNS.

* **ECS Tasks:** Deployed within private subnets for enhanced security.

* **Application Load Balancer (ALB):**
    * Distributes incoming traffic across containers in multiple availability zones.
    * Key attributes:
        * Security group permits all egress traffic, and ingress from any IP address on port 80.
        * Public subnet placement.
        * HTTP listener on port 80.
    * Deletion protection is enabled (disabled for test workloads).
    * **HTTPS Support:** Enable by uncommenting the relevant  `alb` resource code in `main.tf` and providing your certificate ARN. See documentation for more details:
        - Create HTTPS Listener: [https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
        - ALB Resource: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)

* **Task Security Group:** Enables container access (port 3000) from the ALB security group alongside full egress permissions.

## Auto Scaling Configuration

The ECS webapp service leverages auto scaling to dynamically manage instance counts based on load. 
* Minimum capacity: 2 instances
* Maximum capacity: 6 instances

Adjust scaling behavior as needed.  See documentation for more details: [https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service)

## Sharing Secrets with ECS Task Containers

Formbricks in its containerized form relies on environment variables to provide sensitive configuration details. This includes:

* `DATABASE_URL`: Connection details for your database.
* `NEXTAUTH_SECRET`:  Used for secure authentication processes.
* `ENCRYPTION`: A key for data encryption.

Refer to the Formbricks Documentation for more information:

* Setting Up Formbricks: [https://formbricks.com/docs/contributing/setup](https://formbricks.com/docs/contributing/setup)
* External Authentication Providers: [https://formbricks.com/docs/self-hosting/external-auth-providers](https://formbricks.com/docs/self-hosting/external-auth-providers)

**Quick Setup**

For initial setup, you can directly modify the `environment` section within your container definition. #TODO: ADD GITHUB PERMALINK AFTER MERGE TO MAIN

**Security Best Practices**

We strongly recommend using a dedicated secrets management solution for production environments. Examples include AWS Secrets Manager or similar services. To facilitate this, we've included Terraform code as a starting point. See documentation for more details:
- Specifying Sensitive Data in AWS ECS: [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)
- AWS ECS Sensitive Data Tutorial: [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-tutorial.html](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-tutorial.html) 


## Deployment

1. First deploy the core-infra for formbricks.
2. Set AWS Credentials:
   ```shell
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   ```
3. Initialize Terraform:
	```shell
	terraform init
	```
4.
5. Review and Apply Changes:
	```shell
	terraform plan
	terraform apply
	```

