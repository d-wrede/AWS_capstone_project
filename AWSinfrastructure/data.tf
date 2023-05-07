
# get the current account id
data "aws_caller_identity" "current" {}

# get the current user id
data "aws_canonical_user_id" "current" {}

# get the policy document for the lambda function
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}