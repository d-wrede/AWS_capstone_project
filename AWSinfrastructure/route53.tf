resource "aws_route53_zone" "portfolio_zone" {
  name = "example.com"
}

resource "aws_route53_record" "portfolio_record" {
  zone_id = aws_route53_zone.portfolio_zone.id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.portfolio_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.portfolio_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
