# outputs.tf

output "cluster_name" {
  description = "Tên Kubernetes Cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint của EKS Control Plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_region" {
  description = "AWS Region"
  value       = var.region
}

output "configure_kubectl_command" {
  description = "Lệnh cấu hình kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
output "karpenter_node_role_arn" {
  description = "ARN của IAM Role dành cho Node"
  value       = module.karpenter.node_iam_role_arn
}

output "karpenter_queue_name" {
  description = "Tên hàng đợi SQS để xử lý Spot Interruption"
  value       = module.karpenter.queue_name
}
