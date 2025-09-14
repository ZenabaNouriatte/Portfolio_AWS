output "state_bucket" {
  value = module.bootstrap_backend.state_bucket
}

output "lock_table" {
  value = module.bootstrap_backend.lock_table
}

output "acm_arn" {
  value = module.static_site.acm_arn
}

output "acm_validation_records" {
  value = module.static_site.acm_validation_records
}

output "api_url" { value = module.visit_api.api_url }
output "cloudfront_domain" { value = module.static_site.cloudfront_domain }
output "cloudfront_dist_id" { value = module.static_site.cloudfront_distribution_id }
output "site_bucket" { value = module.static_site.site_bucket }


output "ddb_table" {
  value       = module.visit_api.table_name
  description = "Nom de la table DynamoDB pour le compteur"
}

