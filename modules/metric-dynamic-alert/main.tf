/*******************************************************************************

                         TERRAFORM METRIC STATIC ALERT

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

# Assets Data Collection
data "azurerm_resources" "AssetsData" {
  type = var.resourceType
}


resource "azurerm_monitor_metric_alert" "metric-dynamic-alert" {
  
  for_each = var.deploy_alert ? {
    for idx, asset in data.azurerm_resources.AssetsData.resources : idx => {
      name = "${var.alertName}-${asset.name}"
      scopes = [
        "/subscriptions/${var.subscription_id}/resourceGroups/${asset.resource_group_name}/providers/${var.resourceType}/${asset.name}"
      ]
    } 
  } : {}

  name                 = each.value.name
  resource_group_name  = var.alertResourceGroup
  scopes               = each.value.scopes
  target_resource_type = var.resourceType
  description          = "Insert your description here"
  severity             = var.alertSeverity
  window_size          = var.alertWindowSize
  frequency            = var.alertFrequency
  dynamic_criteria {
    metric_name       = var.criteria_MetricName
    metric_namespace  = var.resourceType
    aggregation       = var.criteria_Aggregation
    operator          = var.criteria_Operator
    alert_sensitivity = var.criteria_AlertSensitivity
  }
  action {
    action_group_id = var.actionGroupID
  }
}