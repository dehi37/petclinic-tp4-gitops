output "s3_bucket_name" {
  value       = aws_s3_bucket.tf_state.id
  description = "Nom du bucket S3 créé pour le Backend"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.tf_locks.id
  description = "Nom de la table DynamoDB créée"
}