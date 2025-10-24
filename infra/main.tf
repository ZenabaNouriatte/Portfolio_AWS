module "bootstrap_backend" {
  source             = "./modules/bootstrap-backend"
  project            = var.project
  environment        = var.environment
  bucket_name_prefix = var.bucket_name_prefix
}

module "static_site" {
  source = "./modules/static-site"
  providers = {
    aws      = aws
    aws.use1 = aws.use1
  }

  project             = var.project
  environment         = var.environment
  domain_root         = var.domain_root
  price_class         = var.price_class
  default_root_object = var.default_root_object
}

module "visit_api" {
  source      = "./modules/visit-api"
  project     = var.project
  environment = var.environment

  # table_name = "visit-counter"
}
