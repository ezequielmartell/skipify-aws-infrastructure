resource "aws_codedeploy_app" "frontend_deployment" {
  compute_platform = "ECS"
  name             = "frontend_deployment"
}

resource "aws_codedeploy_deployment_group" "frontend" {
  app_name               = aws_codedeploy_app.frontend_deployment.name
  deployment_group_name  = "frontend-deploy-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.prod.name
    service_name = aws_ecs_service.prod_frontend_web.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.prod_https.arn]
      }

      target_group {
        name = aws_lb_target_group.frontend_tg[0].name
      }

      target_group {
        name = aws_lb_target_group.frontend_tg[1].name
      }

      
    }
  }

}
