variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain_name" {
  type    = string
  default = "www.zenabamogne.fr"
}

variable "subject_alternative_names" {
  type    = list(string)
  default = []
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}
