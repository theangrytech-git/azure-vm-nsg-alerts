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

resource "azapi_resource" "custom-alert-subscription" {

  count = (length(data.azurerm_resources.AssetsData) > 0 && var.deployResourceAlert==true) ? 1 : 0 

  name     = var.alertName
  location = "uksouth"

  type     = "Microsoft.Insights/scheduledQueryRules@2023-03-15-preview"

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
      displayName         = var.alertName
      enabled             = true
      evaluationFrequency = var.alertFrequency
      scopes              = ["/subscriptions/${var.subscription_id}"]
      severity            = tonumber(var.alertSeverity)
      targetResourceTypes = [var.resourceType]
      windowSize          = var.alertWindowSize
    }
  })
}