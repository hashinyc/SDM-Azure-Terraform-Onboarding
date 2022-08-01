output "resource_group_name" {
  value = azurerm_resource_group.sdm_example_group.name
}

output "resource_group_cidr_block" {
  value = azurerm_virtual_network.sdm_example_network.address_space
}

output "public_subnet" {
  value = azurerm_subnet.sdm_example_pub_sub.id
}

output "private_subnet" {
  value = azurerm_subnet.sdm_example_priv_sub.id
}

output "priv_sec_group" {
  value = azurerm_network_security_group.sdm_priv_sec_group.id
}