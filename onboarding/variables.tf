variable "tags" {
  type        = map(string)
  default     = {}
  description = "This tags will be added to both Azure and strongDM resources"
}

variable "prefix" {
  type        = string
  description = "This prefix will be added to various resource names."
}

variable "location" {
  type        = string
  description = "Location you'd wish the Azure Resources to be created in."
}

variable "create_aks" {
  type        = bool
  default     = false
  description = "Set to true to create an AKS cluster."
}

variable "create_mysql" {
  type        = bool
  default     = false
  description = "Set to true to create an VM with MYSQL."
}

variable "create_psql" {
  type        = bool
  default     = true
  description = "Set to true to create an VM with PSQL."
}

variable "create_rdp" {
  type        = bool
  default     = false
  description = "Set to true to create a Windows Server."
}

variable "create_http" {
  type        = bool
  default     = false
  description = "Set to true to a HTTP resource."
}

variable "create_ssh" {
  type        = bool
  default     = true
  description = "Set to true this enables SSH on your other resources."
}

variable "create_ssh_key" {
  type        = bool
  default     = true
  description = "Create an ssh key pair to use with Azure."
}

variable "create_strongdm_gateways" {
  type        = bool
  default     = true
  description = "Set to true to create a pair of strongDM gateways."
}

variable "create_resource_group" {
  type        = bool
  default     = true
  description = "Set to true to create a Resource Group to contain the resources in this module."
}

variable "grant_to_existing_users" {
  type        = list(string)
  default     = []
  description = "A list of email addresses for existing accounts to be granted access to all resources."
}

variable "admin_users" {
  type        = list(string)
  default     = []
  description = "A list of email addresses that will be granted access to all resources."
}

variable "read_only_users" {
  type        = list(string)
  default     = []
  description = "A list of email addresses that will receive read only access."
}

variable "az_resource_group" {
  type = string
  description = "Name of the Azure Resource Group you'd like to use an existing Resource Group."
  default = ""
}

variable "az_virtual_network" {
  type = string
  description = "Name of the Azure Virtual Network you'd like to use an existing Resource Group."
  default = ""
}

variable "az_subnet_name" {
  type = string
  description = "Name of the Azure Subnet you'd like to use an existing Resource Group."
  default = ""
}

variable "az_ssh_pub_key_name" {
  type = string
  description = "Name of the Azure Public Key you'd like to use if you've already have one."
  default = ""
}

variable "az_network_security_group" {
  type = string
  description = "Name of the Azure Security Group you'd like to use if you don't create a Resource Group."
  default = ""
}

variable "service_principal_id" {
  type = string
  description = "AKS Service Principal ID"
  default = ""
}

variable "service_principal_secret" {
  type = string
  description = "AKS Service Principal Secret"
  default = ""
}

locals {
  resource_group_name         = var.create_resource_group ? module.network[0].resource_group_name : data.azurerm_resource_group.default[0].name
  public_subnet_id     = var.create_resource_group ? module.network[0].public_subnet : sort(data.azurerm_subnet.subnets[0].id)
  private_subnet_id     = var.create_resource_group ? module.network[0].private_subnet : sort(data.azurerm_subnet.subnets[0].id)
  priv_sec_group = var.create_resource_group ? module.network[0].priv_sec_group : data.azurerm_network_security_group.sec_group[0].id
  ssh_key = var.create_ssh_key ? module.cert[0].az_tls_private_key : data.azurerm_ssh_public_key.ssh_key[0].public_key
  default_tags   = { 
    CreatedBy = "strongDM-Onboarding" 
    Terraform = "true"
    }
}
