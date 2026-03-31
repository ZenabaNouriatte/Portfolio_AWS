provider "aws" {
  region = "eu-west-3"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
