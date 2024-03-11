# Core Infrastructure for Formbricks

This Terraform module provisions the essential AWS infrastructure to host Formbricks as an ECS Fargate workload.

## Resources Created

* **Networking (VPC):**
    * Public subnets (one per AZ, using the first two in the region).
    * Private subnets (one per AZ, using the first two in the region).
    * NAT Gateways (one per AZ for high availability).
    * Internet Gateway.
    * Associated Route Tables.
* **ECS Cluster:**
    * Fargate capacity providers (optimized for a mix of dedicated and spot instances).
    * CloudWatch log groups with Container Insights enabled for cluster monitoring.
* **Service Discovery:**
    * Private DNS namespace for seamless internal service communication.

## Deployment

1. **Prerequisites**
    * Terraform installed on your system.
    * Valid AWS credentials configured (via env variables, profile, etc.)
    * Change directory to `terraform/core-infra`

2. **Set AWS Credentials**
   ```shell
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

3. **Initialize Terraform**
	```shell
	terraform init
	```

4. **Review and Apply Changes**
	```shell
	terraform plan
	terraform apply
	```

5. **Outputs**  
    
    Terraform will output values for `vpc_id`, `cluster_arn`, `cluster_id` and `service_discovery_namespaces` on successful deployment.

## Cleanup
**Important:** Before destroying this core infrastructure, ensure you've destroyed any dependent resources created by other Formbricks modules.

To destroy the AWS resources created by this module, use:
```shell
terraform destroy
```
