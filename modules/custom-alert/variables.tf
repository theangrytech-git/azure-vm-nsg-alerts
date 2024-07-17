variable "subscription_id" {
  description = "Subscription id"
  type        = string
}

variable "alertName" {
  description = "Name of the alert to be created."
  type        = string
}

variable "alertResourceGroup" {
  description = "Name of the resource group to store the alert in."
  type        = string
}

variable "alertSeverity" {
  description = "Name of the resource group to store the alert in."
  type        = string
}

variable "alertWindowSize" {
  description = "resource type to create alerts against."
  type        = string
}

variable "alertFrequency" {
  description = "Frequency of the alert."
  type        = string
}

variable "resourceType" {
  description = "resource type to create alerts against."
  type        = string
}

variable "criteria_Aggregation" {
  description = "Aggregation method to use"
  type        = string
}

variable "criteria_Operator" {
  description = "Operator to be used"
  type        = string
}

variable "criteria_Threshold" {
  description = "Threshold to compare against"
  type        = string
}

variable "actionGroupId" {
  description = "Action Group Id"
  type        = string
}

variable "queryString" {
  description = "Query String to use"
  type        = string
}

variable "alertDimensions" {
  description = "Dimensions variables in 'key = value' pairs"
  default     = null
  type = list(object({ name = string
    operator = string
    values   = list(string)
  }))
}

variable "failingPeriods" {
  description = "failing periods"
  type        = string
}

variable "evaluationPeriods" {
  description = "evaluationPeriods"
  type        = string
}