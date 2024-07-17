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

variable "criteria_MetricName" {
  description = "Metric name to alert against"
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

variable "criteria_AlertSensitivity" {
  description = "Alert Sensitivity to compare against"
  type        = string
}

variable "actionGroupID" {
  description = "action group to be alerted"
  type        = string
}

variable "deploy_alert" {
  description = "Flag to deploy the resource alert or not (true/false)"
  type        = bool
}