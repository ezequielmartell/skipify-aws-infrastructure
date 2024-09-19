#!/usr/bin/env bash
export $(cat .env | xargs)
tofu destroy --target aws_lb.prod -auto-approve
tofu destroy --target aws_ecs_cluster.prod -auto-approve
tofu destroy --target aws_internet_gateway.prod -auto-approve
tofu destroy --target aws_nat_gateway.prod -auto-approve