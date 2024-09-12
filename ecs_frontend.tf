locals {
  frontend_vars = {
    region    = var.region
    image     = aws_ecr_repository.frontend.repository_url
    log_group = aws_cloudwatch_log_group.prod.name
  }
}

# frontend web task definition and service
resource "aws_ecs_task_definition" "prod_frontend_web" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  family = "frontend-web"
  container_definitions = templatefile(
    "templates/frontend_container.json.tpl",
    merge(
      local.frontend_vars,
      {
        name       = "prod-frontend-web"
        command    = ["nginx", "-g", "daemon off;"]
        log_stream = aws_cloudwatch_log_stream.prod_frontend_web.name
      },
    )
  )
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.prod_backend_task.arn
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [container_definitions]
  }
}

resource "aws_ecs_service" "prod_frontend_web" {
  name                               = "prod-frontend-web"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_frontend_web.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.prod_target.arn
    container_name   = "prod-frontend-web"
    container_port   = 80
  }

  network_configuration {
    security_groups  = [aws_security_group.prod_ecs.id]
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    assign_public_ip = false
  }
}
