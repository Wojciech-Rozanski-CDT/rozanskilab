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

resource "azurerm_role_assignment" "az-policy-managed-identity-mi-operator" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.mi-AzPolicyForAzureMonitorAgent-euw-01.principal_id
}

#Deploy the user-assigned Managed Identity which will be used by the Azure Monitor Agent, along with the necessary permissions

resource "azurerm_user_assigned_identity" "mi-AzureMonitorAgent-euw-01" {
  location            = azurerm_resource_group.rg-monitoring-euw-001.location
  name                = "mi-AzureMonitorAgent-euw-01"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
}

resource "azurerm_role_assignment" "az-monitor-managed-identity-monitoring-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.principal_id
}

resource "azurerm_role_assignment" "az-monitor-managed-identity-la-contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-AzureMonitorAgent-euw-01.principal_id
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
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
      name = "perfCounterDataSource10"
    }
  }
}

#Deploy an Azure Policy which will assign the previously created Managed Identity to all VMs

resource "azurerm_policy_definition" "AddUserAssignedIdentityForAzMonitor" {

  name         = "AddUserAssignedIdentityForAzMonitor"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add user-assigned managed identity to Virtual Machines to be used by the Azure Monitor Agent (CDT custom)"
  description  = "This policy adds a user-assigned managed identity to virtual machines hosted in Azure. This Managed Identity will be used by the Azure Monitor Agent. This policy was tailored to include all Windows OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

  metadata = <<METADATA
    {
    "category": "Custom"
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
            "value": "[requestContext().apiVersion]",
            "greaterOrEquals": "2018-10-01"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Compute/virtualMachines",
          "name": "[field('name')]",
          "evaluationDelay": "AfterProvisioning",
          "deploymentScope": "subscription",
          "existenceCondition": {
            "anyOf": [
              {
                "allOf": [
                  {
                    "field": "identity.type",
                    "contains": "UserAssigned"
                  },
                  {
                    "field": "identity.userAssignedIdentities",
                    "containsKey": "[if(parameters('bringYourOwnUserAssignedManagedIdentity'), concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', trim(parameters('userAssignedManagedIdentityResourceGroup')), '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', trim(parameters('userAssignedManagedIdentityName'))), concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/Built-In-Identity-RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/Built-In-Identity-', field('location')))]"
                  }
                ]
              },
              {
                "allOf": [
                  {
                    "field": "identity.type",
                    "equals": "UserAssigned"
                  },
                  {
                    "value": "[string(length(field('identity.userAssignedIdentities')))]",
                    "equals": "1"
                  }
                ]
              }
            ]
          },
          "roleDefinitionIds": [
            "/subscriptions/fa5fc227-a624-475e-b696-cdd604c735bc/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
            "/subscriptions/fa5fc227-a624-475e-b696-cdd604c735bc/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
          ],
          "deployment": {
            "location": "eastus",
            "properties": {
              "mode": "incremental",
              "parameters": {
                "bringYourOwnUserAssignedManagedIdentity": {
                  "value": "[parameters('bringYourOwnUserAssignedManagedIdentity')]"
                },
                "location": {
                  "value": "[field('location')]"
                },
                "uaName": {
                  "value": "[if(parameters('bringYourOwnUserAssignedManagedIdentity'), parameters('userAssignedManagedIdentityName'), 'Built-In-Identity')]"
                },
                "userAssignedManagedIdentityResourceGroup": {
                  "value": "[if(parameters('bringYourOwnUserAssignedManagedIdentity'), parameters('userAssignedManagedIdentityResourceGroup'), 'Built-In-Identity-RG')]"
                },
                "vmName": {
                  "value": "[field('name')]"
                },
                "vmResourceGroup": {
                  "value": "[resourceGroup().name]"
                },
                "resourceId": {
                  "value": "[field('id')]"
                }
              },
              "template": {
                "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
                "contentVersion": "1.0.0.1",
                "parameters": {
                  "bringYourOwnUserAssignedManagedIdentity": {
                    "type": "bool"
                  },
                  "location": {
                    "type": "string"
                  },
                  "uaName": {
                    "type": "string"
                  },
                  "userAssignedManagedIdentityResourceGroup": {
                    "type": "string"
                  },
                  "vmName": {
                    "type": "string"
                  },
                  "vmResourceGroup": {
                    "type": "string"
                  },
                  "resourceId": {
                    "type": "string"
                  }
                },
                "variables": {
                  "uaNameWithLocation": "[concat(parameters('uaName'),'-', parameters('location'))]",
                  "precreatedUaId": "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', trim(parameters('userAssignedManagedIdentityResourceGroup')), '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', trim(parameters('uaName')))]",
                  "autocreatedUaId": "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', trim(parameters('userAssignedManagedIdentityResourceGroup')), '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', trim(parameters('uaName')), '-', parameters('location'))]",
                  "deployUALockName": "[concat('deployUALock-', uniqueString(deployment().name))]",
                  "deployUAName": "[concat('deployUA-', uniqueString(deployment().name))]",
                  "deployGetResourceProperties": "[concat('deployGetResourceProperties-', uniqueString(deployment().name))]",
                  "deployAssignUAName": "[concat('deployAssignUA-', uniqueString(deployment().name))]"
                },
                "resources": [
                  {
                    "condition": "[not(parameters('bringYourOwnUserAssignedManagedIdentity'))]",
                    "type": "Microsoft.Resources/resourceGroups",
                    "apiVersion": "2020-06-01",
                    "name": "[parameters('userAssignedManagedIdentityResourceGroup')]",
                    "location": "eastus"
                  },
                  {
                    "condition": "[parameters('bringYourOwnUserAssignedManagedIdentity')]",
                    "type": "Microsoft.Resources/deployments",
                    "apiVersion": "2020-06-01",
                    "name": "[variables('deployUALockName')]",
                    "resourceGroup": "[parameters('userAssignedManagedIdentityResourceGroup')]",
                    "properties": {
                      "mode": "Incremental",
                      "expressionEvaluationOptions": {
                        "scope": "inner"
                      },
                      "parameters": {
                        "uaName": {
                          "value": "[parameters('uaName')]"
                        }
                      },
                      "template": {
                        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "parameters": {
                          "uaName": {
                            "type": "string"
                          }
                        },
                        "variables": {},
                        "resources": [
                          {
                            "type": "Microsoft.Authorization/locks",
                            "apiVersion": "2016-09-01",
                            "name": "[concat('CanNotDeleteLock-', parameters('uaName'))]",
                            "scope": "[concat('Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('uaName'))]",
                            "properties": {
                              "level": "CanNotDelete",
                              "notes": "Please do not delete this User-Assigned Identity since extensions enabled by Azure Policy are relying on their existence."
                            }
                          }
                        ]
                      }
                    }
                  },
                  {
                    "condition": "[not(parameters('bringYourOwnUserAssignedManagedIdentity'))]",
                    "type": "Microsoft.Resources/deployments",
                    "apiVersion": "2020-06-01",
                    "name": "[variables('deployUAName')]",
                    "resourceGroup": "[parameters('userAssignedManagedIdentityResourceGroup')]",
                    "dependsOn": [
                      "[resourceId('Microsoft.Resources/resourceGroups', parameters('userAssignedManagedIdentityResourceGroup'))]"
                    ],
                    "properties": {
                      "mode": "Incremental",
                      "expressionEvaluationOptions": {
                        "scope": "inner"
                      },
                      "parameters": {
                        "uaName": {
                          "value": "[variables('uaNameWithLocation')]"
                        },
                        "location": {
                          "value": "[parameters('location')]"
                        }
                      },
                      "template": {
                        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "parameters": {
                          "uaName": {
                            "type": "string"
                          },
                          "location": {
                            "type": "string"
                          }
                        },
                        "variables": {},
                        "resources": [
                          {
                            "type": "Microsoft.ManagedIdentity/userAssignedIdentities",
                            "name": "[parameters('uaName')]",
                            "apiVersion": "2018-11-30",
                            "location": "[parameters('location')]"
                          },
                          {
                            "type": "Microsoft.ManagedIdentity/userAssignedIdentities/providers/locks",
                            "apiVersion": "2016-09-01",
                            "name": "[concat(parameters('uaName'), '/Microsoft.Authorization/', 'CanNotDeleteLock-', parameters('uaName'))]",
                            "dependsOn": [
                              "[parameters('uaName')]"
                            ],
                            "properties": {
                              "level": "CanNotDelete",
                              "notes": "Please do not delete this User-Assigned Identity since extensions enabled by Azure Policy are relying on their existence."
                            }
                          }
                        ]
                      }
                    }
                  },
                  {
                    "type": "Microsoft.Resources/deployments",
                    "apiVersion": "2020-06-01",
                    "name": "[variables('deployGetResourceProperties')]",
                    "location": "eastus",
                    "dependsOn": [
                      "[resourceId('Microsoft.Resources/resourceGroups', parameters('userAssignedManagedIdentityResourceGroup'))]",
                      "[variables('deployUAName')]"
                    ],
                    "properties": {
                      "mode": "Incremental",
                      "template": {
                        "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "resources": [],
                        "outputs": {
                          "resource": {
                            "type": "object",
                            "value": "[reference(parameters('resourceId'), '2019-07-01', 'Full')]"
                          }
                        }
                      }
                    }
                  },
                  {
                    "type": "Microsoft.Resources/deployments",
                    "apiVersion": "2020-06-01",
                    "name": "[concat(variables('deployAssignUAName'))]",
                    "resourceGroup": "[parameters('vmResourceGroup')]",
                    "dependsOn": [
                      "[resourceId('Microsoft.Resources/resourceGroups', parameters('userAssignedManagedIdentityResourceGroup'))]",
                      "[variables('deployUAName')]",
                      "[variables('deployGetResourceProperties')]"
                    ],
                    "properties": {
                      "mode": "Incremental",
                      "expressionEvaluationOptions": {
                        "scope": "inner"
                      },
                      "parameters": {
                        "uaId": {
                          "value": "[if(parameters('bringYourOwnUserAssignedManagedIdentity'), variables('precreatedUaId'), variables('autocreatedUaId'))]"
                        },
                        "vmName": {
                          "value": "[parameters('vmName')]"
                        },
                        "location": {
                          "value": "[parameters('location')]"
                        },
                        "identityType": {
                          "value": "[if(contains(reference(variables('deployGetResourceProperties')).outputs.resource.value, 'identity'), reference(variables('deployGetResourceProperties')).outputs.resource.value.identity.type, '')]"
                        },
                        "userAssignedIdentities": {
                          "value": "[if(and(contains(reference(variables('deployGetResourceProperties')).outputs.resource.value, 'identity'), contains(reference(variables('deployGetResourceProperties')).outputs.resource.value.identity, 'userAssignedIdentities')), reference(variables('deployGetResourceProperties')).outputs.resource.value.identity.userAssignedIdentities, createObject())]"
                        }
                      },
                      "template": {
                        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "parameters": {
                          "uaId": {
                            "type": "string"
                          },
                          "vmName": {
                            "type": "string"
                          },
                          "location": {
                            "type": "string"
                          },
                          "identityType": {
                            "type": "string"
                          },
                          "userAssignedIdentities": {
                            "type": "object"
                          }
                        },
                        "variables": {
                          "identityTypeValue": "[if(contains(parameters('identityType'), 'SystemAssigned'), 'SystemAssigned,UserAssigned', 'UserAssigned')]",
                          "userAssignedIdentitiesValue": "[union(parameters('userAssignedIdentities'), createObject(parameters('uaId'), createObject()))]",
                          "resourceWithSingleUAI": "[and(equals(parameters('identityType'), 'UserAssigned'), equals(string(length(parameters('userAssignedIdentities'))), '1'))]"
                        },
                        "resources": [
                          {
                            "condition": "[not(variables('resourceWithSingleUAI'))]",
                            "apiVersion": "2019-07-01",
                            "type": "Microsoft.Compute/virtualMachines",
                            "name": "[parameters('vmName')]",
                            "location": "[parameters('location')]",
                            "identity": {
                              "type": "[variables('identityTypeValue')]",
                              "userAssignedIdentities": "[variables('userAssignedIdentitiesValue')]"
                            }
                          }
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
}
POLICY_RULE
}

#Deploy an Azure Policy which will install the Azure Monitor Agent on Windows Machines, and configure it to use the user-assigned Managed Identity

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

#Deploy an Azure Policy which will install the Azure Monitor Agent on Linux Machines, and configure it to use the user-assigned Managed Identity

resource "azurerm_policy_definition" "AzureMonitorForLinuxUserAssigned" {
  name         = "AzureMonitorForLinuxUserAssigned"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Linux virtual machines to run Azure Monitor Agent using user-assigned managed identity (CDT custom)"
  description  = "Automate the deployment of Azure Monitor Agent extension on your Linux virtual machines for collecting telemetry data from the guest OS. This policy will install the extension if the OS and region are supported and user-assigned managed identity is enabled, and skip install otherwise. Learn more: https://aka.ms/AMAOverview. This policy was tailored to include all Linux OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

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
            "equals": "Linux"
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
                  },
                  "userAssignedManagedIdentity": {
                    "type": "string"
                  }
                },
                "variables": {
                  "extensionName": "AzureMonitorLinuxAgent",
                  "extensionPublisher": "Microsoft.Azure.Monitor",
                  "extensionType": "AzureMonitorLinuxAgent",
                  "extensionTypeHandlerVersion": "1.15"
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

resource "azurerm_policy_set_definition" "AzMonitorForVmDeploymentUserAssigned" {
  name         = "AzureMonitorAgentUserAssigned"
  policy_type  = "Custom"
  display_name = "Deploy Azure Monitor Agent and associate it with a specified Data Collection Rule (CDT Custom - User Assigned)"
  description  = "Monitor your virtual machines and virtual machine scale sets by deploying the Azure Monitor Agent extension with user-assigned managed identity authentication and associating with specified Data Collection Rule. Azure Monitor Agent Deployment will occur on machines with supported OS images (or machines matching the provided list of images) in supported regions."

  depends_on = [
    azurerm_policy_definition.AzureMonitorForWindowsUserAssigned,
    azurerm_policy_definition.AzureMonitorForLinuxUserAssigned,
    azurerm_monitor_data_collection_rule.dcr-cdt-detailed,
    azurerm_policy_definition.AzureDcrAssociation,
    azurerm_policy_definition.AddUserAssignedIdentityForAzMonitor
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
    reference_id = "Configure Windows virtual machines to run Azure Monitor Agent using user-assigned managed identity (CDT custom)"
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
    reference_id = "Configure Linux virtual machines to run Azure Monitor Agent using user-assigned managed identity (CDT custom)"
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
    policy_definition_id = azurerm_policy_definition.AddUserAssignedIdentityForAzMonitor.id
    reference_id = "Add user-assigned managed identity to Virtual Machines to be used by the Azure Monitor Agent (CDT custom)"
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
    policy_definition_id = azurerm_policy_definition.AzureDcrAssociation.id
    reference_id = "Configure Virtual Machines to be associated with a Data Collection Rule (CDT custom)"
    parameter_values     = <<VALUE
    {
      "dcrResourceId": {"value": "[parameters('dcrResourceId')]"},
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

}

#Assign the policy initiative on the subscription level

resource "azurerm_subscription_policy_assignment" "monitoring-initiative-user-assigned" {
  name                 = "monitoring-initiative-user-assigned"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_set_definition.AzMonitorForVmDeploymentUserAssigned.id
  location = var.location

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi-AzPolicyForAzureMonitorAgent-euw-01.id]
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