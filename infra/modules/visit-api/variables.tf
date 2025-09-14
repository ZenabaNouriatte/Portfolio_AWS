variable "project" { type = string }
variable "environment" { type = string }

# Nom de table DDB (optionnel si tu veux surcharger)
variable "table_name" {
  type    = string
  default = null
}

# Nom de la fonction Lambda
variable "function_name" {
  type    = string
  default = "visit-counter"
}

# FQDN API (sortie API GW) sera remonté en output
