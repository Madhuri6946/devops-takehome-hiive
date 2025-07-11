# Hiive DevOps Take-Home Assignment
Deployment Guide
This Terraform project deploys:
 * An AWS EKS Cluster
 * A containerized NGINX service
 * All necessary VPC, IAM, and network setup
Prerequisites
Before you begin, ensure you have the following installed and configured:
 * Git
 * Terraform
 * AWS CLI configured with appropriate credentials
 * kubectl
Deployment Steps
Follow these steps to deploy the infrastructure and NGINX service:
 * **Clone the Repository**
   git clone https://github.com/your-username/devops-takehome-hiive.git
cd devops-takehome-hiive
 * **Initialize Terraform**
   Navigate into the cloned repository and initialize Terraform to download the necessary providers and modules.
   terraform init
 * **Apply Terraform Configuration**
   Apply the Terraform configuration to provision the AWS resources, including the EKS cluster. Review the plan carefully before confirming.
   terraform apply
 * **Connect to the EKS Cluster**
   Update your kubeconfig file to connect to the newly created EKS cluster. Replace us-east-1 with your AWS region if different, and hiive-eks-cluster with your cluster name if you changed it.
   aws eks update-kubeconfig --region us-east-1 --name hiive-eks-cluster
 * **Deploy the NGINX Service**
   Deploy the NGINX service and its corresponding Kubernetes service using the provided YAML files.
   kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
Accessing the NGINX Service
Once the NGINX service is deployed, you can access it via its external IP address.
To get the external IP, run:
kubectl get svc nginx-service

Look for the EXTERNAL-IP in the output. You can then paste this IP into your web browser to access the NGINX welcome page.
