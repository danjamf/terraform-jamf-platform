/*
This terraform blueprint will build an outcome of Jamf Connect basic for macOS.

It will do the following:
 - Create 2 categories
 - Create 2 scripts
 - Upload 3 packages
 - Create 1 extension attribute
 - Create 1 smart computer groups
 - Create 3 policies
 - Create/upload 2 configuration profiles

 Prerequisites:
  - the Dialog tool must be installed
*/

## Call Terraform provider
terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.1.5"
    }
  }
}

## Create computer extension attributes
resource "jamfpro_computer_extension_attribute" "ea_jc_login_plugin_version" {
  name                   = "${var.prefix}Jamf Connect - Connect Login Plugin Version"
  input_type             = "SCRIPT"
  enabled                = true
  data_type              = "STRING"
  inventory_display_type = "EXTENSION_ATTRIBUTES"
  script_contents        = file("${var.support_files_path_prefix}support_files/computer_extension_attributes/JC-login_plugin_version.sh")
}

## Create categories
resource "jamfpro_category" "category_jamf_connect" {
  name     = "${var.prefix}Jamf Connect"
  priority = 9
}


## Upload Packages (grab from repo project files, then upload to Jamf Pro) 

## Define the dictionary of packages with their paths
locals {
  jc_packages_dict = {
    "JamfConnect_2.38.0"      = "${var.support_files_path_prefix}support_files/computer_packages/JamfConnect_2.38.0.pkg"
    "JamfConnectAssets_EJ_v2" = "${var.support_files_path_prefix}support_files/computer_packages/JamfConnectAssets-EJ_v2_Ward-20240724.pkg"
    "JamfConnectLaunchAgent"  = "${var.support_files_path_prefix}support_files/computer_packages/JamfConnectLaunchAgent.pkg"
  }
}

resource "jamfpro_package" "jc_packages" {
  for_each              = local.jc_packages_dict
  package_name          = "${var.prefix}${each.key}"
  info                  = ""
  category_id           = jamfpro_category.category_jamf_connect.id
  package_file_source   = each.value
  os_install            = false
  fill_user_template    = false
  priority              = 10
  reboot_required       = false
  suppress_eula         = false
  suppress_from_dock    = false
  suppress_registration = false
  suppress_updates      = false
}


## Create Smart Computer Groups
# resource "jamfpro_smart_computer_group" "group_LMAM-vignette-enabled" {
#   name = "${var.prefix}LMAM Run (Vignette Enabled)"

#   criteria {
#     name        = jamfpro_computer_extension_attribute.ea_LMAM-marker.name
#     search_type = "is"
#     value       = "lmamRUN"
#     priority    = 0
#   }

#   depends_on = [
#     jamfpro_computer_extension_attribute.ea_LMAM-marker
#   ]
# }

## Create policies
resource "jamfpro_policy" "install_JC_and_assets" {
  name          = "${var.prefix}Install Jamf Connect PKGs & Assets"
  enabled       = true
  trigger_other = "@installJC"
  frequency     = "Ongoing"
  category_id   = jamfpro_category.category_jamf_connect.id

  scope {
    all_computers = true
  }

  self_service {
    use_for_self_service = false
  }

  payloads {
    packages {
      distribution_point = "default" // Set the appropriate distribution point

      package {
        id     = jamfpro_package.jc_packages["JamfConnect_2.40.0"].id
        action = "Install"
      }
      package {
        id     = jamfpro_package.jc_packages["JamfConnectAssets_EJ_v2"].id
        action = "Install"
      }
      package {
        id     = jamfpro_package.jc_packages["JamfConnectLaunchAgent"].id
        action = "Install"
      }
    }
  }
}


## Create Configuration Profiles

resource "jamfpro_macos_configuration_profile_plist" "LMAM_IDP_config" {
  name                = "${var.prefix}Local macOS Account Management | LMAM (JCL-JCMB-JCPE)"
  description         = "NA"
  level               = "System"
  distribution_method = "Install Automatically"
  category_id         = jamfpro_category.category_jamf_connect.id
  redeploy_on_update  = "Newly Assigned"
  payloads            = file("${var.support_files_path_prefix}support_files/computer_config_profiles/jamf_connect_local_macOS.mobileconfig")
  payload_validate    = false
  user_removable      = false

  depends_on = [
    jamfpro_category.category_jamf_connect
  ]

  scope {
    all_computers      = false
    computer_group_ids = [jamfpro_smart_computer_group.group_LMAM-vignette-enabled.id]
  }
}
