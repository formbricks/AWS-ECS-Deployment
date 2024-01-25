variable "region" {
  type    = string
  default = "us-east-1"
}

variable "secrets_manager_data" {
  type = map(string)
  default = {
    "ENTERPRISE_LICENSE_KEY" = "ENTERPRISE_LICENSE_KEY"
    "ENCRYPTION_KEY"         = "ENCRYPTION_KEY"
    "IS_FORMBRICKS_CLOUD"    = "IS_FORMBRICKS_CLOUD"
    "WEBAPP_URL"             = "WEBAPP_URL"
    "TERMS_URL"              = "TERMS_URL"
    "IMPRINT_URL"            = "IMPRINT_URL"
    "PRIVACY_URL"            = "PRIVACY_URL"
    "DATABASE_URL"           = "DATABASE_URL"
    "NEXT_PUBLIC_SENTRY_DSN" = "NEXT_PUBLIC_SENTRY_DSN"
    "CRON_SECRET"            = "CRON_SECRET"
    "TELEMETRY_DISABLED"     = "TELEMETRY_DISABLED"
    "NEXTAUTH_URL"           = "NEXTAUTH_URL"
    "MAIL_FROM"              = "MAIL_FROM"
    "SMTP_HOST"              = "SMTP_HOST"
    "SMTP_PASSWORD"          = "SMTP_PASSWORD"
    "SMTP_PORT"              = "SMTP_PORT"
    "SMTP_USER"              = "SMTP_USER"
    "NEXTAUTH_SECRET"        = "NEXTAUTH_SECRET"
  }
}

variable "formbricks_ssl_certificate_arn" {
  type    = string
  default = ""
}
