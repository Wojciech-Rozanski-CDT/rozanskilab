data "azurerm_resource_group" "rg-vmtest-systemassigned-euw-001" {
  name = "rg-vmtest-systemassigned-euw-001"
}

data "azurerm_resource_group" "rg-vmtest-userassigned-euw-001" {
  name = "rg-vmtest-userassigned-euw-001"
}

output "rg-vmtest-systemassigned-euw-001-id" {
  value = data.azurerm_resource_group.rg-vmtest-systemassigned-euw-001.id
}

output "rg-vmtest-userassigned-euw-001-id" {
  value = data.azurerm_resource_group.rg-vmtest-userassigned-euw-001.id
}

resource "azurerm_resource_group_policy_assignment" "monitoring-initiative-system-assigned" {
  name                 = "monitoring-initiative-system-assigned"
  resource_group_id    = data.azurerm_resource_group.rg-vmtest-systemassigned-euw-001.id
  policy_definition_id = azurerm_policy_set_definition.AzMonitorForVmDeploymentSystemAssigned.id
  location = var.location

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.id]
  }

  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.dcr-cdt-detailed.id}"
      }
    }
PARAMS
}

resource "azurerm_resource_group_policy_assignment" "monitoring-initiative-user-assigned" {
  name                 = "monitoring-initiative-user-assigned"
  resource_group_id     = data.azurerm_resource_group.rg-vmtest-userassigned-euw-001.id
  policy_definition_id = azurerm_policy_set_definition.AzMonitorForVmDeploymentUserAssigned.id
  location = var.location

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.id]
  }

  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.dcr-cdt-detailed.id}"
      },
      "userAssignedManagedIdentityName": {
        "value": "${azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.name}"
      },
      "userAssignedManagedIdentityResourceGroup": {
        "value": "${azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.resource_group_name}"
      }
    }
PARAMS
}