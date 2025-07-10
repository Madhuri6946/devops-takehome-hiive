# Hiive DevOps Take-Home Assignment

This Terraform project deploys:
- An AWS EKS Cluster
- A containerized NGINX service
- All necessary VPC, IAM, and network setup


## how to deploy

## 1. clone the repo

git clone https://github.com/your-username/devops-takehome-hiive.git
cd devops-takehome-hiive

##  2. Initialize Terraform

terraform init

## 3. Apply

terraform apply

## 4. Connect to EKS

aws eks update-kubeconfig --region us-east-1 --name hiive-eks-cluster

## 5 Deploy the NGINX service

kubectl apply -f nginx-deployment.yaml
kubectl get svc nginx-service

## by using external ip we can access it on web browser
