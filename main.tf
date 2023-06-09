resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${random_string.suffix.result}"
  location = var.region
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-${random_string.suffix.result}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  kubernetes_version = var.kubernetes_version
  dns_prefix         = "k8s-${random_string.suffix.result}"

  default_node_pool {
    name            = "default"
    node_count      = var.aks_node_count
    vm_size         = var.aks_confidential_computing_enabled ? "Standard_DC2s_v2" : "Standard_D2_v2"
    os_sku          = var.aks_os_sku
    os_disk_size_gb = 50
  }

  confidential_computing {
    sgx_quote_helper_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = {
    name        = "alliances-aks-${random_string.suffix.result}"
    environment = "Demo"
  }
}