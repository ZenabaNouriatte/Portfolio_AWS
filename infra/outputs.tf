output "state_bucket" {
  value = module.bootstrap_backend.state_bucket
}

# Output lock_table supprimé - Plus besoin avec le verrouillage natif S3

output "acm_arn" {
  value       = module.static_site.acm_arn
  description = "ARN du cert ACM (us-east-1)"
}

output "acm_dns_validation_records" {
  value       = module.static_site.acm_dns_validation_records
  description = "CNAMEs à créer dans OVH pour valider le certificat"
}

output "api_url" { value = module.visit_api.api_url }
output "cloudfront_domain" {
  value       = module.static_site.cloudfront_domain != null ? module.static_site.cloudfront_domain : null
  description = "Domaine CloudFront (si exposé côté module)"
}
output "cloudfront_dist_id" { value = module.static_site.cloudfront_distribution_id }
output "site_bucket" { value = module.static_site.site_bucket }


output "ddb_table" {
  value       = module.visit_api.table_name
  description = "Nom de la table DynamoDB pour le compteur"
}

