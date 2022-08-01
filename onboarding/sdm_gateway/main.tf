terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
  }
}

### GATEWAY ###

resource "azurerm_network_security_group" "sdm_gw_sec_group" {
  name                = "${var.prefix}-gateway-sec-group"
  location            = var.location
  resource_group_name = var.az_resource_group

  security_rule {
    name                       = "SDM-Public-Sec-Group"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "sdm_gw_sec_group_association" {
  network_interface_id      = azurerm_network_interface.sdm_gateway_nic.id
  network_security_group_id = azurerm_network_security_group.sdm_gw_sec_group.id
}


resource "azurerm_public_ip" "sdm_public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = var.location
  resource_group_name = var.az_resource_group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "sdm_gateway_nic" {
  name                = "sdm-gateway-nic"
  location            = var.location
  resource_group_name = var.az_resource_group
  tags = merge({ Name = "${var.prefix}-gw-nic" }, var.tags)

  ip_configuration {
    name                          = "sdm-public-gateway-nic-ip"
    subnet_id                     = var.gateway_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sdm_public_ip.id
  }

}

resource "azurerm_linux_virtual_machine" "sdm_gateway" {
  depends_on            = [sdm_node.sdm_gateway_01]
  name                  = "${var.prefix}-gateway"
  location              = var.location
  resource_group_name   = var.az_resource_group
  network_interface_ids = [azurerm_network_interface.sdm_gateway_nic.id]
  size                  = "Standard_DS1_v2"
  tags = merge({ Name = "${var.prefix}-gw" }, var.tags)

  os_disk {
    name                 = "GatewayOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "${var.prefix}-gateway-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_key
  }

  custom_data = base64encode(templatefile("${path.module}/templates/relay_install/relay_install.tftpl", { SDM_TOKEN = "${sdm_node.sdm_gateway_01.gateway[0].token}" }))
}

resource "sdm_node" "sdm_gateway_01" {
  gateway {
    name           = "${var.prefix}-gw1"
    listen_address = "${azurerm_public_ip.sdm_public_ip.ip_address}:5000"
    tags = merge({ Name = "${var.prefix}-gw1" }, var.tags)
  }
}

### RELAY ###

resource "azurerm_linux_virtual_machine" "sdm-relay" {
  name                  = "${var.prefix}-relay"
  location              = var.location
  resource_group_name   = var.az_resource_group
  network_interface_ids = [azurerm_network_interface.sdm_relay_nic.id]
  size                  = "Standard_DS1_v2"
  tags = merge({ Name = "${var.prefix}-relay" }, var.tags)

  os_disk {
    name                 = "RelayOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "sdm-relay-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_key
  }

  custom_data = base64encode(templatefile("${path.module}/templates/relay_install/relay_install.tftpl", { SDM_TOKEN = "${sdm_node.sdm_relay_01.relay[0].token}" }))
}

resource "sdm_node" "sdm_relay_01" {
  relay {
    name = "${var.prefix}-relay1"
    tags = merge({ Name = "${var.prefix}-relay1" }, var.tags)
  }
}

resource "azurerm_network_interface_security_group_association" "sdm_relay_priv_sec_group_association" {
  network_interface_id      = azurerm_network_interface.sdm_relay_nic.id
  network_security_group_id = var.priv_sec_group
}

resource "azurerm_network_interface" "sdm_relay_nic" {
  name                = "sdm-relay-nic"
  location            = var.location
  resource_group_name = var.az_resource_group
  tags = merge({ Name = "${var.prefix}-relay-nic" }, var.tags)

  ip_configuration {
    name                          = "sdm-private-relay-nic-ip"
    subnet_id                     = var.relay_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}