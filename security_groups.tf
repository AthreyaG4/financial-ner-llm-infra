# Baseline SG: allow all traffic within the VPC, and all outbound (needed
# for private-subnet resources to reach the internet via the NAT Gateway -
# ECR, Hugging Face Hub, Supabase, etc.).
#
# Deliberately minimal - this is NOT the EKS cluster/node security groups.
# aws_eks_cluster (eks.tf) doesn't specify security_group_ids, so EKS
# generates its own default cluster security group automatically and the
# node group (node_group.tf) reuses it for node<->control-plane
# communication - no need to hand-write those rules here.
resource "aws_security_group" "vpc_baseline" {
  name        = "${var.project_name}-vpc-baseline"
  description = "Baseline SG: allow all traffic within the VPC, all outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow all traffic from within the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vpc-baseline"
  }
}
