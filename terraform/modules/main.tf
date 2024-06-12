
data "aws_caller_identity" "current" {}

variable "name_prefix" {
  description = "Prefix for the resource names"
  type        = string
}
resource "aws_iam_role" "iam_role" {
  name = "${var.name_prefix}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "iam_policy" {
  name = "${var.name_prefix}-policy"
  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : "sts:AssumeRole",
          Resource : "${aws_iam_role.iam_role.arn}"
        }
      ]
    }
  )

}
resource "aws_iam_group" "iam_group" {
  name = "${var.name_prefix}-group"
}

resource "aws_iam_user" "iam_user" {
  name = "${var.name_prefix}-user"
}

resource "aws_iam_group_policy_attachment" "group_policy_attachment" {
  group      = aws_iam_group.iam_group.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_group_membership" "iam_group_membership" {
  name  = "${var.name_prefix}-group-membership"
  users = [aws_iam_user.iam_user.name]
  group = aws_iam_group.iam_group.name
}
