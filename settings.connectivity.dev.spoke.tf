
resource "random_string" "suffix_dev" {
  length  = 8
  special = false
  upper   = false
  lower   = true
#   number  = true
}

locals {
  prefix-spoke1         = "dev-spoke"
  spoke1-location       = var.connectivity_resources_location
  spoke1-resource-group = "dev-spoke-vnet-rg-${random_string.suffix_dev.result}"
}

# Resource Group for Spoke
resource "azurerm_resource_group" "spoke1-vnet-rg" {
  name     = local.spoke1-resource-group
  location = var.default_location
}

# Virtual Network for Spoke
resource "azurerm_virtual_network" "spoke1-vnet" {
  name                = "${local.prefix-spoke1}-vnet"
  location            = azurerm_resource_group.spoke1-vnet-rg.location
  resource_group_name = azurerm_resource_group.spoke1-vnet-rg.name
  address_space       = var.spoke1-cidr-address-space

  tags = {
    environment = local.prefix-spoke1
  }
}

# Subnet for Management in Spoke
resource "azurerm_subnet" "spoke1-mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke1-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.spoke1-vnet.name
  address_prefixes     = var.spoke1-mgmt-address-space
}

# Subnet for Workload in Spoke
resource "azurerm_subnet" "spoke1-workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke1-vnet-rg.name
  virtual_network_name = azurerm_virtual_network.spoke1-vnet.name
  address_prefixes     = var.spoke1-workload-address-space
}

# Peering from Spoke1 to Hub
resource "azurerm_virtual_network_peering" "spoke1-hub-peer" {
  name                      = "spoke1-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke1-vnet-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke1-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true

  depends_on = [
    azurerm_virtual_network.spoke1-vnet,
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

# Network Interface for Spoke1
resource "azurerm_network_interface" "spoke1-nic" {
  name                 = "${local.prefix-spoke1}-nic"
  location             = azurerm_resource_group.spoke1-vnet-rg.location
  resource_group_name  = azurerm_resource_group.spoke1-vnet-rg.name
#   enable_ip_forwarding = true

  ip_configuration {
    name                          = "${local.prefix-spoke1}-nic-config"
    subnet_id                     = azurerm_subnet.spoke1-mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}



# Peering from Hub to Spoke1
resource "azurerm_virtual_network_peering" "hub-spoke1-peer" {
  name                         = "hub-spoke1-peer"
  resource_group_name          = azurerm_resource_group.hub-vnet-rg.name
  virtual_network_name         = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1-vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_virtual_network.spoke1-vnet,
    azurerm_virtual_network.hub-vnet,
    azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}
