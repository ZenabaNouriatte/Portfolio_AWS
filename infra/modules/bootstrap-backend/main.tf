# S3: bucket pour le state
resource "aws_s3_bucket" "tf_state" {
  bucket = "${var.bucket_name_prefix}-${var.project}-${var.environment}-tfstate"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
  lifecycle {
    prevent_destroy = true
  }
}

# Versioning du bucket ( pour l’historique du state)
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement côté serveur 
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Blocage d’accès public 
resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB: table de verrouillage
resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.project}-${var.environment}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
  lifecycle {
    prevent_destroy = true
  }
}
