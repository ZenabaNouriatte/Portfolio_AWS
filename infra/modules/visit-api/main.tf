########################################
# DynamoDB (clé: site_id)
########################################
resource "aws_dynamodb_table" "visitors" {
  name         = coalesce(var.table_name, "${var.project}-${var.environment}-visit-counter")
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "site_id"

  attribute {
    name = "site_id"
    type = "S"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

########################################
# IAM: role + policy minimal pour Lambda
########################################
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-${var.environment}-visit-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.visitors.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.project}-${var.environment}-visit-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

########################################
# Lambda (Python 3.12)
########################################
resource "aws_lambda_function" "visit" {
  function_name = "${var.project}-${var.environment}-${var.function_name}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  # Chemin vers ton zip
  filename         = "${path.module}/../../lambda/build.zip"
  source_code_hash = filebase64sha256("${path.module}/../../lambda/build.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitors.name
      PARTITION  = "site"
    }
  }
}

########################################
# API Gateway HTTP API
########################################
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project}-${var.environment}-visit-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"] # Tu pourras mettre https://www.zenabamogne.fr
    allow_methods = ["GET", "POST"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visit.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_visit" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /visit"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Autoriser APIGW à invoquer la Lambda
resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGWInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visit.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
