# +––––––––––––––––––––––––––––––––––––––––––––––––––––––––+
# |                  REQUIRED PARAMETERS                   |
# | You must provide a value for each of these parameters. |
# +––––––––––––––––––––––––––––––––––––––––––––––––––––––––+

variable "software_title" {
  description = "The name of the App Installer Software Title." # e.g. "Google Chrome"
  type        = string
}

# +––––––––––––––––––––––––––––––––––––––––––––––––––––––––+
# |                  OPTIONAL PARAMETERS                   |
# |      These parameters have reasonable defaults.        |
# +––––––––––––––––––––––––––––––––––––––––––––––––––––––––+

variable "is_enabled" {
  description = "Use the to toggle deployment of the App Installer."
  type        = bool
  default     = true
}

variable "self_service_description" {
  description = "Description (up to 4000 characters) to display for the app in Self Service"
  type        = string
  default     = ""
}

variable "initial_distribution_method" {
  description = "The method to use for distributing the app to a computer for the initial installation."
  type        = string
  default     = "SELF_SERVICE" # options: {INSTALL_AUTOMATICALLY, SELF_SERVICE}
}

variable "update_method" {
  description = "The method to use for all future app updates, regardless of the initial distribution method."
  type        = string
  default     = "AUTOMATIC" # options: {AUTOMATIC, MANUAL}
}

variable "category_id" {
  description = "Category to add the app to."
  type        = string
  default     = "-1" # -1 defaults to "None" Category, otherwise use the associated Category ID number.
}

variable "site_id" {
  description = "Site to add the app to."
  type        = string
  default     = "-1" # -1 defaults to "None" Site, otherwise use the associated Site ID number.
}

variable "smart_group_id" {
  description = "Target Smart Computer Group to add the app to."
  type        = string
  default     = "1" # 1 defaults to "All Managed Clients" Smart Group, otherwise use the associated Smart Group ID number.
}

variable "install_supporting_configuration_profiles" {
  description = "Allows Jamf to automatically install necessary configuration profiles to support this App Installer."
  type        = bool
  default     = true
}

variable "log_event_notifications_for_this_app" {
  description = "Opt in to receiving notifications for certain events including app updates and installation failures."
  type        = bool
  default     = true
}

variable "notification_message" {
  description = "Message to display as the push notification (up to 150 characters) when an update is available."
  type        = string
  default     = "A new ${var.software_title} update is available"
}

variable "notification_frequency" {
  description = "How often the notification message is displayed (in hours)"
  type        = number
  default     = 1
}

variable "force_quit_message" {
  description = "Message to display as the push notification (up to 150 characters) when the app is forced to quit to complete the update."
  type        = string
  default     = "Update deadline approaching"
}

variable "update_deadline" {
  description = "How long the user can defer the update before the app is forced to quit to complete the update (in hours)"
  type        = number
  default     = 1
}

variable "force_quit_grace_period" {
  description = "Additional time for users to save work and close the app (in minutes)"
  type        = number
  default     = 5
}

variable "update_complete_message" {
  description = "Message to display as the push notification (up to 150 characters) when an update is complete"
  type        = string
  default     = "Update completed successfully"
}

variable "post_update_action" {
  description = "Automatically open app after update. Does not apply if the app was already closed when the update started."
  type        = bool
  default     = true
}

variable "suppression_settings" {
  description = "Suppress all notifications. WARNING: Jamf does not recommend suppressing all notifications. This may prevent end users from knowing an app is quitting to complete an update."
  type        = bool
  default     = false
}

variable "self_service_included_in_featured_category" {
  description = "Include the app in the Featured category."
  type        = bool
  default     = false
}

variable "self_service_included_in_compliance_category" {
  description = "Include the app in the Compliance category."
  type        = bool
  default     = false
}

variable "self_service_description_force_view" {
  description = "Force users to view the description before installing the app."
  type        = bool
  default     = false
}

variable "self_service_display_in_category_id" {
  description = "Display in the corresponding Self Service category (by ID)."
  type        = string
  default     = "" # This is required if the "initial_distribution_method" is set to "SELF_SERVICE" otherwise it will not display to the end-user.
}


variable "self_service_display_in_category_id_featured" {
  description = "Feature in the corresponding Self Service category."
  type        = bool
  default     = false # This is optional if the "initial_distribution_method" is set to "SELF_SERVICE".
}
