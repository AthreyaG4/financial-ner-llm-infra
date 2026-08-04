# IRSA roles: unlike the node role (node_group.tf, shared by every pod on a
# node), each of these is scoped to exactly one Kubernetes ServiceAccount,
# via a trust-policy condition on the OIDC provider's sub/aud claims - the
# same "condition on the sub claim" pattern already used for GitHub Actions,
# just matching "system:serviceaccount:<namespace>:<name>" instead of a repo.
locals {
  oidc_provider_url = replace(aws_iam_openid_connect_provider.eks.url, "https://", "")
}

data "aws_caller_identity" "current" {}

# --- External Secrets Operator: read-only access to Secrets Manager ---

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.eso_namespace}:${var.eso_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "${var.project_name}-eso-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}

data "aws_iam_policy_document" "eso_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    # Scoped to secrets under this project's own name prefix, not every
    # secret in the account - name secrets accordingly when you create them
    # (e.g. "financial-ner-llm/backend-db"). The random suffix Secrets
    # Manager appends to each secret's real ARN still matches this wildcard.
    resources = ["arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*"]
  }
}

resource "aws_iam_policy" "eso_permissions" {
  name   = "${var.project_name}-eso-policy"
  policy = data.aws_iam_policy_document.eso_permissions.json
}

resource "aws_iam_role_policy_attachment" "eso_permissions" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso_permissions.arn
}

# --- AWS Load Balancer Controller: create/manage ALBs, target groups,
# listeners, and security groups on your behalf for Ingress resources ---

data "aws_iam_policy_document" "lb_controller_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.lb_controller_namespace}:${var.lb_controller_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  name               = "${var.project_name}-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json
}

# Official policy pulled directly from kubernetes-sigs/aws-load-balancer-
# controller (docs/install/iam_policy.json) - re-fetch that file if this
# ever needs updating rather than hand-editing the permissions here.
resource "aws_iam_policy" "lb_controller_permissions" {
  name   = "${var.project_name}-lb-controller-policy"
  policy = file("${path.module}/iam-policies/aws-load-balancer-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller_permissions" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller_permissions.arn
}
