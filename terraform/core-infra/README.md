# Core Infrastructure for Formbricks

This Terraform project provisions the essential AWS infrastructure to host Formbricks as an ECS Fargate workload.

**Resources Created**

* **Networking (VPC):**
    * Public subnets (one per AZ, using the first two in the region).
    * Private subnets (one per AZ, using the first two in the region).
    * NAT Gateways (one per AZ for high availability).
    * Internet Gateway.
    * Route tables for efficient traffic management.
* **ECS Cluster:**
    * Fargate capacity providers (optimized for a mix of regular and spot instances).
    * CloudWatch Container Insights for cluster monitoring.
* **Service Discovery:**
    * Private DNS namespace for seamless internal service communication.

**Prerequisites**

* Terraform installed on your system.
* Valid AWS credentials  configured (via env variables, profile, etc.)

**Deployment**

1. **Set AWS Credentials:**
   ```shell
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key

2. Initialize Terraform:
	```shell
	terraform init
	```

3. Review and Apply Changes:
	```shell
	terraform plan
	terraform apply
	```

**Outputs**

Terraform will provide values like the VPC ID and ECS cluster ARN on successful deployment.

**Cleanup**

```shell
terraform destroy
```
Important: Destroy dependent resources (other Formbricks modules) before destroying this core infrastructure.