## Call Terraform provider
terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.1.11"
    }
  }
}

module "management-app-installers-microsoft-365" {
  source = "../management-app-installers-microsoft-365"
}

module "management-app-installers-google-chrome" {
  source = "../management-app-installers-google-chrome"
}

module "management-app-installers-mozilla-firefox" {
  source = "../management-app-installers-mozilla-firefox"
}

module "management-app-installers-slack" {
  source = "../management-app-installers-slack"
}

module "management-app-installers-dropbox" {
  source = "../management-app-installers-dropbox"
}

module "management-app-installers-google-drive" {
  source = "../management-app-installers-google-drive"
}

module "management-app-installers-jamf-composer" {
  source = "../management-app-installers-jamf-composer"
}

module "management-app-installers-pppc-utility" {
  source = "../management-app-installers-pppc-utility"
}

module "management-app-installers-jamfcheck" {
  source = "../management-app-installers-jamfcheck"
}

module "management-app-installers-zoom" {
  source = "../management-app-installers-zoom"
}
