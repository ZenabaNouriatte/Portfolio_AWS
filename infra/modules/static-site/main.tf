########################################
# Certificat ACM (us-east-1) pour CloudFront
########################################
resource "aws_acm_certificate" "site" {
  provider                  = aws.use1        # IMPORTANT: us-east-1
  domain_name               = var.domain_name # ex: "www.zenabamogne.fr"
  validation_method         = "DNS"
  subject_alternative_names = var.subject_alternative_names

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

########################################
# S3 privé (site)
########################################
resource "aws_s3_bucket" "site" {
  # ex: portfolio-dev-www-zenabamogne-fr-site
  bucket = "${var.project}-${var.environment}-${replace(var.domain_name, ".", "-")}-site"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################################
# OAC (Origin Access Control) pour S3 privé
########################################
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project}-${var.environment}-oac"
  description                       = "OAC for private S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################################
# Distribution CloudFront
########################################
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  price_class         = var.price_class
  default_root_object = var.default_root_object

  # Alias personnalisé (ton domaine)
  aliases = [var.domain_name] # ex: "www.zenabamogne.fr"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # Certificat ACM en us-east-1
    acm_certificate_arn      = aws_acm_certificate.site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }

  # Attendre le déploiement de la distrib avant de terminer l'apply
  wait_for_deployment = true
}

########################################
# Policy du bucket : n'autoriser QUE CloudFront (via OAC)
########################################

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid     = "AllowCloudFrontOAC"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.site.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    # N'autoriser que les requêtes provenant de TA distribution
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.site.id}"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [aws_cloudfront_distribution.site]
}
