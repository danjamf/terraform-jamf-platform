terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = "~> 0.1.5"
    }
    jsc = {
      source = "danjamf/jsctfprovider"
      version = "0.0.5"
    }
  }
}

provider "jamfpro" {
  jamfpro_instance_fqdn          = var.jamfpro_instance_url
  auth_method =               "basic" // oauth2
  basic_auth_username = var.jamfpro_username
  basic_auth_password = var.jamfpro_password
  #client_id                   = var.jamfpro_client_id
  #client_secret               = var.jamfpro_client_secret
  enable_client_sdk_logs                 = false
  hide_sensitive_data         = true # Hides sensitive data in logs
  token_refresh_buffer_period_seconds = 5 # minutes
  jamfpro_load_balancer_lock     = true
  mandatory_request_delay_milliseconds = 100
}

variable "jamfpro_instance_url" {
  description = "Jamf Pro Instance name."
  default     = ""
}

variable "jamfpro_client_id" {
  description = "Jamf Pro Client ID for authentication."
  default     = ""
}

variable "jamfpro_client_secret" {
  description = "Jamf Pro Client Secret for authentication."
  sensitive   = true
  default     = ""
}

variable "jamfpro_username" {
  description = "Jamf Pro username used for authentication."
  default     = ""
}

variable "jamfpro_password" {
  description = "Jamf Pro password used for authentication."
  sensitive   = true
  default     = ""
}

provider "jsc" {
  # Configure provider-specific settings if needed
  username   = var.radar_user
  password   = var.radar_pass
  //customerid = var.radar_customerid
}

variable "radar_user" {
  type = string
  default = "empty"
}

variable "radar_pass" {
  type = string
  sensitive = true
  default = "empty"
}