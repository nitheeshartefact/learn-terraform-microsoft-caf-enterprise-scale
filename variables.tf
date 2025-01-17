# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# The following variable are used to simplify the process of customizing 
# important settings and provide the foundation for what needs to be true when 
# deploying multiple instances of the module into a single Tenant.

# With the exception of subscription_id_management and 
# subscription_id_connectivity, these are all given values via the included 
# .tfvars files.



variable "subscription_id" {
  type        = string
  default     = "4e0fe0d0-1b67-414a-9b61-9b1f68a4deef"
  description = "Sets the Subscription ID to use for resources."
}

variable "subscription_id_management" {
  type        = string
  default     = "4e0fe0d0-1b67-414a-9b61-9b1f68a4deef"
  description = "Sets the Subscription ID to use for Management resources."
}

variable "subscription_id_connectivity" {
  type        = string
  default     = "4e0fe0d0-1b67-414a-9b61-9b1f68a4deef"
  description = "Sets the Subscription ID to use for Connectivity resources."
}

variable "subscription_id_identity" {
  type        = string
  default     = "aed5a54f-b376-4308-a1d9-90384150d3b7"
  description = "Sets the Subscription ID to use for Identity resources."
}

variable "subscription_id_LZ_DEV" {
  type        = string
  default     = "aed5a54f-b376-4308-a1d9-90384150d3b7"
  description = "Sets the Subscription ID to use for landing zone Dev"
}

variable "subscription_id_LZ_STG" {
  type        = string
  default     = "aed5a54f-b376-4308-a1d9-90384150d3b7"
  description = "Sets the Subscription ID to use for landing zone STG"
}

variable "subscription_id_LZ_PRD" {
  type        = string
  default     = "aed5a54f-b376-4308-a1d9-90384150d3b7"
  description = "Sets the Subscription ID to use for landing zone PRD"
}

variable "root_id" {
  type        = string
  default     = "dld"
  description = "Sets the ID associated with the \"customer root\" Management Group and the default prefix used for most resources deployed as part of Enterprise-scale."
}

variable "root_name" {
  type        = string
  default     = "dld-org"
  description = "Sets the displayName value for the \"customer root\" Management Group."
}

variable "default_location" {
  type        = string
  default     = "uaenorth"
  description = "Sets the default location for resources, including references to location within Policy templates."
}

variable "deploy_corp_landing_zones" {
  type        = bool
  default     = false
  description = "If set to true, will deploy the \"Corp\" landing zones in addition to any core and custom landing zones."
}

variable "deploy_online_landing_zones" {
  type        = bool
  default     = false
  description = "If set to true, will deploy the \"Online\" landing zones in addition to any core and custom landing zones."
}

variable "deploy_sap_landing_zones" {
  type        = bool
  default     = false
  description = "If set to true, will deploy the \"SAP\" landing zones in addition to any core and custom landing zones."
}

variable "deploy_management_resources" {
  type        = bool
  default     = true
  description = "If set to true, will deploy the management resources in the Subscription assigned as the Management landing zone."
}

variable "log_retention_in_days" {
  type    = number
  default = 50
}

variable "security_alerts_email_address" {
  type    = string
  default = "nitheeshpanicker@npanicker.com" 
}

variable "management_resources_location" {
  type    = string
  default = "uaenorth"
}

variable "management_resources_tags" {
  type = map(string)
  default = {
    demo_type = "deploy_management_resources_custom"
  }
}

variable "deploy_connectivity_resources" {
  type        = bool
  default     = true
  description = "If set to true, will deploy the connectivity resources in the Subscription assigned as the Connectivity landing zone."
}

variable "connectivity_resources_location" {
  type    = string
  default = "uaenorth"
}

variable "connectivity_resources_tags" {
  type = map(string)
  default = {
    demo_type = "deploy_connectivity_resources_custom"
  }
}

variable "security_contact_email_address" {
  type        = string
  default     = "nitheeshpanicker@npanicker.com"
  description = "Sets the security contact email address used when configuring Azure Security Center."
}

variable "hub-shared-key" {
  type        = string
  default     = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
  description = "Shared Key for Hub-Vnet"
}

variable "hub-cidr-address-space" {
  type        = list
  default     = ["10.120.0.0/16",]
  description = "CIDR bloc"
}

variable "hub-firewall-address-prefix" {
  type        = string
  default     = "10.120.0.0/24"
  description = "Dedicated subnet for Azure Firewall"
}


variable "hub-app-address-prefix" {
  type        = string
  default     = "10.120.1.0/24"
  description = "Subnet for application servers"
}

variable "hub-db-address-prefix" {
  type        = string
  default     = "10.120.2.0/24"
  description = "Subnet for databases"
}

variable "hub-gateway-address-space" {
  type        = list
  default     = ["10.120.3.0/24" , ]
  description = "Dedicated subnet for hub Gateway .Enables VPN or ExpressRoute connectivity"
}

variable "hub-gateway-address-prefix" {
  type        = string
  default     = "10.120.3.0/24" 
  description = "Dedicated subnet for hub Gateway .Enables VPN or ExpressRoute connectivity"
}

variable "hub-mgmt-address-space" {
  type        = list
  default     = ["10.120.4.0/24",]
  description = "Dedicated subnet for Hub Mgmt.Hosts jump servers, monitoring agents, etc"
}

variable "hub-mgmt-address-prefix" {
  type        = string
  default     = "10.120.4.0/24"
  description = "Dedicated prefix for Hub Mgmt.Hosts jump servers, monitoring agents, etc"
}

variable "hub-dmz-address-space" {
  type        = list
  default     = ["10.120.5.0/24", ]
  description = "Dedicated subnet for Hub DMZ.For external-facing security services .Acts as a buffer zone for external connections"
}

variable "hub-dmz-address-prefix" {
  type        = string
  default     = "10.120.5.0/24"
  description = "Dedicated prefix for Hub DMZ.For external-facing security services .Acts as a buffer zone for external connections"
}


variable "spoke1-cidr-address-space" {
  type    = list(string)
  default = ["10.130.0.0/16"]
}

variable "spoke1-mgmt-address-space" {
  type    = list(string)
  default = ["10.130.0.64/27"]
}

variable "spoke1-workload-address-space" {
  type    = list(string)
  default = ["10.130.1.0/24"]
}


variable "spoke2-cidr-address-space" {
  type    = list(string)
  default = ["10.140.0.0/16"]
}

variable "spoke2-mgmt-address-space" {
  type    = list(string)
  default = ["10.140.0.64/27"]
}

variable "spoke2-workload-address-space" {
  type    = list(string)
  default = ["10.140.1.0/24"]
}


variable "spoke3-cidr-address-space" {
  type    = list(string)
  default = ["10.150.0.0/16"]
}

variable "spoke3-mgmt-address-space" {
  type    = list(string)
  default = ["10.150.0.64/27"]
}

variable "spoke3-workload-address-space" {
  type    = list(string)
  default = ["10.150.1.0/24"]
}