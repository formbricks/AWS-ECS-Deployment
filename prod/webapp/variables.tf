variable "region" {
    type    = string
    default = "us-east-1"
}

variable "serets_access_IAM_roles_arn" {
    type    = list(string)
    default = []
}