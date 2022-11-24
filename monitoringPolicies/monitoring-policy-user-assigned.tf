resource "azurerm_policy_definition" "AzureMonitorForWindowsUserAssigned" {
  name         = "AzureMonitorForWindowsUserAssigned"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Windows virtual machines to run Azure Monitor Agent using user-assigned managed identity (CDT custom)"
  description  = "Automate the deployment of Azure Monitor Agent extension on your Windows virtual machines for collecting telemetry data from the guest OS. This policy will install the extension if the OS and region are supported and system-assigned managed identity is enabled, and skip install otherwise. Learn more: https://aka.ms/AMAOverview. This policy was tailored to include all Windows OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

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

  "bringYourOwnUserAssignedManagedIdentity": {
        "type": "Boolean",
        "metadata": {
          "displayName": "Bring Your Own User-Assigned Managed Identity",
          "description": "If set to true, Azure Monitor Agent will use the user-assigned managed identity specified via the 'User-Assigned Managed Identity ...' parameters for authentication. Otherwise, Azure Monitor Agent will use the user-assigned managed identity /subscriptions/<subscription-id>/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-<location> for authentication."
        },
        "allowedValues": [
          false,
          true
        ]
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

  policy_rule = <<POLICY_RULE
 {
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
            "equals": "Windows"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Compute/virtualMachines/extensions",
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
          ],
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/type",
                "equals": "AzureMonitorWindowsAgent"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
                "equals": "Microsoft.Azure.Monitor"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/provisioningState",
                "equals": "Succeeded"
              }
            ]
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  },
                  "userAssignedManagedIdentity": {
                    "type": "string"
                  }
                },
                "variables": {
                  "extensionName": "AzureMonitorWindowsAgent",
                  "extensionPublisher": "Microsoft.Azure.Monitor",
                  "extensionType": "AzureMonitorWindowsAgent",
                  "extensionTypeHandlerVersion": "1.2"
                },
                "resources": [
                  {
                    "name": "[concat(parameters('vmName'), '/', variables('extensionName'))]",
                    "type": "Microsoft.Compute/virtualMachines/extensions",
                    "location": "[parameters('location')]",
                    "apiVersion": "2019-07-01",
                    "properties": {
                      "publisher": "[variables('extensionPublisher')]",
                      "type": "[variables('extensionType')]",
                      "typeHandlerVersion": "[variables('extensionTypeHandlerVersion')]",
                      "autoUpgradeMinorVersion": true,
                      "enableAutomaticUpgrade": true,
                      "settings": {
                        "authentication": {
                          "managedIdentity": {
                            "identifier-name": "mi_res_id",
                            "identifier-value": "[parameters('userAssignedManagedIdentity')]"
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "parameters": {
                "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "userAssignedManagedIdentity": {
                  "value": "[if(parameters('bringYourOwnUserAssignedManagedIdentity'), concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', parameters('userAssignedManagedIdentityResourceGroup'), '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('userAssignedManagedIdentityName')), concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-', field('location')))]"
                }
              }
            }
          }
        }
    }
    }
POLICY_RULE
}

resource "azurerm_policy_definition" "AzureMonitorForLinuxUserAssigned" {
  name         = "AzureMonitorForLinuxUserAssigned"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Linux virtual machines to run Azure Monitor Agent using user-assigned managed identity (CDT custom)"
  description  = "Automate the deployment of Azure Monitor Agent extension on your Linux virtual machines for collecting telemetry data from the guest OS. This policy will install the extension if the OS and region are supported and system-assigned managed identity is enabled, and skip install otherwise. Learn more: https://aka.ms/AMAOverview. This policy was tailored to include all Linux OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

  metadata = <<METADATA
    {
    "category": "General"
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

  "bringYourOwnUserAssignedManagedIdentity": {
        "type": "Boolean",
        "metadata": {
          "displayName": "Bring Your Own User-Assigned Managed Identity",
          "description": "If set to true, Azure Monitor Agent will use the user-assigned managed identity specified via the 'User-Assigned Managed Identity ...' parameters for authentication. Otherwise, Azure Monitor Agent will use the user-assigned managed identity /subscriptions/<subscription-id>/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-<location> for authentication."
        },
        "allowedValues": [
          false,
          true
        ]
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


  policy_rule = <<POLICY_RULE
 {
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
            "equals": "Linux"
          },
          {
            "field": "identity.type",
            "contains": "SystemAssigned"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Compute/virtualMachines/extensions",
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
          ],
          "existenceCondition": {
            "allOf": [
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/type",
                "equals": "AzureMonitorLinuxAgent"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
                "equals": "Microsoft.Azure.Monitor"
              },
              {
                "field": "Microsoft.Compute/virtualMachines/extensions/provisioningState",
                "equals": "Succeeded"
              }
            ]
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "vmName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  }
                },
                "variables": {
                  "extensionName": "AzureMonitorLinuxAgent",
                  "extensionPublisher": "Microsoft.Azure.Monitor",
                  "extensionType": "AzureMonitorLinuxAgent",
                  "extensionTypeHandlerVersion": "1.12"
                },
                "resources": [
                  {
                    "name": "[concat(parameters('vmName'), '/', variables('extensionName'))]",
                    "type": "Microsoft.Compute/virtualMachines/extensions",
                    "location": "[parameters('location')]",
                    "apiVersion": "2019-07-01",
                    "properties": {
                      "publisher": "[variables('extensionPublisher')]",
                      "type": "[variables('extensionType')]",
                      "typeHandlerVersion": "[variables('extensionTypeHandlerVersion')]",
                      "autoUpgradeMinorVersion": true,
                      "enableAutomaticUpgrade": true
                    }
                  }
                ]
              },
              "parameters": {
                "vmName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "userAssignedManagedIdentity": {
                  "value": "[if(parameters('bringYourOwnUserAssignedManagedIdentity'), concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', parameters('userAssignedManagedIdentityResourceGroup'), '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('userAssignedManagedIdentityName')), concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/built-in-identity-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/built-in-identity-', field('location')))]"
                }
              }
            }
          }
        }
      }
  }
POLICY_RULE


}