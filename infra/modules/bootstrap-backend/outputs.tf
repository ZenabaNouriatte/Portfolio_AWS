output "state_bucket" {
  value       = aws_s3_bucket.tf_state.bucket
  description = "Nom du bucket de state"
}

output "lock_table" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "Nom de la table DynamoDB de lock"
}
