resource "aws_secretsmanager_secret" "TF_VAR_prod_rds_password" {
  name = "TF-VAR-prod-rds-password"
}

resource "aws_secretsmanager_secret" "TF_VAR_prod_backend_secret_key" {
  name = "TF-VAR-prod-backend-secret-key"
}

resource "aws_secretsmanager_secret" "TF_VAR_prod_sendgrid_api_key" {
  name = "TF-VAR-prod-sendgrid-api-key"
}

resource "aws_secretsmanager_secret" "TF_VAR_prod_client_id" {
  name = "TF-VAR-prod-client-id"
}

resource "aws_secretsmanager_secret" "TF_VAR_prod_client_secret" {
  name = "TF-VAR-prod-client-secret"
}

resource "aws_secretsmanager_secret" "TF_VAR_prod_redirect_uri" {
  name = "TF-VAR-prod-redirect-uri"
}
