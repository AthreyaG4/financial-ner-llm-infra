# Node role: assumed by the EC2 instances backing the node group (via their
# instance profile), not by the control plane. Covers what runs ON the
# nodes: kubelet registering with the cluster (AmazonEKSWorkerNodePolicy),
# the VPC CNI plugin managing pod networking (AmazonEKS_CNI_Policy), and
# nodes pulling images from ECR directly without imagePullSecrets
# (AmazonEC2ContainerRegistryReadOnly). Every pod scheduled on a node
# inherits this role's permissions unless it uses IRSA (irsa.tf) instead -
# that's the whole reason IRSA exists as a separate, narrower mechanism.
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${var.project_name}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_readonly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Managed node group - nodes live in private subnets only (reach the
# internet via the NAT Gateway; never directly internet-facing themselves).
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = aws_subnet.private[*].id

  capacity_type  = var.node_capacity_type
  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # Same reasoning as eks.tf's depends_on - EKS requires these policies to
  # be attached before nodes can successfully join the cluster, but nothing
  # here references the attachments directly.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker_policy,
    aws_iam_role_policy_attachment.eks_node_cni_policy,
    aws_iam_role_policy_attachment.eks_node_ecr_readonly,
  ]
}
