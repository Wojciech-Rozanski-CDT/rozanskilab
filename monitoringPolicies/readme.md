# Monitoring Policies for Cloudeteer Development

## Deployment with system-assigned identities

Deployment of the policy assignment of the system-managed initiative is still using the user-assigned managed identity. 
The MI is used for the policy assignment. 
The Azure Monitor Agent is using the system-assigned identity of the VMs.

## Deployment with user-assigned identities

In this scenario, both the policy assignment and the Azure Monitor Agent are using the user-assigned managed identity.

## Choosing the deployment method

If the policy initiative assignment should be done manually, the system-assigned version is acceptable. 
If full automation is required, the user-assigned version is the only option.
