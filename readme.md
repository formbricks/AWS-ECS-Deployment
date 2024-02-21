# AWS Infra
![AWS Architecture Diagram](https://github.com/formbricks/AWSInfra/assets/26037101/c0100e03-d77a-4f55-9696-0e9a25b4cb1e)

Design Decions:
- One NAT Gateway per availability zone: Though this adds extra baseline cost, this prevents the app from going down if there is an outage in one specific zone.
- The database is outside the VPC, as our current production web app still needs to connect to the database. Moving it inside the VPC would involve downtime and changes to the infrastructure. Unless we settle for AWS, it's alright to keep the Database outside the VPC.
- Using Fargate over EC2 for the ECS cluster. Fargate allows us to run containers without directly managing EC2 instances. If we use EC2, it would require a lot of fine-tuning to identify the right EC2 configurations and task placement strategy. Using Fargate eliminates this challenge.
- Fargate compute allocation strategy: We require the ECS service to use a 50-50 mix of Fargate dedicated and Fargate Spot. With at least 20% of the containers running on dedicated Fargate compute. This allows us to stay cost-effective while ensuring reliability.
- Secrets manager is not deployed via Terraform. As we need to share secrets across deployments, it doesn't make sense to redeploy secrets manager every time as that would entail losing the secrets and setting the secrets manager again.
- Using Secrets Manager to store sensitive information. Our web app requires sensitive information such as DB URL, Next Auth secret, etc., to be passed to the containers as environment variables. Instead of directly passing environment variables as plain text while deploying infra, we instead grant IAM read access to secrets to the ECS task (containers). This allows us to securely inject sensitive data into the containers.

# Development Setup
We use a devcontainer setup by AWSLabs to quickly grt development environment up and running quickly.
Read more about it here: https://github.com/awslabs/aws-terraform-dev-container
 
