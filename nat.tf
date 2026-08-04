resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# Single shared NAT Gateway (not one per AZ) - a deliberate cost tradeoff.
# A NAT Gateway costs ~$0.045/hr + ~$0.045/GB processed *each*, regardless
# of usage - one per AZ meaningfully adds up for a dev project that gets
# torn down and recreated often. This sacrifices some HA (an outage in this
# NAT's AZ takes down outbound internet for private subnets in every AZ,
# not just this one) - a reasonable tradeoff outside of production.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}
