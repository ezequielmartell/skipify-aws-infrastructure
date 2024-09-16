locals {
  target_groups = [
    "green",
    "blue",
  ]
}

# Application Load Balancer for production
resource "aws_lb" "prod" {
  name               = "prod"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.prod_lb.id]
  subnets            = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id]
}

# Codedeply target group for frontend
resource "aws_lb_target_group" "frontend_tg" {
  count = length(local.target_groups)

  name        = "frontend-${var.lb_target_group_name}-${element(local.target_groups, count.index)}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.prod.id
  health_check {
    matcher = "200,301,302,404"
    path    = "/"
  }

}
# Codedeply target group for backend
resource "aws_lb_target_group" "backend_tg" {
  count = length(local.target_groups)

  name        = "backend-${var.lb_target_group_name}-${element(local.target_groups, count.index)}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.prod.id
  health_check {
    matcher = "200,301,302,404"
    path    = "/"
  }

}
# Target group for frontend web application
resource "aws_lb_target_group" "prod_frontend_target" {
  name        = "prod-frontend-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod.id
  target_type = "ip"

  health_check {
    # path                = "/health/"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

# Target group for backend web application
resource "aws_lb_target_group" "prod_backend_target" {
  name        = "prod-backend-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod.id
  target_type = "ip"

  health_check {
    path                = "/health/"
    # path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200"
  }
}

# Target listener for http:80
resource "aws_lb_listener" "prod_http" {
  load_balancer_arn = aws_lb.prod.id
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.prod_frontend_target]

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "prod_8080" {
  load_balancer_arn = aws_lb.prod.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg[1].arn
  }
}
# Target listener for https:443
resource "aws_lb_listener" "prod_https" {
  load_balancer_arn = aws_lb.prod.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  depends_on        = [aws_lb_target_group.prod_frontend_target]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg[0].arn
  }

  certificate_arn = aws_acm_certificate_validation.prod_backend.certificate_arn
}

# ALB Target Rules
resource "aws_lb_listener_rule" "static_admin" {
  listener_arn = aws_lb_listener.prod_https.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg[0].arn
  }

  condition {
    path_pattern {
      values = ["/static/admin/*"]
    }
  }
    
}
resource "aws_lb_listener_rule" "static_rest_framework" {
  listener_arn = aws_lb_listener.prod_https.arn
  priority     = 51

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg[0].arn
  }
  condition {
    path_pattern {
      values = ["/static/rest_framework/*"]
    }
  }
}
resource "aws_lb_listener_rule" "staff" {
  listener_arn = aws_lb_listener.prod_https.arn
  priority     = 52

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg[0].arn
  }
  condition {
    path_pattern {
      values = ["/staff/*"]
    }
  }
}
resource "aws_lb_listener_rule" "staff_files" {
  listener_arn = aws_lb_listener.prod_https.arn
  priority     = 53

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg[0].arn
  }
  condition {
    path_pattern {
      values = ["/staff"]
    }
  }
}
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.prod_https.arn
  priority     = 55

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg[0].arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Allow traffic from 80 and 443 ports only
resource "aws_security_group" "prod_lb" {
  name        = "prod-lb"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}