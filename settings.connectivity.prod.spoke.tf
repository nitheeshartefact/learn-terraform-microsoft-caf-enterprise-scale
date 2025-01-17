resource "random_string" "suffix_prd" {
  length  = 8
  special = false
  upper   = false
  lower   = true
#   number  = true
}

locals {
  prefix-spoke3         = "prd-spoke"
  spoke3-location       = var.connectivity_resources_location
  spoke3-resource-group = "prd-spoke-vnet-rg-${random_string.suffix_prd.result}"
}

# Resource Group for Spoke
resource "azurerm_resource_group" "spoke3-vnet-rg" {
  name     = local.spoke3-resource-group
  location = var.default_location
}

# Virtual Network for Spoke
resource "azurerm_virtual_network" "spoke3-vnet" {
  name                = "${local.prefix-spoke3}-vnet"
  location            = azurerm_resource_group.spoke3-vnet-rg.location
  resource_group_name = azurerm_resource_group.spoke3-vnet-rg.name
  address_space       = var.spoke3-cidr-address-space

  tags = {
    environment = local.prefix-spoke3
  }
}

# Subnet for Management in Spoke
resource "azurerm_subnet" "spoke3-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke3-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.spoke3-vnet.name
  address_prefixes     = var.spoke3-mgmt-address-space
}

# Subnet for Workload in Spoke
resource "azurerm_subnet" "spoke3-workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke3-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.spoke3-vnet.name
  address_prefixes     = var.spoke3-workload-address-space
}

# Peering from spoke3 to Hub
resource "azurerm_virtual_network_peering" "spoke3-hub-peer" {
  name                      = "spoke3-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke3-vnet-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke3-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.spoke3-vnet,
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

# Network Interface for spoke3
resource "azurerm_network_interface" "spoke3-nic" {
  name                 = "${local.prefix-spoke3}-nic"
  location             = azurerm_resource_group.spoke3-vnet-rg.location
  resource_group_name  = azurerm_resource_group.spoke3-vnet-rg.name
#   enable_ip_forwarding = true

  ip_configuration {
    name                          = "${local.prefix-spoke3}-nic-config"
    subnet_id                     = azurerm_subnet.spoke3-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}



# Peering from Hub to spoke3
resource "azurerm_virtual_network_peering" "hub-spoke3-peer" {
  name                         = "hub-spoke3-peer"
  resource_group_name          = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name         = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke3-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_virtual_network.spoke3-vnet,
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}
