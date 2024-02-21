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
    "IS_FORMBRICKS_CLOUD"    = "IS_FORMBRICKS_CLOUD"
    "WEBAPP_URL"             = "WEBAPP_URL"
    "TERMS_URL"              = "TERMS_URL"
    "IMPRINT_URL"            = "IMPRINT_URL"
    "PRIVACY_URL"            = "PRIVACY_URL"
    "ENTERPRISE_LICENSE_KEY" = "ENTERPRISE_LICENSE_KEY"
    "NEXT_PUBLIC_SENTRY_DSN" = "NEXT_PUBLIC_SENTRY_DSN"
    "CRON_SECRET"            = "CRON_SECRET"
    "TELEMETRY_DISABLED"     = "TELEMETRY_DISABLED"
    "NEXTAUTH_URL"           = "NEXTAUTH_URL"
    "MAIL_FROM"              = "MAIL_FROM"
    "SMTP_HOST"              = "SMTP_HOST"
    "SMTP_PASSWORD"          = "SMTP_PASSWORD"
    "SMTP_PORT"              = "SMTP_PORT"
    "SMTP_USER"              = "SMTP_USER"
  }
}
*/