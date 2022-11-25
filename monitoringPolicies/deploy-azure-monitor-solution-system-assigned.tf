#Get data about the current subscription, needed for policy assignment

data "azurerm_subscription" "current" {}

#Deploy a Resource Group where the monitoring resources (DCR, LAW) will be deployed

resource "azurerm_resource_group" "rg-monitoring-euw-001" {
  name     = "rg-monitoring-euw-001"
  location = "West Europe"
}

#Deploy the Log Analytics Workspace. While Ops Stack is using Azure Monitor, it has been found that Windows machines also
#need to have a Log Analytics Workspace deployed as a destination for the logs.

resource "azurerm_log_analytics_workspace" "law-VmInsights-001" {
  name                = "law-VmInsights-001"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
  location            = azurerm_resource_group.rg-monitoring-euw-001.location
}

#Deploy the user-assigned managed identity, which will be used for the policy initiative assignment, along with all the necessary permissions. 

resource "azurerm_user_assigned_identity" "mi-AzPolicyForAzureMonitorAgent-euw-01" {
  location            = azurerm_resource_group.rg-monitoring-euw-001.location
  name                = "mi-AzPolicyForAzureMonitorAgent-euw-01"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
}

resource "azurerm_role_assignment" "az-policy-managed-identity-monitoring-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzPolicyForAzureMonitorAgent-euw-01.principal_id
}

resource "azurerm_role_assignment" "az-policy-managed-identity-la-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzPolicyForAzureMonitorAgent-euw-01.principal_id
}

resource "azurerm_role_assignment" "az-policy-managed-identity-vm-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzPolicyForAzureMonitorAgent-euw-01.principal_id
}

#Deploy the Data Collection Rule, which will control what performance data is gathered from the Guest OS

resource "azurerm_monitor_data_collection_rule" "dcr-cdt-detailed" {
  name                = "dcr-performancedata-detailed-cdt"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
  location            = azurerm_resource_group.rg-monitoring-euw-001.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law-VmInsights-001.id
      name                  = "logAnalyticsWorkspace-default"
    }

    azure_monitor_metrics {
      name = "azureMonitorMetrics-default"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["azureMonitorMetrics-default"]
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Perf"]
    destinations = ["logAnalyticsWorkspace-default"]
  }

  data_sources {

    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 10
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
      name = "perfCounterDataSource10"
    }
  }
}

#Deploy an Azure Policy which will enable a system-assigned Managed Identity on all VMs which don't have it

resource "azurerm_policy_definition" "AddSystemAssignedIdentity" {

  name         = "AddSystemAssignedIdentity"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add system-assigned managed identity to Virtual Machines (CDT custom)"
  description  = "This policy adds a system-assigned managed identity to virtual machines hosted in Azure. This policy was tailored to include all Windows OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

  metadata = <<METADATA
    {
    "category": "Custom"
    }

METADATA
   
  policy_rule = <<POLICY_RULE
  {
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "field": "identity.type",
            "notContains": "SystemAssigned"
          }
        ]
    },
    "then": {
        "effect": "modify",
        "details": {
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
          ],
          "operations": [
            {
              "operation": "addOrReplace",
              "field": "identity.type",
              "value": "SystemAssigned"
            }
          ]
        }
      }  
  }
  POLICY_RULE 
}

#Deploy an Azure Policy which will install the Azure Monitor Agent on Windows Machines, and configure it to use the system-assigned Managed Identity

resource "azurerm_policy_definition" "AzureMonitorForWindowsSystemAssigned" {
  name         = "AzureMonitorForWindowsSystemAssigned"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Windows virtual machines to run Azure Monitor Agent using system-assigned managed identity (CDT custom)"
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
                    }
                  },
                  "variables": {
                    "extensionName": "AzureMonitorWindowsAgent",
                    "extensionPublisher": "Microsoft.Azure.Monitor",
                    "extensionType": "AzureMonitorWindowsAgent",
                    "extensionTypeHandlerVersion": "1.8"
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
                  }
                }
              }
            }
          }
        }
    }
  POLICY_RULE

}

#Deploy an Azure Policy which will install the Azure Monitor Agent on Windows Machines, and configure it to use the system-assigned Managed Identity

resource "azurerm_policy_definition" "AzureMonitorForLinuxSystemAssigned" {
  name         = "AzureMonitorForLinuxSystemAssigned"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Linux virtual machines to run Azure Monitor Agent using system-assigned managed identity (CDT custom)"
  description  = "Automate the deployment of Azure Monitor Agent extension on your Linux virtual machines for collecting telemetry data from the guest OS. This policy will install the extension if the OS and region are supported and system-assigned managed identity is enabled, and skip install otherwise. Learn more: https://aka.ms/AMAOverview. This policy was tailored to include all Linux OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

  metadata = <<METADATA
    {
    "category": "General"
    }

METADATA


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
                }
              }
            }
          }
        }
      }
  }
POLICY_RULE

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
      }
  }
PARAMETERS

}

#Deploy an Azure Policy which will associate the previously created Data Collection Rule with all VMs

resource "azurerm_policy_definition" "AzureDcrAssociation" {
  name         = "AzureDcrAssociation"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Virtual Machines Machines to be associated with a Data Collection Rule (CDT custom)"
  description  = "Deploy Association to link Azure Virtual Machines to the specified Data Collection Rule. This policy was tailored to include all Virtual Machines not only those deployed from the Marketplace to ensure compatibility with L&S machines."

  metadata = <<METADATA
    {
    "category": "Monitoring"
    }

METADATA


  policy_rule = <<POLICY_RULE
 {
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "anyof": [
              {
                "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
                "equals": "Windows"
              },
              {
              "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
              "equals": "Linux"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Insights/dataCollectionRuleAssociations",
          "roleDefinitionIds": [
            "/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
            "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
          ],
          "existenceCondition": {
            "field": "Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionRuleId",
            "equals": "[parameters('dcrResourceId')]"
          },
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "resourceName": {
                    "type": "string"
                  },
                  "location": {
                    "type": "string"
                  },
                  "dcrResourceId": {
                    "type": "string"
                  }
                },
                "variables": {
                  "associationName": "[concat('assoc-', uniqueString(parameters('dcrResourceId')))]"
                },
                "resources": [
                  {
                    "name": "[variables('associationName')]",
                    "type": "Microsoft.Insights/dataCollectionRuleAssociations",
                    "apiVersion": "2021-04-01",
                    "properties": {
                      "dataCollectionRuleId": "[parameters('dcrResourceId')]"
                    },
                    "scope": "[concat('Microsoft.Compute/virtualMachines/', parameters('resourceName'))]"
                  }
                ]
              },
              "parameters": {
                "resourceName": {
                  "value": "[field('name')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "dcrResourceId": {
                  "value": "[parameters('dcrResourceId')]"
                }
              }
            }
          }
        }
      }
  }
POLICY_RULE

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
          "description": "Resource Id of the Data Collection Rule to be applied on the virtual machines in scope."
        }
      }
  }
PARAMETERS

}

#Deploy an Azure Policy Initiative which will contain all the previously configured policies.

resource "azurerm_policy_set_definition" "AzMonitorForVmDeploymentSystemAssigned" {
  name         = "AzureMonitorAgentSystemAssigned"
  policy_type  = "Custom"
  display_name = "Deploy Azure Monitor Agent and associate it with a specified Data Collection Rule (CDT Custom - System Assigned)"
  description  = "Monitor your virtual machines and virtual machine scale sets by deploying the Azure Monitor Agent extension with system-assigned managed identity authentication and associating with specified Data Collection Rule. Azure Monitor Agent Deployment will occur on machines with supported OS images (or machines matching the provided list of images) in supported regions."

  depends_on = [
    azurerm_policy_definition.AzureMonitorForWindowsSystemAssigned,
    azurerm_policy_definition.AzureMonitorForLinuxSystemAssigned,
    azurerm_monitor_data_collection_rule.dcr-cdt-detailed,
    azurerm_policy_definition.AzureDcrAssociation,
    azurerm_policy_definition.AddSystemAssignedIdentity
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
    reference_id = "Configure Windows virtual machines to run Azure Monitor Agent using system-assigned managed identity (CDT custom)"
    parameter_values     = <<VALUE
    {
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }
  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureMonitorForLinuxSystemAssigned.id
    reference_id = "Configure Linux virtual machines to run Azure Monitor Agent using system-assigned managed identity (CDT custom)"
    parameter_values     = <<VALUE
    {
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AddSystemAssignedIdentity.id
    reference_id = "Add system-assigned managed identity to Virtual Machines (CDT custom)"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.AzureDcrAssociation.id
    reference_id = "Configure Azure Virtual Machines to be associated with a Data Collection Rule (CDT custom)"
    parameter_values     = <<VALUE
    {
      "dcrResourceId": {"value": "[parameters('dcrResourceId')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }
}

#Assign the policy initiative on the subscription level

resource "azurerm_subscription_policy_assignment" "monitoring-initiative-system-assigned" {
  name                 = "monitoring-initiative-system-assigned"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.AzMonitorForVmDeploymentSystemAssigned.id
  location = "West Europe"

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-AzPolicyForAzureMonitorAgent-euw-01.id]
  }

  parameters = <<PARAMS
    {
      "dcrResourceId": {
        "value": "${azurerm_monitor_data_collection_rule.dcr-cdt-detailed.id}"
      }
    }
PARAMS
}