terraform {
  required_version = ">= 0.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

module "network" {
  count        = var.create_resource_group ? 1 : 0
  source       = "./network"
  prefix       = var.prefix
  location = var.location
  default_tags = local.default_tags
  tags         = var.tags
}

module "cert" {
  count = var.create_ssh_key ? 1 : 0
  source = "./cert"
}

module "sdm" {
  count         = var.create_strongdm_gateways ? 1 : 0
  source        = "./sdm_gateway"
  prefix       = var.prefix
  location = var.location
  az_resource_group = local.resource_group_name
  gateway_subnet_id = local.public_subnet_id
  relay_subnet_id = local.private_subnet_id
  priv_sec_group = local.priv_sec_group
  ssh_key = local.ssh_key
  tags = merge(local.default_tags, var.tags)
}

module "psql" {
  count =  var.create_psql ? 1 : 0
  create_ssh = var.create_ssh ? 1 : 0
  source = "./psql"
  prefix       = var.prefix
  location = var.location
  az_resource_group = local.resource_group_name
  psql_subnet_id = local.private_subnet_id
  priv_sec_group = local.priv_sec_group
  ssh_key = local.ssh_key
  sdm_pub_key =  data.sdm_ssh_ca_pubkey.this_key.public_key
  tags = merge(local.default_tags, var.tags)
}

module "mysql" {
  count =  var.create_mysql ? 1 : 0
  create_ssh = var.create_ssh ? 1 : 0
  source = "./mysql"
  prefix       = var.prefix
  location = var.location
  az_resource_group = local.resource_group_name
  mysql_subnet_id = local.private_subnet_id
  priv_sec_group = local.priv_sec_group
  ssh_key = local.ssh_key
  sdm_pub_key =  data.sdm_ssh_ca_pubkey.this_key.public_key
  tags = merge(local.default_tags, var.tags)
}

module "web" {
  count =  var.create_http ? 1 : 0
  create_ssh = var.create_ssh ? 1 : 0
  source = "./web"
  prefix       = var.prefix
  location = var.location
  az_resource_group = local.resource_group_name
  web_subnet_id = local.private_subnet_id
  priv_sec_group = local.priv_sec_group
  ssh_key = local.ssh_key
  sdm_pub_key =  data.sdm_ssh_ca_pubkey.this_key.public_key
  tags = merge(local.default_tags, var.tags)
}

module "aks" {
  count = var.create_aks ? 1 : 0
  source = "./aks"
  prefix       = var.prefix
  location = var.location
  az_resource_group = local.resource_group_name
  ssh_key = local.ssh_key
  service_principal_id = var.service_principal_id
  service_principal_secret = var.service_principal_secret
  tags = merge(local.default_tags, var.tags)
}

module "rdp" {
  count = var.create_rdp ? 1 : 0
  source = "./rdp"
  prefix       = var.prefix
  location = var.location
  az_resource_group = local.resource_group_name
  rdp_subnet_id = local.private_subnet_id
  priv_sec_group = local.priv_sec_group
  tags = merge(local.default_tags, var.tags)
}