resource "azurerm_service_plan" "app_service_plan" {
  
  name                = var.asp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

}

resource "azurerm_linux_web_app" "linux_web_app" {
  name                = var.linux_web_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  https_only = var.https_only
  enabled = var.enabled

  site_config {

    application_stack {
      docker_image = var.application_stack == "docker" ? var.docker_image : null
      docker_image_tag = var.application_stack == "docker" ? var.docker_image_tag : null
      dotnet_version = var.application_stack == "dotnet" ? var.dotnet_version : null
      go_version = var.application_stack == "go" ? var.go_version : null
      java_server = var.application_stack == "java" ? var.java_server : null
      java_server_version = var.application_stack == "java" ? var.java_server_version : null
      java_version = var.application_stack == "java" ? var.java_version : null
      node_version = var.application_stack == "node" ? var.node_version : null
      php_version = var.application_stack == "php" ? var.php_version : null
      python_version = var.application_stack == "python" ? var.python_version : null
      ruby_version = var.application_stack == "ruby " ? var.ruby_version : null
    }

    always_on = var.always_on

    ftps_state = var.ftps_state
    minimum_tls_version = var.minimum_tls_version
    scm_minimum_tls_version = var.scm_minimum_tls_version

  }

  identity {
    type = var.identity_type
    identity_ids = var.identity_type == "UserAssigned" || "SystemAssigned, UserAssigned" ? var.identity_ids : null
  }

  tags = var.tags

}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  name               = "diag-" + var.linux_web_app_name
  target_resource_id = azurerm_linux_web_app.linux_web_app.id
  log_analytics_workspace_id  = var.azurerm_log_analytics_workspace_id

  log {
    category = "AppServiceAppLogs"
    enabled = var.AppServiceAppLogs_enabled
  }

  log {
    category = "AppServiceAuditLogs"
    enabled = var.AppServiceAuditLogs_enabled
  }

  log {
    category = "AppServiceConsoleLogs"
    enabled = var.AppServiceConsoleLogs_enabled
  }

  log {
    category = "AppServiceHTTPLogs"
    enabled = var.AppServiceHTTPLogs_enabled
  }

  log {
    category = "AppServiceIPSecAuditLogs"
    enabled = var.AppServiceIPSecAuditLogs_enabled
  }

  log {
    category = "AppServicePlatformLogs"
    enabled = var.AppServicePlatformLogs_enabled
  }

  metric {
    category = var.metric_category
  }
}