# Hiive DevOps Take-Home Assignment

This Terraform project deploys:
- An AWS EKS Cluster
- A containerized NGINX service
- All necessary VPC, IAM, and network setup

---

## 🚀 How to Deploy

### 1. Clone the repo
```bash
git clone https://github.com/your-username/devops-takehome-hiive.git
cd devops-takehome-hiive

### 2. Initialize Terraform
bash

terraform init

### 3. Apply

bash

terraform apply

##4. Connect to EKS

bash

aws eks update-kubeconfig --region us-east-1 --name hiive-eks-cluster

## 5 Deploy the NGINX service

bash

kubectl apply -f nginx-deployment.yaml
kubectl get svc nginx-service

