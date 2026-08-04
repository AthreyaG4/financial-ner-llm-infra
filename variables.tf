variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name prefix used for tagging/naming all resources"
  type        = string
  default     = "financial-ner-llm"
}

variable "cluster_name" {
  description = <<-EOT
    Name you plan to give the EKS cluster (created manually for now, not by
    this Terraform yet). Needed here so subnets can be tagged correctly for
    EKS/AWS Load Balancer Controller auto-discovery from the start - make
    sure this matches whatever you actually name the cluster.
  EOT
  type        = string
  default     = "financial-ner-llm"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs to spread subnets across - EKS requires at least 2"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ (index-matched to availability_zones)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (EKS nodes live here), one per AZ (index-matched to availability_zones)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}
