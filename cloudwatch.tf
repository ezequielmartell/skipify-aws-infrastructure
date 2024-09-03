# Cloudwatch Logs
resource "aws_cloudwatch_log_group" "prod" {
  name              = "prod"
  retention_in_days = var.ecs_prod_retention_days
}

resource "aws_cloudwatch_log_stream" "prod_backend_web" {
  name           = "prod-backend-web"
  log_group_name = aws_cloudwatch_log_group.prod.name
}

resource "aws_cloudwatch_log_stream" "prod_backend_worker" {
  name           = "prod-backend-worker"
  log_group_name = aws_cloudwatch_log_group.prod.name
}

resource "aws_cloudwatch_log_stream" "prod_backend_beat" {
  name           = "prod-backend-beat"
  log_group_name = aws_cloudwatch_log_group.prod.name
}

resource "aws_cloudwatch_log_stream" "prod_frontend_web" {
  name           = "prod-frontend_web"
  log_group_name = aws_cloudwatch_log_group.prod.name
}