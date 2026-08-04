# EKS control plane. The cluster role is assumed by the AWS-managed control
# plane itself (not your nodes, not your pods) - it needs to act on your VPC
# to create/manage the ENIs it uses to reach your nodes, describe subnets and
# security groups, etc. This is separate from both the node role
# (node_group.tf, assumed by EC2 instances) and the IRSA roles (irsa.tf,
# assumed by individual pods).
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.project_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    # Only private subnets - this is where the control plane's cross-account
    # ENIs live to reach your nodes/pods, not where nodes themselves run
    # (that's node_group.tf) or how the AWS Load Balancer Controller finds
    # subnets (that's tag-based, via subnets.tf, independent of this list).
    # No reason for the control plane's network presence to touch a public
    # subnet when nothing here requires it.
    subnet_ids              = aws_subnet.private[*].id
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # aws_eks_cluster only reads role_arn (an attribute reference, which
  # Terraform already tracks) - it never reads anything from the policy
  # attachment, so that dependency has to be stated explicitly, same
  # reasoning as the NAT Gateway -> Internet Gateway depends_on in nat.tf.
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}
