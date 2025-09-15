# ARN du certificat (pour l'attacher ensuite à CloudFront)
output "acm_arn" {
  description = "ARN du certificat ACM (us-east-1)"
  value       = aws_acm_certificate.site_cert.arn
}

output "acm_dns_validation_records" {
  description = "Enregistrements DNS de validation (à créer chez OVH)"
  value = [
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : {
      domain_name           = dvo.domain_name
      resource_record_name  = dvo.resource_record_name
      resource_record_type  = dvo.resource_record_type
      resource_record_value = dvo.resource_record_value
    }
  ]
}

output "site_bucket" { value = aws_s3_bucket.site.bucket }
output "cloudfront_domain" { value = aws_cloudfront_distribution.site.domain_name }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.site.id }
