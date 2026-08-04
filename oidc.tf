# One OIDC identity provider per cluster - this is what makes IRSA possible.
# Once registered, IAM roles can trust specific Kubernetes ServiceAccounts
# (scoped by namespace:serviceaccount via the sub claim, see irsa.tf) rather
# than trusting the node role's broad permissions. Same federated-identity
# pattern as the GitHub Actions OIDC trust set up earlier - EKS's version of
# the same mechanism.
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}
