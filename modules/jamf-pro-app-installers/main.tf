## Call Terraform provider
terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = ">= 0.1.5"
    }
  }
}

resource "jamfpro_app_installer" "app_installer" {
  name            = var.software_title
  enabled         = var.is_enabled
  deployment_type = var.initial_distribution_method
  update_behavior = var.update_method
  category_id     = var.category_id
  site_id         = var.site_id
  smart_group_id  = var.smart_group_id

  install_predefined_config_profiles = var.install_supporting_configuration_profiles
  trigger_admin_notifications        = var.log_event_notifications_for_this_app

  notification_settings {
    notification_message  = var.notification_message
    notification_interval = var.notification_frequency
    deadline_message      = var.force_quit_message
    deadline              = var.update_deadline
    quit_delay            = var.force_quit_grace_period
    complete_message      = var.update_complete_message
    relaunch              = var.post_update_action
    suppress              = var.suppression_settings
  }

  self_service_settings {
    include_in_featured_category   = var.self_service_included_in_featured_category
    include_in_compliance_category = var.self_service_included_in_compliance_category
    force_view_description         = var.self_service_description_force_view
    description                    = var.self_service_description

    categories {
      id       = var.self_service_display_in_category_id
      featured = var.self_service_display_in_category_id_featured
    }
  }
}