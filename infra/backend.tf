# À ACTIVER APRÈS le bootstrap :
# terraform {
#   backend "s3" {
#     bucket         = "zenaba-portfolio-dev-tfstate"
#     key            = "states/dev.tfstate"
#     region         = "eu-west-3"
#     dynamodb_table = "portfolio-dev-tf-lock"
#     encrypt        = true
#   }
# }
