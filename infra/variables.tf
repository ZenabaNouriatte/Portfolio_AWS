variable "project" {
  type        = string
  default     = "portfolio"
  description = "Nom du projet"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environnement"
}

variable "bucket_name_prefix" {
  type        = string
  default     = "zenaba"
  description = "Préfixe unique pour le bucket (ex: ton pseudo)"
}

variable "region_primary" {
  type    = string
  default = "eu-west-3"
}

variable "domain_root" {
  type        = string
  default     = "zenabamogne.fr"
  description = "Nom de domaine racine (ex: zenabamogne.fr)"
}



variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "default_root_object" {
  type    = string
  default = "index.html"
}
