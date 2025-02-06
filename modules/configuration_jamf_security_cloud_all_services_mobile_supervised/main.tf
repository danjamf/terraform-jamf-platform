## Call Terraform provider
terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.1.5"
    }
    jsc = {
      source  = "danjamf/jsctfprovider"
      version = ">= 0.0.15"
    }
  }
}

resource "random_integer" "entropy" {
  min = 10
  max = 999
}

resource "jsc_oktaidp" "okta_idp_base" {
  clientid   = var.tje_okta_clientid
  name       = "Okta IDP Integration"
  orgdomain  = var.tje_okta_orgdomain
  depends_on = [random_integer.entropy]
}

resource "jsc_ap" "all_services" {
  name             = "Jamf Connect ZTNA and Protect - Mobile (Supervised) [${random_integer.entropy.result}]"
  idptype          = "OKTA"
  oktaconnectionid = jsc_oktaidp.okta_idp_base.id
  privateaccess    = true
  threatdefence    = true
  datapolicy       = true
  depends_on       = [jsc_oktaidp.okta_idp_base]
}

resource "jamfpro_category" "jsc_all_services_profiles" {
  name       = "Jamf Security Cloud [${random_integer.entropy.result}]"
  priority   = 9
  depends_on = [jsc_ap.all_services]
}

resource "jamfpro_mobile_device_configuration_profile_plist" "all_services_mobile_supervised" {
  name               = "Jamf Connect ZTNA + Jamf Protect Threat and Content Control - Mobile (Supervised) [${random_integer.entropy.result}]"
  description        = "**Please remember to go to your Jamf Security Cloud tenant and collect the Managed app configuration and add that to the Jamf Trust app in Devices > Mobile Device Apps."
  deployment_method  = "Install Automatically"
  level              = "Device Level"
  redeploy_on_update = "Newly Assigned"
  payloads           = jsc_ap.all_services.supervisedplist
  payload_validate   = false

  category_id = jamfpro_category.jsc_all_services_profiles.id

  scope {
    all_mobile_devices = false
    all_jss_users      = false
  }
  depends_on = [jamfpro_category.jsc_all_services_profiles]
}
