resource "random_string" "suffix_cert" {
  length  = 8
  special = false
  upper   = false
  lower   = true
#   number  = true
}

locals {
  prefix-spoke2         = "staging-spoke"
  spoke2-location       = var.connectivity_resources_location
  spoke2-resource-group = "staging-spoke-vnet-rg-${random_string.suffix_cert.result}"
}

# Resource Group for Spoke
resource "azurerm_resource_group" "spoke2-vnet-rg" {
  name     = local.spoke2-resource-group
  location = local.spoke2-location
}

# Virtual Network for Spoke
resource "azurerm_virtual_network" "spoke2-vnet" {
  name                = "${local.prefix-spoke2}-vnet"
  location            = azurerm_resource_group.spoke2-vnet-rg.location
  resource_group_name = azurerm_resource_group.spoke2-vnet-rg.name
  address_space       = var.spoke2-cidr-address-space

  tags = {
    environment = local.prefix-spoke2
  }
}

# Subnet for Management in Spoke
resource "azurerm_subnet" "spoke2-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke2-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.spoke2-vnet.name
  address_prefixes     = var.spoke2-mgmt-address-space
}

# Subnet for Workload in Spoke
resource "azurerm_subnet" "spoke2-workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke2-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.spoke2-vnet.name
  address_prefixes     = var.spoke2-workload-address-space
}

# Peering from spoke2 to Hub
resource "azurerm_virtual_network_peering" "spoke2-hub-peer" {
  name                      = "spoke2-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke2-vnet-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke2-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.spoke2-vnet,
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

# Network Interface for spoke2
resource "azurerm_network_interface" "spoke2-nic" {
  name                 = "${local.prefix-spoke2}-nic"
  location             = azurerm_resource_group.spoke2-vnet-rg.location
  resource_group_name  = azurerm_resource_group.spoke2-vnet-rg.name
#   enable_ip_forwarding = true

  ip_configuration {
    name                          = "${local.prefix-spoke2}-nic-config"
    subnet_id                     = azurerm_subnet.spoke2-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}



# Peering from Hub to spoke2
resource "azurerm_virtual_network_peering" "hub-spoke2-peer" {
  name                         = "hub-spoke2-peer"
  resource_group_name          = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name         = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_virtual_network.spoke2-vnet,
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}