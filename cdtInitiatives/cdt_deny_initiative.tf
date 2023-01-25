resource "azurerm_policy_definition" "deny_public_lb" {
  name         = "deny_public_lb"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Load balancers should be internal only"

  metadata = <<METADATA
    {
    "category": "Network"
    }

METADATA


  policy_rule = <<POLICY_RULE
 {
    "if": {
        "allOf": [
          {
            "field": "Microsoft.Network/loadBalancers/frontendIPConfigurations[*].publicIPAddress",
            "exists": "true"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
  }
POLICY_RULE


  parameters = <<PARAMETERS
 {
    "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Audit",
          "Disabled",
          "Deny"
        ],
        "defaultValue": "Deny"
      }
  }
PARAMETERS

}

resource "azurerm_policy_set_definition" "cdt_deny_initiative" {

  name         = "cdt_deny_initiative"
  policy_type  = "Custom"
  display_name = "Deploy Cloudeteer Deny Policies"
  description  = "Deploys a policy initiative which consists of Cloudeteer's agreed standard deny policies"

  metadata = <<METADATA
    {
    "category": "Cloudeteer"
    }
METADATA

parameters = <<PARAMETERS
    {
    "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "Audit",
          "Disabled",
          "Deny"
        ],
        "defaultValue": "Deny"
      }
  }
PARAMETERS

    policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_lb.id
    reference_id = "Load balancers should be internal only"
    parameter_values     = <<VALUE
    {
      "effect": {"value": "[parameters('effect')]"}
    }
    VALUE
  }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1b5ef780-c53c-4a64-87f3-bb9c8c8094ba"
      reference_id = "App Service apps should disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/405c5871-3e91-4644-8a63-58e19d68ff5b"
      reference_id = "Azure Key Vault should disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/55615ac9-af46-4a59-874e-391cc3dfb490"
      reference_id = "Azure Key Vault should have firewall enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d"
      reference_id = "Key vaults should have soft delete enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0b60c0b2-2dc2-4e1c-b5c9-abbed971de53"
      reference_id = "Key vaults should have purge protection enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/88c0b9da-ce96-4b03-9635-f29a937e2900"
      reference_id = "Network interfaces should disable IP forwarding"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
      reference_id = "Network interfaces should not have public IPs"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ddcf4b94-9dfa-4a80-aca6-22bb654fde72"
      reference_id = "Azure NetApp Files SMB Volumes should use SMB3 encryption"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d558e1a6-296d-4fbb-81a5-ea25822639f6"
      reference_id = "Azure NetApp Files Volumes should not use NFSv3 protocol type"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/fe83a0eb-a853-422d-aac2-1bffd182c5d0"
      reference_id = "Storage accounts should have the specified minimum TLS version"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c"
      reference_id = "Storage accounts should restrict network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4fa4b6c0-31ca-4c0d-b10d-24b96f62a751"
      reference_id = "[Preview]: Storage account public access should be disallowed"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693"
      reference_id = "Storage accounts should disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/32e6bbec-16b6-44c2-be37-c5b672d103cf"
      reference_id = "Azure SQL Database should be running TLS version 1.2 or newer"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9dfea752-dd46-4766-aed1-c355fa93fb91"
      reference_id = "Azure SQL Managed Instances should disable public network access"
    }

}