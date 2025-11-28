terraform {
  backend "s3" {
    bucket  = "zenaba-portfolio-dev-tfstate"
    key     = "states/dev.tfstate"
    region  = "eu-west-3"
    encrypt = true
    use_lockfile = true
  }
}

