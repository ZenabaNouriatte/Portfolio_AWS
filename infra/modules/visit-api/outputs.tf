
output "api_url" {
  description = "Invoke URL for HTTP API"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

# utile pour debug
output "api_base" {
  description = "API base endpoint (sans stage)"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "table_name" {
  value       = aws_dynamodb_table.visitors.name
  description = "DynamoDB table for visit counter"
}

