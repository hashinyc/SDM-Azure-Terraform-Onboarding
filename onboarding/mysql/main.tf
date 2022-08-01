terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
  }
}

### MYSQL ###

resource "azurerm_network_interface_security_group_association" "sdm_mysql_priv_sec_group_association" {
  network_interface_id      = azurerm_network_interface.sdm_mysql_nic.id
  network_security_group_id = var.priv_sec_group
}

resource "azurerm_network_interface" "sdm_mysql_nic" {
  name                = "sdm-mysql-nic"
  location            = var.location
  resource_group_name = var.az_resource_group
  tags = merge({ Name = "${var.prefix}-mysql-nic" }, var.tags)

  ip_configuration {
    name                          = "sdm-private-mysql-nic-ip"
    subnet_id                     = var.mysql_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "sdm_mysql" {
  name                  = "${var.prefix}-mysql"
  location              = var.location
  resource_group_name   = var.az_resource_group
  network_interface_ids = [azurerm_network_interface.sdm_mysql_nic.id]
  size                  = "Standard_DS1_v2"
  tags = merge({ Name = "${var.prefix}-mysql" }, var.tags)

  os_disk {
    name                 = "MYSQLOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "sdm-mysql-01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_key
  }

  custom_data = base64encode(templatefile("${path.module}/templates/mysql_install/mysql_install.tftpl", { SSH_PUB_KEY = "${var.sdm_pub_key}" }))
}

resource "sdm_resource" "mysql_admin" {
  mysql {
    name     = "${var.prefix}-mysql-admin"
    hostname = azurerm_linux_virtual_machine.sdm_mysql.private_ip_address
    database = "strongdmdb"
    username = "strongdmadmin"
    password = "strongdmpassword123"
    port     = 3306

    tags = merge({ Name = "${var.prefix}-mysql-admin" }, var.tags)
  }
}

resource "sdm_resource" "mysql_ro" {
  mysql {
    name     = "${var.prefix}-mysql-ro"
    hostname = azurerm_linux_virtual_machine.sdm_mysql.private_ip_address
    database = "strongdmdb"
    username = "strongdmreadonly"
    password = "strongdmpassword123"
    port     = 3306

    tags = merge({ Name = "${var.prefix}-mysql-ro" }, var.tags)
  }
}

resource "sdm_resource" "mysql_ssh" {
  count = var.create_ssh
  ssh_cert {
    name     = "${var.prefix}-mysql-ssh"
    username = "azureuser"
    hostname = azurerm_linux_virtual_machine.sdm_mysql.private_ip_address
    port     = 22
    tags = merge({ Name = "${var.prefix}-mysql-ssh" }, var.tags)
  }
}
