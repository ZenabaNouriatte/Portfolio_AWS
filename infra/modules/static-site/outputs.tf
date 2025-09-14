# ARN du certificat (pour l'attacher ensuite à CloudFront)
output "acm_arn" {
  value       = aws_acm_certificate.site.arn
  description = "ARN du certificat ACM (us-east-1)"
}

# CNAMEs de validation DNS à créer chez OVH
# Clé = domaine validé ; valeur = { name, type, value }
output "acm_validation_records" {
  description = "Enregistrements DNS (CNAME) à créer pour valider le certificat"
  value = {
    for dvo in aws_acm_certificate.site.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

output "site_bucket" { value = aws_s3_bucket.site.bucket }
output "cloudfront_domain" { value = aws_cloudfront_distribution.site.domain_name }
output "cloudfront_distribution_id" { value = aws_cloudfront_distribution.site.id }
