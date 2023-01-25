resource "azurerm_policy_set_definition" "cdt_defender_initiative" {

  name         = "cdt_defender_initiative"
  policy_type  = "Custom"
  display_name = "Deploy Microsoft Defender"
  description  = "Deploys a policy initiative which enabled Microsoft Defender on all services"

  metadata = <<METADATA
    {
    "category": "Cloudeteer"
    }
METADATA

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b40e7bcd-a1e5-47fe-b9cf-2f534d0bfb7d"
      reference_id = "Configure Azure Defender for App Service to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b99b73e7-074b-4089-9395-b7236f094491"
      reference_id = "Configure Azure Defender for Azure SQL database to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2370a3c1-4a25-4283-a91a-c9c1a145fb2f"
      reference_id = "Configure Azure Defender for DNS to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1f725891-01c0-420a-9059-4fa46cb770b7"
      reference_id = "Configure Azure Defender for Key Vaults to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/b7021b2b-08fd-4dc0-9de7-3c6ece09faf9"
      reference_id = "Configure Azure Defender for Resource Manager to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/74c30959-af11-47b3-9ed2-a26e03f427a3"
      reference_id = "Configure Azure Defender for Storage to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/44433aa3-7ec2-4002-93ea-65c65ff0310a"
      reference_id = "Configure Azure Defender for open-source relational databases to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/8e86a5b6-b9bd-49d1-8e21-4bb8a0862222"
      reference_id = "Configure Azure Defender for servers to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c5a62eb0-c65a-4220-8a4d-f70dd4ca95dd"
      reference_id = "Configure Azure Defender to be enabled on SQL managed instances"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/36d49e87-48c4-4f2e-beed-ba4ed02b71f5"
      reference_id = "Configure Azure Defender to be enabled on SQL servers"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/689f7782-ef2c-4270-a6d0-7664869076bd"
      reference_id = "Configure Microsoft Defender CSPM to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/82bf5b87-728b-4a74-ba4d-6123845cf542"
      reference_id = "Configure Microsoft Defender for Azure Cosmos DB to be enabled"
    }

    policy_definition_reference {
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c9ddb292-b203-4738-aead-18e2716e858f"
      reference_id = "Configure Microsoft Defender for Containers to be enabled"
    }
}