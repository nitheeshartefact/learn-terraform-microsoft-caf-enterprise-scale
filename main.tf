
# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "~> 1.0.0"

  default_location = var.default_location

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
  library_path   = "${path.root}/lib"


  custom_landing_zones = {
    "${var.root_id}-dev" = {
      display_name               = "${upper(var.root_id)} DEV"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = var.subscription_id_LZ_DEV
      archetype_config = {
        archetype_id   = "policy"
        parameters     = {}
        access_control = {}
      }
    }
    "${var.root_id}-staging" = {
      display_name               = "${upper(var.root_id)} STAGING"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = var.subscription_id_LZ_STG
      archetype_config = {
        archetype_id = "policy"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["uaenorth", "uaecentral" ]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["uaenorth", "uaecentral"]
          }
        }
        access_control = {}
      }
    }
    "${var.root_id}-production" = {
      display_name               = "${upper(var.root_id)} PRODUCTION"
      parent_management_group_id = "${var.root_id}-landing-zones"
      subscription_ids           = var.subscription_id_LZ_PRD
      archetype_config = {
        archetype_id = "policy"
        parameters = {
          Deny-Resource-Locations = {
            listOfAllowedLocations = ["uaenorth", "uaecentral"]
          }
          Deny-RSG-Locations = {
            listOfAllowedLocations = ["uaenorth", "uaecentral"]
          }
        }
        access_control = {}
      }
    }
  }
 # Deploy out of the box connectivity 
  deploy_connectivity_resources    = var.deploy_connectivity_resources
  subscription_id_connectivity     = var.subscription_id_connectivity
  configure_connectivity_resources = local.configure_connectivity_resources
 # Deploy out of the box identity resources 
  deploy_identity_resources = true
  subscription_id_identity  = var.subscription_id_identity
 # Deploy out of the box management resources 
 # https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Management-Resources-With-Custom-Settings
  deploy_management_resources    = var.deploy_management_resources
  subscription_id_management     = var.subscription_id_management
  configure_management_resources = local.configure_management_resources
}

  