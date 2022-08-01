terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
  }
}

### PSQL ###

resource "azurerm_network_interface_security_group_association" "sdm_psql_priv_sec_group_association" {
  network_interface_id      = azurerm_network_interface.sdm_psql_nic.id
  network_security_group_id = var.priv_sec_group
}

resource "azurerm_network_interface" "sdm_psql_nic" {
  name                = "sdm-psql-nic"
  location            = var.location
  resource_group_name = var.az_resource_group
  tags = merge({ Name = "${var.prefix}-psql-nic" }, var.tags)

  ip_configuration {
    name                          = "sdm-private-psql-nic-ip"
    subnet_id                     = var.psql_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "sdm_psql" {
  name                  = "${var.prefix}-psql"
  location              = var.location
  resource_group_name   = var.az_resource_group
  network_interface_ids = [azurerm_network_interface.sdm_psql_nic.id]
  size                  = "Standard_DS1_v2"
  tags = merge({ Name = "${var.prefix}-psql" }, var.tags)

  os_disk {
    name                 = "PSQLOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "sdm-psql-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_key
  }

  custom_data = base64encode(templatefile("${path.module}/templates/psql_install/psql_install.tftpl", { SSH_PUB_KEY = "${var.sdm_pub_key}" }))
}

resource "sdm_resource" "psql_admin" {
  postgres {
    name     = "${var.prefix}-psql-admin"
    hostname = azurerm_linux_virtual_machine.sdm_psql.private_ip_address
    database = "dvdrental"
    username = "postgres"
    password = "strongdmpassword123"
    port     = 5432

    tags = merge({ Name = "${var.prefix}-psql-admin" }, var.tags)
  }
}

resource "sdm_resource" "psql_ro" {
  postgres {
    name     = "${var.prefix}-psql-ro"
    hostname = azurerm_linux_virtual_machine.sdm_psql.private_ip_address
    database = "dvdrental"
    username = "read_user"
    password = "notastrongpassword123"
    port     = 5432

    tags = merge({ Name = "${var.prefix}-psql-ro" }, var.tags)
  }
}

resource "sdm_resource" "psql_ssh" {
  count = var.create_ssh
  ssh_cert {
    name     = "${var.prefix}-psql-ssh"
    username = "azureuser"
    hostname = azurerm_linux_virtual_machine.sdm_psql.private_ip_address
    port     = 22
    tags = merge({ Name = "${var.prefix}-psql-ssh" }, var.tags)
  }
}