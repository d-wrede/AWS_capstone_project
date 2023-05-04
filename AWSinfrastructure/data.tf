
# get the current account id
data "aws_caller_identity" "current" {}

# get the current user id
data "aws_canonical_user_id" "current" {}
