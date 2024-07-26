## Root provider requirements
terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = "~> 0.1.5"
    }
    jsc = {
      source  = "danjamf/jsctfprovider"
      version = "0.0.7"
    }
  }
}

## Jamf Pro provider root configuration
provider "jamfpro" {
  jamfpro_instance_fqdn                = var.jamfpro_instance_url
  auth_method                          = var.jamfpro_auth_method
  basic_auth_username                  = var.jamfpro_username
  basic_auth_password                  = var.jamfpro_password
  client_id                            = var.jamfpro_client_id
  client_secret                        = var.jamfpro_client_secret
  enable_client_sdk_logs               = false
  hide_sensitive_data                  = true # Hides sensitive data in logs
  token_refresh_buffer_period_seconds  = 5    # minutes
  jamfpro_load_balancer_lock           = true
  mandatory_request_delay_milliseconds = 100
}

## Initialize Jamf Pro child modules
module "jamfpro_demo_config" {
  count  = var.include_jamfpro_demo_config == true ? 1 : 0
  source = "./modules/jamfpro_demo_config/"
}

## Initialize Experience Jamf vignette modules
module "ej_base" {
  count  = var.include_ej_base == true ? 1 : 0
  source = "./modules/experience_jamf_vignettes/ej_base"
}

module "ej_incident_response" {
  count  = var.include_ej_incident_response == true ? 1 : 0
  source = "./modules/experience_jamf_vignettes/ej_incident_response"
}

module "ej_mac_cis_benchmark" {
  count  = var.include_ej_mac_cis_benchmark == true ? 1 : 0
  source = "./modules/experience_jamf_vignettes/ej_mac_cis_benchmark"
}

module "ej_mobile_cis_benchmark" {
  count  = var.include_ej_mobile_cis_benchmark == true ? 1 : 0
  source = "./modules/experience_jamf_vignettes/ej_mobile_cis_benchmark"
}

module "ej_secure_remote_access" {
  count  = var.include_ej_secure_remote_access == true ? 1 : 0
  source = "./modules/experience_jamf_vignettes/ej_secure_remote_access"
}


## Begin Jamf Security Cloud Configuration

## Create UEMC and Okta integrations
module "jsc_base" {
  count = var.include_jsc_base == true ? 1 : 0
  source = "./modules/staging_templates/jsc_base"
}

module "jsc_block_pages" {
  count = var.include_jsc_block_pages == true ? 1 : 0
  source = "./modules/staging_templates/jsc_block_pages"
}

## Create Jamf Security Cloud Activation Profile containing ONLY Category Based Content Filtering
module "jsc_dp_only" {
  count  = var.include_jsc_dp_only == true ? 1 : 0
  source = "./modules/staging_templates/jsc_dp_only"
  jsc_provided_idp_client_child = var.jsc_provided_idp_client
}

## Create Jamf Security Cloud Activation Profile containing ONLY Threat Response (MTD) 
module "jsc_mtd_only" {
  count  = var.include_jsc_mtd_only == true ? 1 : 0
  source = "./modules/staging_templates/jsc_mtd_only"
  jsc_provided_idp_client_child = var.jsc_provided_idp_client
}

## Create Jamf Security Cloud Activation Profile containing ONLY Connect ZTNA
module "jsc_ztna" {
  count = var.include_jsc_ztna == true ? 1 : 0
  source = "./modules/staging_templates/jsc_ztna"
  jsc_provided_idp_client_child = var.jsc_provided_idp_client
}

## Create Jamf Security Cloud Activation Profile containing ALL JSC Services
module "jsc_all_services" {
  count  = var.include_jsc_all_services == true ? 1 : 0
  source = "./modules/staging_templates/jsc_all_services"
  jsc_provided_idp_client_child = var.jsc_provided_idp_client
}

## Create Jamf Security Cloud Config for Experience Jamf
module "ej_jsc_config" {
  count = var.include_ej_jsc_config == true ? 1 : 0
  source = "./modules/experience_jamf_vignettes/ej_jsc_config"
}

## Initialize sandbox module
module "sandbox" {
  count  = var.include_sandbox == true ? 1 : 0
  source = "./modules/sandbox"
}

## JSC provider root configuration
provider "jsc" {
  username = var.radar_user
  password = var.radar_pass
  #customerid = var.radar_customerid
}

## Initialiaze JSC child modules
module "jsc_demo_config" {
  count                = var.include_jsc_demo_config == true ? 1 : 0
  source               = "./modules/jsc_demo_config/"
  jamfpro_instance_url = var.jamfpro_instance_url
  radar_user           = var.radar_user
  tje_okta_clientid    = var.tje_okta_clientid
  tje_okta_orgdomain   = var.tje_okta_orgdomain
  wizard_suffix        = var.wizard_suffix
}