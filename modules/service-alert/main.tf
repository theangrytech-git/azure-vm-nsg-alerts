/*******************************************************************************

                         TERRAFORM SUBSCRIPTION HEALTH ALERTS

*******************************************************************************/

terraform {
  required_version = ">= 1.5.2"
  required_providers {
    azurerm = "~> 3.112.0"
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_monitor_activity_log_alert" "service_health_warning" {

  name                = "ServiceHealth-Warning"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "ServiceHealth"
    levels      = ["Warning"]
      service_health {
      events = ["Incident"]
      locations = ["uksouth","ukwest","global"]

      }
  }
  action {
    action_group_id = var.ag_itsm
  }
  }

resource "azurerm_monitor_activity_log_alert" "service_health_error" {

  name                = "ServiceHealth-Error"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "ServiceHealth"
    levels      = ["Error"]
      service_health {
      events = ["Incident"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }
resource "azurerm_monitor_activity_log_alert" "service_health_critical" {

  name                = "ServiceHealth-Critical"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "ServiceHealth"
    levels      = ["Critical"]
      service_health {
      events = ["Incident"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }
resource "azurerm_monitor_activity_log_alert" "security_warning" {

  name                = "SecurityAlert-Warning"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "Security"
    levels      = ["Warning"]
      service_health {
      events = ["Security"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }

resource "azurerm_monitor_activity_log_alert" "security_error" {

  name                = "SecurityAlert-Error"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "Security"
    levels      = ["Error"]
      service_health {
      events = ["Security"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }

resource "azurerm_monitor_activity_log_alert" "security_critical" {

  name                = "SecurityAlert-Critical"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "Security"
    levels      = ["Critical"]
      service_health {
      events = ["Security"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }

resource "azurerm_monitor_activity_log_alert" "maintenance" {

  name                = "PlannedMaintenanceAlert"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "ServiceHealth"
    levels      = ["Warning","Error","Critical"]
      service_health {
      events = ["Maintenance"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }

resource "azurerm_monitor_activity_log_alert" "health_advisories" {

  name                = "Health_Advisories"
  resource_group_name = "rg-alerts"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Insert your description here"

  criteria {
    category    = "ServiceHealth"
    levels      = ["Informational"]
      service_health {
      events = ["Informational"]
        locations = ["uksouth","ukwest","global"]

      }
  }
  action {
      action_group_id = var.ag_itsm
  }
  }