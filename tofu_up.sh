export $(cat .env | xargs)
tofu plan
tofu apply -auto-approve