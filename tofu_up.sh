#!/usr/bin/env bash
export $(cat .env | xargs)
tofu plan
tofu apply -auto-approve


# tofu plan -target="aws_ecs_task_definition.prod_backend_web" -var="image_tag=test"