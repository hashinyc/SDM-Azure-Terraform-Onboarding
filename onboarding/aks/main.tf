terraform {
  required_version = ">= 0.15.0"
  required_providers {
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 2.6.4"
    }
  }
}

### AKS ###

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}-aks-cluster"
  location            = var.location
  resource_group_name = var.az_resource_group
  dns_prefix          = "${var.prefix}-aks-cluster"
  tags = merge({ Name = "${var.prefix}-aks" }, var.tags)

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = var.ssh_key
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = var.service_principal_id
    client_secret = var.service_principal_secret
  }

}

resource "sdm_resource" "aks" {
  aks {
    name                  = "${var.prefix}-aks-cluster"
    hostname              = join("", [split(":", azurerm_kubernetes_cluster.k8s.kube_config.0.host)[0], ":", split(":", azurerm_kubernetes_cluster.k8s.kube_config.0.host)[1]])
    port                  = split(":", azurerm_kubernetes_cluster.k8s.kube_config.0.host)[2]
    certificate_authority = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
    client_certificate    = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key            = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    tags = merge({ Name = "${var.prefix}-aks" }, var.tags)
  }
}