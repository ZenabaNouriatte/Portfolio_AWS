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
  description = "Préfixe unique pour le bucket (ex: ton pseudo)"
}
