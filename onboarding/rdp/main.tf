terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
  }
}

### RDP ###

resource "azurerm_network_interface_security_group_association" "sdm_rdp_priv_sec_group_association" {
  network_interface_id      = azurerm_network_interface.sdm_rdp_nic.id
  network_security_group_id = var.priv_sec_group
}

resource "azurerm_network_interface" "sdm_rdp_nic" {
  name                = "sdm-rdp-nic"
  location            = var.location
  resource_group_name = var.az_resource_group
  tags = merge({ Name = "${var.prefix}-rdp-nic" }, var.tags)

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.rdp_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "sdm_rdp" {
  name                = "sdm-rdp-1"
  resource_group_name = var.az_resource_group
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.sdm_rdp_nic.id,
  ]
  tags     = merge({ Name = "${var.prefix}-rdp" }, var.tags)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "sdm_resource" "rdp_server" {
  rdp {
    name     = "${var.prefix}-rdp"
    hostname = azurerm_windows_virtual_machine.sdm_rdp.private_ip_address
    port     = 3389
    username = "adminuser"
    password = "P@$$w0rd1234!"
    tags     = merge({ Name = "${var.prefix}-rdp" }, var.tags)
  }
}