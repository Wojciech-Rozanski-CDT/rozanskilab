variable "asp_name" {
    type = string
    description = "The name for the App Service Plan"
}

variable "location" {
    type = string
    description = "The region where the resources should be deployed to"
}

variable "resource_group_name" {
    type = string
    description = "Name of the resource group the resources should be deployed to"
}

variable "os_type" {
    type = string
    description = "Choice whether the application should run on Windows or Linux"
    default = "Linux"
}

variable "sku_name" {
    type = string
    description = "The SKU the App Service Plan should run on"
}

variable "linux_web_app_name" {
    type = string
    description = "Name of the App Service"
}

variable "https_only" {
    type = bool
    description = "Choice whether the Web App should be available only via HTTPS"
    default = true
}

variable "enabled" {
    type = bool
    description = "Choice whether the Web App should be enabled"
    default = true
}

variable "application_stack" {
    type = string
    description = "Choice of the programming language the Web App is made with"
    validation {
        condition = contains(["docker","dotnet","go","java","node","php","python","ruby", var.application_stack])
    }
}

variable "docker_image" {
    type = string
    description = "The Docker image reference, including repository host as needed."
}

variable "docker_image_tag" {
    type = string
    description = "The image Tag to use. e.g. latest."
}

variable "dotnet_version" {
    type = string
    description = "The version of .NET to use. Possible values include 3.1, 5.0, 6.0 and 7.0"
}

variable "go_version" {
    type = string
    description = "The version of Go to use. Possible values include 1.18, and 1.19"
}

variable "java_server" {
    type = string
    description = "The Java server type. Possible values include JAVA, TOMCAT, and JBOSSEAP."
}

variable "java_server_version" {
    type = string
    description = "The Version of the java_server to use"
}

variable "java_version" {
    type = string
    description = "The Version of Java to use. Possible values include 8, 11, and 17"
}

variable "node_version" {
    type = string
    description = "The version of Node to run. Possible values include 12-lts, 14-lts, 16-lts, and 18-lts. This property conflicts with java_version"
}

variable "php_version" {
    type = string
    description = "The version of PHP to run. Possible values are 7.4, 8.0 and 8.1"
}

variable "python_version" {
    type = string
    description = "The version of Python to run. Possible values include 3.7, 3.8, 3.9, 3.10 and 3.11"
}

variable "ruby_version" {
    type = string
    description = "The version of Ruby to run. Possible values include 2.6 and 2.7"
}

variable "always_on" {
    type = string
    description = "If this Linux Web App is Always On enabled. Defaults to true"
}

variable "ftps_state" {
    type = string
    description = "The State of FTP / FTPS service. Possible values include AllAllowed, FtpsOnly, and Disabled"
    default = "FtpsOnly"
}

variable "minimum_tls_version" {
    type = string
    description = "The configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2"
    default = "1.2"
}

variable "scm_minimum_tls_version" {
    type = string
    description = "The configures the minimum version of TLS required for SSL requests to the SCM site Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2"
    default = "1.2"
}

variable "identity_type" {
    type = string
    description = "Specifies the type of Managed Service Identity that should be configured on this Linux Web App Slot. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned (to enable both)"

}

variable "identity_ids" {
    type = list(string)
    description = "A list of User Assigned Managed Identity IDs to be assigned to this Linux Web App Slot."
}

variable "tags" {
  type        = map(string)
  description = "Labels to be attached to resources"
}

variable "azurerm_log_analytics_workspace_id" {
    type = string
    description = "The ID of the Log Analytics Workspace to be used for logging"
}

variable "AppServiceAppLogs_enabled" {
    type = string
    description = "Choice whether the App Service App Logs should be enabled"
}

variable "AppServiceAuditLogs_enabled" {
    type = string
    description = "Choice whether the App Service Audit Logs should be enabled"
}

variable "AppServiceConsoleLogs_enabled" {
    type = string
    description = "Choice whether the App Service Console Logs should be enabled"
}

variable "AppServiceHTTPLogs_enabled" {
    type = string
    description = "Choice whether the App Service HTTP Logs should be enabled"
}

variable "AppServiceIPSecAuditLogs_enabled" {
    type = string
    description = "Choice whether the App Service IPSec Audit Logs should be enabled"
}

variable "AppServicePlatformLogs_enabled" {
    type = string
    description = "Choice whether the App Service Platform Logs should be enabled"
}

variable "metric_category" {
    type = string
    description = "Choice whether the Metrics should be collected"
}