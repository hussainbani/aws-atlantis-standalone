# IAM role for instance profile
data "aws_iam_policy_document" "role" {
  for_each = var.instance_iam_role == null ? toset(["iam-instance-profile"]) : []
  statement {
    sid    = "AllowEC2STSAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }

}

resource "aws_iam_role" "role" {
  for_each = var.instance_iam_role == null ? toset(["iam-instance-profile"]) : []
  name     = "${var.name}-instance_role"
  path     = "/"

  assume_role_policy = data.aws_iam_policy_document.role["iam-instance-profile"].json
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.name}-instance_profile"
  role = var.instance_iam_role == null ? aws_iam_role.role["iam-instance-profile"].name : var.instance_iam_role
}


# Attach policy to allow SSM agent to operate
resource "aws_iam_role_policy_attachment" "ssm" {
  for_each   = var.instance_iam_role == null ? toset(["iam-instance-profile"]) : []
  role       = aws_iam_role.role["iam-instance-profile"].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "policy" {
  for_each = var.instance_iam_role == null ? { for v in var.additional_policies : v.name => v } : {}

  description = lookup(each.value, "description", "Additional IAM policy for instance profile")
  name        = each.key
  name_prefix = lookup(each.value, "name_prefix", "")
  path        = lookup(each.value, "path", "/")
  policy      = lookup(each.value, "policy", "")

  tags = merge(local.tags, var.additional_tags)
}

resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = var.instance_iam_role == null ? { for v in var.additional_policies : v.name => v } : {}
  role       = aws_iam_role.role["iam-instance-profile"].name
  policy_arn = aws_iam_policy.policy[each.key].arn
}


resource "aws_iam_role_policy_attachment" "additional_policy" {
  for_each   = var.instance_iam_role == null ? toset(var.additional_policies_arn) : []
  role       = aws_iam_role.role["iam-instance-profile"].name
  policy_arn = each.value
}