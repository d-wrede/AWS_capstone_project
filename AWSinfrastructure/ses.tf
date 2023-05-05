######################
#   SES resources    #
######################


resource "aws_ses_receipt_rule_set" "rule_set" {
  rule_set_name = "portfolio-website-rule-set"
  provider      = aws.ses_provider
}

resource "aws_ses_active_receipt_rule_set" "active_rule_set" {
  rule_set_name = aws_ses_receipt_rule_set.rule_set.rule_set_name
  provider      = aws.ses_provider
}

resource "aws_ses_receipt_rule" "rule" {
    provider      = aws.ses_provider
    name          = local.receipt_rule_name
    rule_set_name = aws_ses_receipt_rule_set.rule_set.rule_set_name
    recipients    = ["daniel-wrede.de"]
    tls_policy    = "Optional"
    enabled       = true
    scan_enabled  = true

    s3_action {
        position          = "1"
        bucket_name       = aws_s3_bucket.email_bucket.bucket
        object_key_prefix = "emails"
    }
    lambda_action {
        position        = "2"
        function_arn    = aws_lambda_function.email_forwarder.arn
        invocation_type = "Event"
    }

    depends_on = [aws_lambda_permission.ses_invoke]
}

resource "aws_lambda_permission" "ses_invoke" {
  provider      = aws.ses_provider
  statement_id  = "AllowSESInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_forwarder.function_name
  principal     = "ses.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn    = "arn:aws:ses:${var.ses_region}:${data.aws_caller_identity.current.account_id}:receipt-rule-set/${aws_ses_receipt_rule_set.rule_set.rule_set_name}:receipt-rule/${local.receipt_rule_name}"
}

# my first local
locals {
  receipt_rule_name = "manage-emails-rule"
}
