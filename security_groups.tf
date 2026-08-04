# Baseline SG: allow all traffic within the VPC, and all outbound (needed
# for private-subnet resources to reach the internet via the NAT Gateway -
# ECR, Hugging Face Hub, etc.).
#
# Deliberately minimal - this is NOT the EKS cluster/node security groups.
# Those depend on the actual EKS cluster and node group, which don't exist
# yet (you're setting EKS up manually first). When you create the cluster,
# EKS will generate its own cluster security group automatically, and
# you'll want a node-to-cluster communication SG at that point too - add
# those alongside the cluster itself rather than guessing at their rules
# here ahead of time.
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
