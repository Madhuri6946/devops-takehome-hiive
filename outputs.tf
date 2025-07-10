output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig" {
  value = <<EOT
To access the cluster:

aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}
EOT
}
