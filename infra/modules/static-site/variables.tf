variable "project" {
  type = string
}

variable "environment" {
  type = string
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

variable "domain_root" {
  type        = string
  description = "Apex domain (ex: zenabamogne.fr)"
}

