variable "region" {
  description = "AWS Region để deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Tên của EKS Cluster"
  type        = string
  default     = "eks-karpenter-demo"
}

variable "vpc_cidr" {
  description = "Dải IP cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "k8s_version" {
  description = "Kubernetes Version"
  type        = string
  default     = "1.33"
}