terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
  }
}

### WEB ###

resource "azurerm_network_interface_security_group_association" "sdm_web_priv_sec_group_association" {
  network_interface_id      = azurerm_network_interface.sdm_web_nic.id
  network_security_group_id = var.priv_sec_group
}

resource "azurerm_network_interface" "sdm_web_nic" {
  name                = "sdm-web-nic"
  location            = var.location
  resource_group_name = var.az_resource_group
  tags = merge({ Name = "${var.prefix}-web-nic" }, var.tags)

  ip_configuration {
    name                          = "sdm-private-web-nic-ip"
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "sdm_web" {
  name                  = "${var.prefix}-web"
  location              = var.location
  resource_group_name   = var.az_resource_group
  network_interface_ids = [azurerm_network_interface.sdm_web_nic.id]
  size                  = "Standard_DS1_v2"
  tags = merge({ Name = "${var.prefix}-web" }, var.tags)

  os_disk {
    name                 = "WEBOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "sdm-web-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_key
  }

  custom_data = base64encode(templatefile("${path.module}/templates/web_install/web_install.tftpl", { SSH_PUB_KEY = "${var.sdm_pub_key}" }))
}

resource "sdm_resource" "azure_web" {
  http_no_auth {
    name             = "${var.prefix}-web"
    url              = "http://${azurerm_linux_virtual_machine.sdm_web.private_ip_address}"
    healthcheck_path = "/"
    default_path     = "/"
    subdomain        = "azure-website"

    tags = merge({ Name = "${var.prefix}-web" }, var.tags)
  }
}

resource "sdm_resource" "web_ssh" {
  count = var.create_ssh
  ssh_cert {
    name     = "${var.prefix}-web-ssh"
    username = "azureuser"
    hostname = azurerm_linux_virtual_machine.sdm_web.private_ip_address
    port     = 22
    tags = merge({ Name = "${var.prefix}-web-ssh" }, var.tags)
  }
}
