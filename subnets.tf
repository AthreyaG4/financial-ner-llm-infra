# Public subnets - one per AZ. Hold the NAT Gateway, and later the ALB
# provisioned by the AWS Load Balancer Controller.
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${var.availability_zones[count.index]}"
    # Lets EKS/the AWS Load Balancer Controller auto-discover which subnets
    # to use for internet-facing load balancers.
    "kubernetes.io/role/elb"                     = "1"
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
  }
}

# Private subnets - one per AZ. Where the EKS worker nodes (and therefore
# all pods) actually live. No direct inbound internet access; outbound goes
# through the NAT Gateway.
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-${var.availability_zones[count.index]}"
    # Lets EKS/the AWS Load Balancer Controller auto-discover which subnets
    # to use for internal load balancers.
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
