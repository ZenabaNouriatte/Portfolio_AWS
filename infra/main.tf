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

  project                   = var.project
  environment               = var.environment
  domain_name               = "www.zenabamogne.fr"
  subject_alternative_names = []
  price_class               = "PriceClass_100"
  default_root_object       = "index.html"
}

module "visit_api" {
  source      = "./modules/visit-api"
  project     = var.project
  environment = var.environment

  # Optionnel, pour garder EXACTEMENT "visit-counter"
  # table_name = "visit-counter"
}
