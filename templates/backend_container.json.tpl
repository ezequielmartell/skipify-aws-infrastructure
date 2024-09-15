[
  {
    "name": "${name}",
    "image": "${image}",
    "essential": true,
    "links": [],
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000,
        "protocol": "tcp"
      }
    ],
    "command": ${jsonencode(command)},
    "environment": [
      {
        "name": "DATABASE_URL",
        "value": "postgresql://${rds_username}:${rds_password}@${rds_hostname}:5432/${rds_db_name}"
      },
      {
        "name": "SECRET_KEY",
        "value": "${secret_key}"
      },
      {
        "name": "DEBUG",
        "value": "true"
      },
      {
        "name": "ALLOWED_HOSTS",
        "value": "${domain}"
      },
      {
        "name": "AWS_REGION",
        "value": "${region}"
      },
      {
        "name": "CELERY_BROKER_URL",
        "value": "sqs://${urlencode(sqs_access_key)}:${urlencode(sqs_secret_key)}@"
      },
      {
        "name": "CELERY_TASK_DEFAULT_QUEUE",
        "value": "${sqs_name}"
      },
      {
        "name": "SESSION_COOKIE_SECURE",
        "value": "true"
      },
      {
        "name": "CSRF_COOKIE_SECURE",
        "value": "true"
      },
      {
        "name": "CSRF_COOKIE_SECURE",
        "value": "true"
      },
      {
        "name": "CSRF_TRUSTED_ORIGIN",
        "value": "https://${domain}"
      },
      {
        "name": "SENDGRID_API_KEY",
        "value": "${sendgrid_api_key}"
      },
      {
        "name": "CLIENT_ID",
        "value": "${client_id}"
      },
      {
        "name": "CLIENT_SECRET",
        "value": "${client_secret}"
      },
      {
        "name": "REDIRECT_URI",
        "value": "${redirect_uri}"
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