resource "azurerm_policy_set_definition" "AzMonitorForVmDeploymentSystemAssigned" {
  name         = "AzureMonitorAgentSystemAssigned"
  policy_type  = "Custom"
  display_name = "Deploy Azure Monitor Agent and associate it with a specified Data Collection Rule (CDT Custom - System Assigned)"
  description  = "Monitor your virtual machines and virtual machine scale sets by deploying the Azure Monitor Agent extension with system-assigned managed identity authentication and associating with specified Data Collection Rule. Azure Monitor Agent Deployment will occur on machines with supported OS images (or machines matching the provided list of images) in supported regions."

  depends_on = [
    azurerm_policy_definition.AzureMonitorForWindowsSystemAssigned,
    azurerm_policy_definition.AzureMonitorForLinuxSystemAssigned,
    azurerm_monitor_data_collection_rule.dcr-cdt-detailed,
    azurerm_policy_definition.AzureDcrAssociationWindows,
    azurerm_policy_definition.AzureDcrAssociationLinux
  ]

  metadata = <<METADATA
    {
    "category": "Monitoring"
    }
METADATA

parameters = <<PARAMETERS
    {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy."
        },
        "allowedValues": [
          "DeployIfNotExists",
          "Disabled"
        ],
        "defaultValue": "DeployIfNotExists"
      },
      "dcrResourceId": {
        "type": "String",
        "metadata": {
          "displayName": "Data Collection Rule Resource Id",
          "description": "Resource Id of the Data Collection Rule that the virtual machines in scope should be associated with."
        },
        "defaultValue": "\"\""
      }
    }
PARAMETERS

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureMonitorForWindowsSystemAssigned.id
    parameter_values     = <<VALUE
    {
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureMonitorForLinuxSystemAssigned.id
    parameter_values     = <<VALUE
    {
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureDcrAssociationWindows.id
    parameter_values     = <<VALUE
    {
      "dcrResourceId": {"value": "[parameters('dcrResourceId')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureDcrAssociationLinux.id
    parameter_values     = <<VALUE
    {
      "dcrResourceId": {"value": "[parameters('dcrResourceId')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

}


resource "azurerm_policy_set_definition" "AzMonitorForVmDeploymentUserAssigned" {
  name         = "AzureMonitorAgentUserAssigned"
  policy_type  = "Custom"
  display_name = "Deploy Azure Monitor Agent and associate it with a specified Data Collection Rule (CDT Custom - User Assigned)"
  description  = "Monitor your virtual machines and virtual machine scale sets by deploying the Azure Monitor Agent extension with user-assigned managed identity authentication and associating with specified Data Collection Rule. Azure Monitor Agent Deployment will occur on machines with supported OS images (or machines matching the provided list of images) in supported regions."

  depends_on = [
    azurerm_policy_definition.AzureMonitorForWindowsUserAssigned,
    azurerm_policy_definition.AzureMonitorForLinuxUserAssigned,
    azurerm_monitor_data_collection_rule.dcr-cdt-detailed,
    azurerm_policy_definition.AzureDcrAssociationWindows,
    azurerm_policy_definition.AzureDcrAssociationLinux
  ]

  metadata = <<METADATA
    {
    "category": "Monitoring"
    }
METADATA

parameters = <<PARAMETERS
    {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy."
        },
        "allowedValues": [
          "DeployIfNotExists",
          "Disabled"
        ],
        "defaultValue": "DeployIfNotExists"
      },
      "dcrResourceId": {
        "type": "String",
        "metadata": {
          "displayName": "Data Collection Rule Resource Id",
          "description": "Resource Id of the Data Collection Rule that the virtual machines in scope should point to."
        },
        "defaultValue": "\"\""
      },
      "bringYourOwnUserAssignedManagedIdentity": {
        "type": "Boolean",
        "metadata": {
          "displayName": "Bring Your Own User-Assigned Managed Identity",
          "description": "If set to true, Azure Monitor Agent will use the user-assigned managed identity specified via the 'User-Assigned Managed Identity ...' parameters for authentication. Otherwise, Azure Monitor Agent will use the user-assigned managed identity /subscriptions/<subscription-id>/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-<location> for authentication."
        },
        "defaultValue": true
      },
      "userAssignedManagedIdentityName": {
        "type": "String",
        "metadata": {
          "displayName": "User-Assigned Managed Identity Name",
          "description": "The name of the user-assigned managed identity which Azure Monitor Agent will use for authentication when 'Bring Your Own User-Assigned Managed Identity' is set to true."
        },
        "defaultValue": ""
      },
      "userAssignedManagedIdentityResourceGroup": {
        "type": "String",
        "metadata": {
          "displayName": "User-Assigned Managed Identity Resource Group",
          "description": "The resource group of the user-assigned managed identity which Azure Monitor Agent will use for authentication when 'Bring Your Own User-Assigned Managed Identity' is set to true."
        },
        "defaultValue": ""
      }
    }
PARAMETERS

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureMonitorForWindowsUserAssigned.id
    parameter_values     = <<VALUE
    {
      "userAssignedManagedIdentityName": {"value": "[parameters('userAssignedManagedIdentityName')]"},
      "bringYourOwnUserAssignedManagedIdentity": {"value": "[parameters('bringYourOwnUserAssignedManagedIdentity')]"},
      "userAssignedManagedIdentityResourceGroup": {"value": "[parameters('userAssignedManagedIdentityResourceGroup')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }
  
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureMonitorForLinuxUserAssigned.id
    parameter_values     = <<VALUE
    {
      "userAssignedManagedIdentityName": {"value": "[parameters('userAssignedManagedIdentityName')]"},
      "bringYourOwnUserAssignedManagedIdentity": {"value": "[parameters('bringYourOwnUserAssignedManagedIdentity')]"},
      "userAssignedManagedIdentityResourceGroup": {"value": "[parameters('userAssignedManagedIdentityResourceGroup')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureDcrAssociationWindows.id
    parameter_values     = <<VALUE
    {
      "dcrResourceId": {"value": "[parameters('dcrResourceId')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureDcrAssociationLinux.id
    parameter_values     = <<VALUE
    {
      "dcrResourceId": {"value": "[parameters('dcrResourceId')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

}