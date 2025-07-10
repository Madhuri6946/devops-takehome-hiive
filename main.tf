resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-eks-vpc"
  }
}

# Data source to get available Availability Zones in your region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create Subnet 1 in the first available AZ
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0] 
  map_public_ip_on_launch = true 
  # Use the first AZ
  tags = {
    Name = "my-eks-public-subnet-1"
  }
}

# Create Subnet 2 in the second available AZ
resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1] 
  map_public_ip_on_launch = true 
  # Use the second AZ
  tags = {
    Name = "my-eks-public-subnet-2"
  }
}

# Add an Internet Gateway for public subnet routing
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-eks-igw"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-eks-public-rt"
  }
}

# Add route for Internet Gateway to public route table
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate Public Subnet 1 with Public Route Table
resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate Public Subnet 2 with Public Route Table
resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# EKS Cluster (updated subnet_ids)
resource "aws_eks_cluster" "eks" {
  name = var.cluster_name # Make sure cluster_name is defined in variables.tf
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]
    # If you want the cluster endpoint to be accessible from outside the VPC (e.g., your local machine)
    endpoint_public_access = true
    # If you want to limit public access to specific CIDR blocks (e.g., your office IP)
    # public_access_cidrs = ["0.0.0.0/0"] # Be cautious with 0.0.0.0/0 in production
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach AmazonEKSClusterPolicy
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

# Attach AmazonEKSVPCResourceController - This is crucial for EKS to manage ENIs in your VPC
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

# --- Additional resources for EKS Worker Nodes (very important!) ---

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach required policies for EKS Worker Nodes
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}

# EKS Managed Node Group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "example-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
  instance_types  = ["t3.medium"] # Choose an appropriate instance type

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # Add a remote_access block if you need SSH access to nodes
  # remote_access {
  #   ec2_ssh_key = "your-ssh-key-name"
  #   source_security_group_ids = ["your-security-group-id-to-allow-ssh"]
  # }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}































  






