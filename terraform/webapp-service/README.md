# Webapp Infrastructure for Formbricks

This Terraform module provisions the AWS infrastructure to host Formbricks webapp containers as an ECS Fargate workload.

## Resources Created
* **ECS Service:**  
    * Maintains a consistent running state of two tasks.
    * Task execution IAM roles facilitate secure access to Secrets Manager.
    * CloudMap registration for service discovery via DNS.

* **ECS Tasks:**  
Deployed within private subnets for enhanced security.

* **Application Load Balancer (ALB):**
    * Distributes incoming traffic across containers in multiple availability zones.
    * Key attributes:
        * Security group permits all egress traffic, and ingress from any IP address on port 80.
        * Public subnet placement.
        * HTTP listener on port 80.
    * Deletion protection is enabled by default.
    * **HTTPS Support:**   
    Enable by uncommenting the relevant  `alb` resource code in `main.tf` and providing your certificate ARN. See documentation for more details:
        - Create HTTPS Listener: [https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html)
        - ALB Resource: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)

* **Task Security Group:**  
Enables container access (port 3000) from the ALB security group alongside full egress permissions.

## Auto Scaling Configuration

The `webapp-formbricks-service` leverages auto scaling to dynamically manage running tasks based on load. 
* Minimum capacity: 2 tasks
* Maximum capacity: 6 tasks

Auto scaling behavior for the service can be changed based on your needs by [modifying the terraform code](https://github.com/formbricks/AWSInfra/blob/5174afbd5ccbee4777beb802a08325e74ad87783/terraform/webapp-service/main.tf#L87-L88C31) and redeploying.

Refer to Terraform AWS ECS module documentation for more details: [https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service)

## **Sharing Secrets with ECS Task Containers**

Formbricks, in its containerized form, requires sensitive configuration details provided through environment variables. Here are the essential ones:

* **DATABASE_URL:** Connection details for your database.
* **NEXTAUTH_SECRET:** Used for secure authentication processes.
* **ENCRYPTION_KEY:** A key used for data encryption.

Formbricks documentation provides further details: [https://formbricks.com/docs/self-hosting/external-auth-providers](https://formbricks.com/docs/self-hosting/external-auth-providers)

**Methods for Sharing Secrets:**

Choose the method that best suits your environment and security requirements.

**1. Environment Variables in Task Definition (Ideal for Quick Setup and Non-Production Workloads)**

*   Modify the [container task definition](https://github.com/formbricks/AWSInfra/blob/c736612209c70bafa814fa7f2db8a65b91496742/terraform/webapp-service/main.tf#L110-L123C8), adding required environment variables.
*   For convenience, [the essential variables](https://github.com/formbricks/AWSInfra/blob/c736612209c70bafa814fa7f2db8a65b91496742/terraform/webapp-service/variables.tf#L11-L24C2) (`DATABASE_URL`, `NEXTAUTH_SECRET`, `ENCRYPTION_KEY`) are already included.
*   Assign values using Terraform variables (`DATABASE_URL`, `NEXTAUTH_SECRET`, `ENCRYPTION_KEY`) during deployment.
*   Refer to these resources for guidance:
    * Terraform AWS ECS Container Definition Module: [https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/container-definition](https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/container-definition) 
    * Using task definition parameters: [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/taskdef-envfiles.html](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/taskdef-envfiles.html)

**2. Using AWS Secrets Manager (Recommended for Production Environments)**

* Disable using [environment variables](https://github.com/formbricks/AWSInfra/blob/9b6c57d42fe3c527b33901bd62b633e105bdbf7a/terraform/webapp-service/main.tf#L108-L119C11) to ensure sensitive information isn't passed directly through environment variables. 
* [Setup the Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/create_database_secret.html). 
* Store values for the following secrets: `DATABASE_URL`, `NEXTAUTH_SECRET` and `ENCRYPTION_KEY`.

* Modify the Terraform Code:
    * Update the [Terraform variables](https://github.com/formbricks/AWSInfra/blob/9b6c57d42fe3c527b33901bd62b633e105bdbf7a/terraform/webapp-service/variables.tf#L28-L35C2) file (variables.tf) to accept the ARNs (Amazon Resource Names) of the Secrets Manager secrets as input.
    * Configure the ecs_module in the Terraform code (main.tf) with the following:
        * Grant the [IAM role](https://github.com/formbricks/AWSInfra/blob/9b6c57d42fe3c527b33901bd62b633e105bdbf7a/terraform/webapp-service/main.tf#L93) the necessary permissions to read the specified secrets from Secrets Manager.
        * Pass the [secrets' ARNs as input](https://github.com/formbricks/AWSInfra/blob/9b6c57d42fe3c527b33901bd62b633e105bdbf7a/terraform/webapp-service/main.tf#L126-L132C8) to the container task definition.

## Deployment

1. **Prerequisites**
    * Terraform installed on your system.
    * Valid AWS credentials configured (via env variables, profile, etc.)
    * Deploy the core-infra for Formbricks.
    * Change directory to `terraform/webapp-formbricks`
2. **Set AWS Credentials**
   ```shell
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   ```
3. **Initialize Terraform**
   ```shell
   terraform init
   ```
4.  **Generate Security Keys**

    Use the following command to generate values for `NEXTAUTH_SECRET` and `ENCRYPTION_KEY`.
    ```shell
    openssl rand -hex 32
    ```
    **Note:** Use different values for `NEXTAUTH_SECRET` and `ENCRYPTION_KEY`.
6. **Review and Apply Changes**
    ```shell
    terraform apply -var "DATABASE_URL=your_db_connection_string" \
                    -var "NEXTAUTH_SECRET=your_nextauth_secret" \
                    -var "ENCRYPTION_KEY=your_encryption_key"
    ```
