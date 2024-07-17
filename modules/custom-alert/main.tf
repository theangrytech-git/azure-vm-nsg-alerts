/*******************************************************************************

                         TERRAFORM CUSTOM INSIGHTS ALERT

*******************************************************************************/

terraform {
  required_version = ">= 1.5.2"
  required_providers {
    azurerm = "~> 3.112.0"
    azapi = {
      source = "Azure/azapi"
    }
  }
}

# Assets Data Collection
data "azurerm_resources" "AssetsData" {
  type = var.resourceType
}

resource "azapi_resource" "custom-alert" {

  for_each = {
    for idx, asset in data.azurerm_resources.AssetsData.resources : idx => {
      name                = "${var.alertName}-${asset.name}"
      resource_group_name = "${asset.resource_group_name}"
      location            = "${asset.location}"
      scopes              = "/subscriptions/${var.subscription_id}/resourceGroups/${asset.resource_group_name}/providers/${var.resourceType}/${asset.name}"
    }
  }

  name     = each.value.name
  location = each.value.location
  type     = "Microsoft.Insights/scheduledQueryRules@2022-08-01-preview"

  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.alertResourceGroup}"

  body = jsonencode({
    properties = {
      actions = {
        actionGroups = [var.actionGroupId]
      }
      criteria = {
        allOf = [
          {
            dimensions = var.alertDimensions
            failingPeriods = {
              minFailingPeriodsToAlert  = tonumber(var.failingPeriods)
              numberOfEvaluationPeriods = tonumber(var.evaluationPeriods)
            }
            operator            = var.criteria_Operator
            query               = var.queryString
            threshold           = tonumber(var.criteria_Threshold)
            timeAggregation     = "Average"
            metricMeasureColumn = "AggregatedValue"
          }
        ]
      }
      description         = "Insert your description here"
      displayName         = "${each.value.name}"
      enabled             = true
      evaluationFrequency = var.alertFrequency
      scopes              = [each.value.scopes]
      severity            = tonumber(var.alertSeverity)
      targetResourceTypes = [var.resourceType]
      windowSize          = var.alertWindowSize
    }
  })
}