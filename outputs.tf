output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_baseline_security_group_id" {
  value = aws_security_group.vpc_baseline.id
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Feed into a kubeconfig if you're not just using `aws eks update-kubeconfig`"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

output "eso_role_arn" {
  description = "Paste into ESO's ServiceAccount annotation (eks.amazonaws.com/role-arn) in Config Repo"
  value       = aws_iam_role.eso.arn
}

output "lb_controller_role_arn" {
  description = "Paste into the AWS Load Balancer Controller's ServiceAccount annotation (eks.amazonaws.com/role-arn) in Config Repo"
  value       = aws_iam_role.lb_controller.arn
}

output "cluster_autoscaler_role_arn" {
  description = "Paste into Cluster Autoscaler's ServiceAccount annotation (eks.amazonaws.com/role-arn) in Config Repo"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "account_id" {
  description = "Config Repo's backend/frontend deployment.yaml hardcode this in their ECR image URLs - ECR itself isn't managed by this Terraform, so this only helps you verify/copy the right value by hand, it doesn't wire the dependency automatically."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Must match Config Repo's external-secrets/cluster-secret-store.yaml region field."
  value       = var.aws_region
}
