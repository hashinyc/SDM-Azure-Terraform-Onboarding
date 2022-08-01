# ---------------------------------------------------------------------------- #
# These data-sources gather the necessary VPC information if create Resource Group is not specified
# ---------------------------------------------------------------------------- #
data "azurerm_resource_group" "default" {
  count   = var.create_resource_group ? 0 : 1
  name = var.az_resource_group
}

data "azurerm_subnet" "subnets" {
  count  = var.create_resource_group ? 0 : 1
  resource_group_name = data.azurerm_resource_group.default[0].name
  name = var.az_subnet_name
  virtual_network_name = var.az_virtual_network
}

data "azurerm_ssh_public_key" "ssh_key" {
  count = var.create_ssh_key ? 0 : 1
  name = var.az_ssh_pub_key_name
  resource_group_name = var.create_resource_group ? module.network[0].resource_group_name : data.azurerm_resource_group.default[0].name
}

data "azurerm_network_security_group" "sec_group" {
  count = var.create_resource_group ? 0 : 1
  name = var.az_network_security_group
  resource_group_name = var.create_resource_group ? module.network[0].resource_group_name : data.azurerm_resource_group.default[0].name
}

# ---------------------------------------------------------------------------- #
# Grab the strongDM CA public key for the authenticated organization
# ---------------------------------------------------------------------------- #
data "sdm_ssh_ca_pubkey" "this_key" {}
