resource "azurerm_resource_group" "rg-monitoring-euw-001" {
  name     = "rg-monitoring-euw-001"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "law-VmInsights-001" {
  name                = "law-VmInsights-001"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
  location            = azurerm_resource_group.rg-monitoring-euw-001.location
}

resource "azurerm_user_assigned_identity" "mi-AzureMonitorAgent-euw-01" {
  location            = azurerm_resource_group.rg-monitoring-euw-001.location
  name                = "mi-AzureMonitorAgent-euw-01"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
}

resource "azurerm_role_assignment" "managed-identity-monitoring-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.principal_id
}

resource "azurerm_role_assignment" "managed-identity-la-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.principal_id
}

resource "azurerm_role_assignment" "managed-identity-vm-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.principal_id
}