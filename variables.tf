variable "region" {
  description = "The AWS region to create resources in."
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name to use in resource names"
  default     = "django-aws"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["us-east-2a", "us-east-2c"]
}

variable "ecs_prod_retention_days" {
  description = "Retention period for backend logs"
  default     = 30
}

# RDS
variable "prod_rds_db_name" {
  description = "RDS database name"
  default     = "django_aws"
}
variable "prod_rds_username" {
  description = "RDS database username"
  default     = "django_aws"
}
variable "prod_rds_password" {
  description = "postgres password for production DB"
}
variable "prod_rds_instance_class" {
  description = "RDS instance type"
  default     = "db.t4g.micro"
}
# Django Variables
variable "prod_domain" {
  description = "domain for production"
  default     = "skipify.ezdoes.xyz"
}
variable "prod_backend_secret_key" {
  description = "production Django's SECRET_KEY"
}
variable "prod_sendgrid_api_key" {
  description = "Sendgrid API key"
}
variable "prod_client_id" {
  description = "OAuth client ID"
}
variable "prod_client_secret" {
  description = "OAuth client secret"
}
variable "prod_redirect_uri" {
  description = "OAuth redirect URI"
}
variable "prod_debug" {
  description = "Django Debug mode"
  default     = "False"
}
# LB Variables
variable "lb_target_group_name" {
  type    = string
  default = "tg"
}