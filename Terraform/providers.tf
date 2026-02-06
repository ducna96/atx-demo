terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
    # Provider này cần thiết để EKS module quản lý các resource trong K8s (nếu cần)
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    # Random string cho suffix tài nguyên (tùy chọn, giữ cho best practice)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.region
  
  # Default tags: Tự động gắn tag này vào MỌI resource tạo ra
  default_tags {
    tags = {
      Project     = "EKS-Karpenter-Test"
      Environment = "Dev"
      Terraform   = "True"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    # Dùng lệnh này để lấy token động mỗi khi chạy
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
    }
  }
}