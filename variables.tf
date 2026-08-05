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
  description = "Name of the EKS cluster - also used for the subnet auto-discovery tags in subnets.tf, so this is the single source of truth for the cluster's name."
  type        = string
  default     = "financial-ner-llm"
}

variable "kubernetes_version" {
  description = "EKS control plane version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 instance type for the managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT - SPOT is cheaper but nodes can be reclaimed on short notice, which is an annoying surprise while you're still learning this setup. Switch to SPOT later once things are stable."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "eso_namespace" {
  description = "Namespace the External Secrets Operator will be installed into - must match whatever namespace its ArgoCD Application/Helm values actually use"
  type        = string
  default     = "external-secrets"
}

variable "eso_service_account_name" {
  description = "ServiceAccount name ESO's pods run under - must match the Helm chart's serviceAccount.name value"
  type        = string
  default     = "external-secrets"
}

variable "lb_controller_namespace" {
  description = "Namespace the AWS Load Balancer Controller will be installed into"
  type        = string
  default     = "kube-system"
}

variable "lb_controller_service_account_name" {
  description = "ServiceAccount name the LB Controller's pods run under - must match the Helm chart's serviceAccount.name value"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "cluster_autoscaler_namespace" {
  description = "Namespace Cluster Autoscaler will be installed into"
  type        = string
  default     = "kube-system"
}

variable "cluster_autoscaler_service_account_name" {
  description = "ServiceAccount name Cluster Autoscaler's pods run under - must match the Helm chart's serviceAccount.name value"
  type        = string
  default     = "cluster-autoscaler"
}

variable "gpu_node_instance_type" {
  description = "EC2 instance type for the GPU node group (vLLM)"
  type        = string
  default     = "g4dn.xlarge"
}

variable "gpu_node_capacity_type" {
  description = "ON_DEMAND or SPOT - see node_capacity_type's comment; same reasoning applies here."
  type        = string
  default     = "ON_DEMAND"
}

variable "gpu_node_ami_type" {
  description = "EKS-optimized AMI type - must be a GPU variant (has NVIDIA drivers preinstalled) or the device plugin can't see the GPU. Verify this is still the current recommended GPU ami_type for the cluster's kubernetes_version before applying - AWS has been migrating GPU AMIs from AL2 to AL2023 variants."
  type        = string
  default     = "AL2_x86_64_GPU"
}

variable "gpu_node_desired_size" {
  description = "Starting node count - Cluster Autoscaler adjusts this at runtime within min/max, this is only the initial value Terraform sets."
  type        = number
  default     = 0
}

variable "gpu_node_min_size" {
  description = "Minimum GPU nodes - 0 so nothing runs (and nothing costs money) when vLLM has no pods scheduled."
  type        = number
  default     = 0
}

variable "gpu_node_max_size" {
  description = "Maximum GPU nodes"
  type        = number
  default     = 2
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
