variable "region" {
  type    = string
  default = "us-east-1"
}

variable "TF_VAR_container_image" {
  type    = string
  default = "ghcr.io/formbricks/formbricks:latest"
}

variable "DATABASE_URL" {
  type    = string
  default = "your-database-connection-string"
}

variable "ENCRYPTION_KEY" {
  type    = string
  default = "your-encryption-key"
}

variable "NEXTAUTH_SECRET" {
  type    = string
  default = "your-nextauth-secret"
}

# Optional: Uncomment and replace with your with AWS Secrets Manager ARN in ECS Task for sharing sensitive data
/*
variable "secrets_manager_data" {
  type = map(string)
  default = {
    "ENCRYPTION_KEY"         = "ENCRYPTION_KEY"
    "NEXTAUTH_SECRET"        = "NEXTAUTH_SECRET"
    "DATABASE_URL"           = "DATABASE_URL"
  }
}
*/