output "task_definition_arn_backend" {
  value = aws_ecs_task_definition.prod_backend_web.arn
}

output "task_definition_arn_frontend" {
  value = aws_ecs_task_definition.prod_frontend_web.arn
}