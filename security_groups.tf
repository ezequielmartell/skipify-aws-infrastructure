# Security Group
resource "aws_security_group" "prod_ecs_backend" {
  name        = "prod-ecs-backend"
  vpc_id      = aws_vpc.prod.id

  #need to make this rule be a set group instead of hard coded like this
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = ["sg-02b0c22c3a6ddab6d"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "prod_ecs_frontend" {
  name        = "prod-ecs-frontend"
  vpc_id      = aws_vpc.prod.id

  #need to make this rule be a set group instead of hard coded like this
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["sg-02b0c22c3a6ddab6d"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}