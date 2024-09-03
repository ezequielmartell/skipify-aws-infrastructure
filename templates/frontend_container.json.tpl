[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "links": [],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "command": ${jsonencode(command)},
    "environment": [
      {
        "name": "test2",
        "value": "testing env 2"
      },
      {
        "name": "test1",
        "value": "testing env 1"
      }
    ],
    "healthcheck": {
      "command": ["CMD-SHELL", "echo 'healthy' || exit 1"]
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "${log_stream}"
      }
    }
  }
]