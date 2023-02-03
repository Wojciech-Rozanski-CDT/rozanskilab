variable "alert_health" {
  type        = string
  description = "A descriptive name of the new activity log alert"
}

variable "alert_description" {
  type        = string
  description = "A more detailed description of the new activity log alert"
}

variable "category" {
  type        = string
  description = "The category of the operation. Possible values are Administrative, Autoscale, Policy, Recommendation, ResourceHealth, Security and ServiceHealth"
}

variable "operation_name" {
  type        = string
  description = "The Resource Manager Role-Based Access Control operation name. Supported operation should be of the form: <resourceProvider>/<resourceType>/<operation>"
  default     = null
}

variable "resource_provider" {
  type        = string
  description = "The name of the resource provider monitored by the activity log alert"
  default     = null
}

variable "resource_type" {
  type        = string
  description = "The resource type monitored by the activity log alert"
  default     = null
}

variable "alert_resource_group" {
  type        = string
  description = "The name of resource group monitored by the activity log alert"
  default     = null
}

variable "resource_id" {
  type        = string
  description = "The specific resource monitored by the activity log alert. It should be within one of the scopes"
  default     = null
}

variable "caller" {
  type        = string
  description = "The email address or Azure Active Directory identifier of the user who performed the operation"
  default     = null
}

variable "level" {
  type        = string
  description = "The severity level of the event. Possible values are Verbose, Informational, Warning, Error, and Critical"
  default     = null
}

variable "status" {
  type        = string
  description = "The status of the event. For example, Started, Failed, or Succeeded"
  default     = null
}

variable "sub_status" {
  type        = string
  description = "The sub status of the event"
  default     = null
}

variable "recommendation_type" {
  type        = string
  description = "The recommendation type of the event. It is only allowed when category is Recommendation"
  default     = null
}

variable "recommendation_category" {
  type        = string
  description = "The recommendation category of the event. Possible values are Cost, Reliability, OperationalExcellence and Performance. It is only allowed when category is Recommendation"
  default     = null
}

variable "recommendation_impact" {
  type        = string
  description = "The recommendation impact of the event. Possible values are High, Medium and Low. It is only allowed when category is Recommendation"
  default     = null
}

variable "service_health_events" {
  type        = list(string)
  description = "Events this alert will monitor Possible values are Incident, Maintenance, Informational, ActionRequired and Security. Defaults to all Events or Set to null to select all Events"
  default     = null
}

variable "service_health_locations" {
  type        = list(string)
  description = "Locations this alert will monitor. For example, West Europe. Defaults to Global."
}

variable "service_health_services" {
  type        = list(string)
  description = "Services this alert will monitor. For example, Activity Logs & Alerts, Action Groups. Defaults to all Services or Set to null to select all Services."
  default     = null
}

variable "resource_health_current" {
  type        = string
  description = "The current resource health statuses that will log an alert. Possible values are Available, Degraded, Unavailable and Unknown"
  default     = null
}

variable "resource_health_previous" {
  type        = string
  description = "The previous resource health statuses that will log an alert. Possible values are Available, Degraded, Unavailable and Unknown"
  default     = null
}

variable "resource_healt_reason" {
  type        = string
  description = "The reason that will log an alert. Possible values are PlatformInitiated (such as a problem with the resource in an affected region of an Azure incident), UserInitiated (such as a shutdown request of a VM) and Unknown"
  default     = null
}

variable "action_group_id" {
  type        = string
  description = "The ID of the Action Group"
  default     = null
}