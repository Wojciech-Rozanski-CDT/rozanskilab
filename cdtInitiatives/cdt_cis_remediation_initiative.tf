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