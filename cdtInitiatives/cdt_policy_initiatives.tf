resource "azurerm_policy_set_definition" "cdt_audit_initiative" {

  name         = "cdt_audit_initiative"
  policy_type  = "Custom"
  display_name = "Deploy Cloudeteer Audit Policies"
  description  = "Deploys a policy initiative which consists of Cloudeteer's agreed standard auditing policies"

  metadata = <<METADATA
    {
    "category": "Cloudeteer"
    }
METADATA

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/dea83a72-443c-4292-83d5-54a2f98749c0"
      reference_id = "Automation Account should have Managed Identity"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/013e242c-8828-4970-87b3-ab247555486d"
      reference_id = "Azure Backup should be enabled for Virtual Machines"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0a914e76-4921-4c19-b460-a2d36003525a"
      reference_id = "Audit resource location matches resource group location"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0b15565f-aa9e-48ba-8619-45960f2c314d"
      reference_id = "Email notification to subscription owner for high severity alerts should be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0fc39691-5a3f-4e3e-94ee-2e6447309ad9"
      reference_id = "Running container images should have vulnerability findings resolved"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/feedbf84-6b99-488c-acc2-71c829aa5ffc"
      reference_id = "SQL databases should have vulnerability findings resolved"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6ba6d016-e7c3-4842-b8f2-4992ebc0d72d"
      reference_id = "SQL servers on machines should have vulnerability findings resolved"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517"
      reference_id = "Subnets should be associated with a Network Security Group"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4f4f78b8-e367-4b10-a341-d9a4ad5cf1c7"
      reference_id = "Subscriptions should have a contact email address for security issues"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2f080164-9f4d-497e-9db6-416dc9f7b48a"
      reference_id = "Network Watcher flow logs should have traffic analytics enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a8793640-60f7-487c-b5c3-1d37215905c4"
      reference_id = "SQL Managed Instance should have the minimal TLS version of 1.2"
    }

}

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

resource "azurerm_policy_set_definition" "cdt_cis_remediation_initiative" {

  name         = "cdt_cis_remediation_initiative"
  policy_type  = "Custom"
  display_name = "Deploy CIS Remediation Policies"
  description  = "Deploys a policy initiative which consists of policies used to remediate CIS non-compliant resources"

  metadata = <<METADATA
    {
    "category": "Cloudeteer"
    }
METADATA

parameters = <<PARAMETERS
    {
    "logAnalyticsWorkspaceId": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics Workspace ID",
          "description": "Auditing will write database events to this Log Analytics Workspace.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
    }
  }
PARAMETERS

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0f98368e-36bc-4716-8ac2-8f8067203b63"
      reference_id = "Configure App Service apps to only be accessible over HTTPS"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ae44c1d1-0df2-4ca9-98fa-a3d3ae5b409d"
      reference_id = "Configure App Service apps to use the latest TLS version"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2374605e-3e0b-492b-9046-229af202562c"
      reference_id = "Configure App Service apps to disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/572e342c-c920-4ef5-be2e-1ed3c6a51dc5"
      reference_id = "Configure App Service apps to disable local authentication for FTP deployments"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/5e97b776-f380-4722-a9a3-e7f0be029e79"
      reference_id = "Configure App Service apps to disable local authentication for SCM sites"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a18c77f2-3d6d-497a-9f61-849a7e8a3b79"
      reference_id = "Configure App Service app slots to only be accessible over HTTPS"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/014664e7-e348-41a3-aeb9-566e4ff6a9df"
      reference_id = "Configure App Service app slots to use the latest TLS version"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c6c3e00e-d414-4ca4-914f-406699bb8eee"
      reference_id = "Configure App Service app slots to disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2c034a29-2a5f-4857-b120-f800fe5549ae"
      reference_id = "Configure App Service app slots to disable local authentication for SCM sites"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f493116f-3b7f-4ab3-bf80-0c2af35e46c2"
      reference_id = "Configure App Service app slots to disable local authentication for FTP deployments"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1f01f1c7-539c-49b5-9ef4-d4ffa37d22e0"
      reference_id = "Configure Function apps to use the latest TLS version"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cd794351-e536-40f4-9750-503a463d8cad"
      reference_id = "Configure Function apps to disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/08cf2974-d178-48a0-b26d-f6b8e555748b"
      reference_id = "Configure Function app slots to only be accessible over HTTPS"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/fa3a6357-c6d6-4120-8429-855577ec0063"
      reference_id = "Configure Function app slots to use the latest TLS version"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/242222f3-4985-4e99-b5ef-086d6a6cb01c"
      reference_id = "Configure Function app slots to disable public network access"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a9b99dd8-06c5-4317-8629-9d86a3c6e7d9"
      reference_id = "Deploy network watcher when virtual networks are created"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/25da7dfb-0666-4a15-a8f5-402127efd8bb"
      reference_id = "Configure SQL servers to have auditing enabled to Log Analytics workspace"
      parameter_values     = <<VALUE
    {
      "logAnalyticsWorkspaceId": {"value": "[parameters('logAnalyticsWorkspaceId')]"}
    }
    VALUE
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/f81e3117-0093-4b17-8a60-82363134f0eb"
      reference_id = "Configure secure transfer of data on a storage account"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/13502221-8df0-4414-9937-de9c5c4e396b"
      reference_id = "Configure your Storage account public access to be disallowed"
    }

}