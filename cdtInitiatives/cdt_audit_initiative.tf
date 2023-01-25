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