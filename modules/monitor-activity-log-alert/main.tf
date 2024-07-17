/*******************************************************************************

                         TERRAFORM ACTIVITY LOG ALERT

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

resource "azurerm_monitor_activity_log_alert" "keyvault_deletion_alert" {
  scopes = ["/subscriptions/${var.subscription_id}"]

  count = var.deploy_alert ? 1 : 0
  
  name        = var.alertName
  description = "Insert your description here"

  resource_group_name = var.alertResourceGroup

  criteria {
    category       = "Administrative"
    level          = "Informational"
    resource_type  = var.resourceType
    operation_name = var.criteria_OperationName

  }
  action {
    action_group_id = var.actionGroupID
  }

  enabled = true
}