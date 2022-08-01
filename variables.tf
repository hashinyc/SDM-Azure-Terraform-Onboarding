### SDM ###
variable "SDM_API_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "SDM_API_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "SDM_ADMINS_EMAILS" {
  type = string
}

### AZURE ###

variable "REGION_AZURE" {
  type = string
}
