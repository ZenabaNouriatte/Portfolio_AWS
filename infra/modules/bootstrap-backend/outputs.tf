output "state_bucket" {
  value       = aws_s3_bucket.tf_state.bucket
  description = "Nom du bucket de state"
}

# Output lock_table supprimé car plus besoin de DynamoDB
# Terraform 1.10+ utilise le verrouillage natif S3
