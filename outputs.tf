# These are what you'll need to paste into the console when manually
# configuring the EKS cluster's networking.

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
