resource "azurerm_policy_definition" "AzureDcrAssociationWindows" {
  name         = "AzureDcrAssociationWindows"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Windows Machines to be associated with a Data Collection Rule (CDT custom)"
  description  = "Deploy Association to link Windows virtual machines, virtual machine scale sets, and Arc machines to the specified Data Collection Rule. The list of locations and OS images are updated over time as support is increased. This policy was tailored to include all Windows OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

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
            "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
            "equals": "Windows"
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

resource "azurerm_policy_definition" "AzureDcrAssociationLinux" {
  name         = "AzureDcrAssociationLinux"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Configure Linux Machines to be associated with a Data Collection Rule (CDT custom)"
  description  = "Deploy Association to link Linux virtual machines, virtual machine scale sets, and Arc machines to the specified Data Collection Rule. The list of locations and OS images are updated over time as support is increased. This policy was tailored to include all Linux OS, not only those deployed from the Marketplace to ensure compatibility with L&S machines."

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
            "field": "Microsoft.Compute/virtualMachines/storageProfile.osDisk.osType",
            "equals": "Linux"
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
