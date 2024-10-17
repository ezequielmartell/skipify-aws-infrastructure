locals {
  backend_vars = {
    region         = var.region
    image          = aws_ecr_repository.backend.repository_url
    log_group      = aws_cloudwatch_log_group.prod.name
    rds_db_name    = var.prod_rds_db_name
    rds_username   = var.prod_rds_username
    rds_password   = var.prod_rds_password
    rds_hostname   = aws_db_instance.prod.address
    domain         = var.prod_domain
    secret_key     = var.prod_backend_secret_key
    sqs_access_key = aws_iam_access_key.prod_sqs.id
    sqs_secret_key = aws_iam_access_key.prod_sqs.secret
    sqs_name       = aws_sqs_queue.prod.name
    sendgrid_api_key = var.prod_sendgrid_api_key
    client_id        = var.prod_client_id
    client_secret    = var.prod_client_secret
    redirect_uri     = var.prod_redirect_uri
    debug       = var.prod_debug
  }
}

# Production cluster
resource "aws_ecs_cluster" "prod" {
  name = "prod"
}

# Backend web task definition and service
resource "aws_ecs_task_definition" "prod_backend_web" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  skip_destroy             = true

  family = "backend-web"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    merge(
      local.backend_vars,
      {
        name       = "prod-backend-web"
        command    = ["gunicorn", "-w", "3", "-b", ":8000", "django_aws.wsgi:application"]
        log_stream = aws_cloudwatch_log_stream.prod_backend_web.name
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

resource "aws_ecs_service" "prod_backend_web" {
  name                               = "prod-backend-web"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_backend_web.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  force_new_deployment = true
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg[0].arn
    container_name   = "prod-backend-web"
    container_port   = 8000
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  network_configuration {
    security_groups  = [aws_security_group.prod_ecs.id]
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    assign_public_ip = false
  }
  lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }
}

# Worker

resource "aws_ecs_task_definition" "prod_backend_worker" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  skip_destroy             = true

  family = "backend-worker"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    merge(
      local.backend_vars,
      {
        name       = "prod-backend-worker"
        command    = ["celery", "-A", "django_aws", "worker", "--loglevel", "warning"]
        log_stream = aws_cloudwatch_log_stream.prod_backend_worker.name
      },
    )
  )
  depends_on         = [aws_sqs_queue.prod, aws_db_instance.prod]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.prod_backend_task.arn
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [container_definitions]
  }
}

resource "aws_ecs_service" "prod_backend_worker" {
  name                               = "prod-backend-worker"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_backend_worker.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  network_configuration {
    security_groups  = [aws_security_group.prod_ecs.id]
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    assign_public_ip = false
  }
}

# Beat

resource "aws_ecs_task_definition" "prod_backend_beat" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  skip_destroy             = true

  family = "backend-beat"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    merge(
      local.backend_vars,
      {
        name       = "prod-backend-beat"
        command    = ["celery", "-A", "django_aws", "beat", "--loglevel", "warning"]
        log_stream = aws_cloudwatch_log_stream.prod_backend_beat.name
      },
    )
  )
  depends_on         = [aws_sqs_queue.prod, aws_db_instance.prod]
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.prod_backend_task.arn
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [container_definitions]
  }
}

resource "aws_ecs_service" "prod_backend_beat" {
  name                               = "prod-backend-beat"
  cluster                            = aws_ecs_cluster.prod.id
  task_definition                    = aws_ecs_task_definition.prod_backend_beat.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true

  network_configuration {
    security_groups  = [aws_security_group.prod_ecs.id]
    subnets          = [aws_subnet.prod_private_1.id, aws_subnet.prod_private_2.id]
    assign_public_ip = false
  }
}

# IAM roles and policies
resource "aws_iam_role" "prod_backend_task" {
  name = "prod-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid    = ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

