### RESOURCE GROUP ###

resource "azurerm_resource_group" "sdm_example_group" {
  name     = "${var.prefix}-resources"
  location = var.location
}

### NETWORK ###

resource "azurerm_virtual_network" "sdm_example_network" {
  name                = "${var.prefix}-network"
  resource_group_name = azurerm_resource_group.sdm_example_group.name
  location            = azurerm_resource_group.sdm_example_group.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sdm_example_pub_sub" {
  name                 = "${var.prefix}_Public_Subnet"
  resource_group_name  = azurerm_resource_group.sdm_example_group.name
  virtual_network_name = azurerm_virtual_network.sdm_example_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sdm_example_priv_sub" {
  name                 = "${var.prefix}_Private_Subnet"
  resource_group_name  = azurerm_resource_group.sdm_example_group.name
  virtual_network_name = azurerm_virtual_network.sdm_example_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# PRIVATE SUBNET SECURITY SETTINGS

resource "azurerm_network_security_group" "sdm_priv_sec_group" {
  name                = "${var.prefix}-priv-sec-group"
  location            = var.location
  resource_group_name = azurerm_resource_group.sdm_example_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "PSQL"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "MYSQL"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WEB"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Public Subnet Denial"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

}