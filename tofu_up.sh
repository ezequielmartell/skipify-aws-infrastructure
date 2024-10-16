#!/usr/bin/env bash
export $(cat .env | xargs)
tofu plan
tofu apply -auto-approve