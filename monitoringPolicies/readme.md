# Monitoring Policies for Cloudeteer Development

## Deployment with system-assigned identities

Deployment of the policy assignment of the system-managed initiative is not fully automated. Each policy with a DeployIfNotExists effect needs to have an identity connected to it's assignment. This identity should be granted all the necessary permissions to deploy the agent and connect the DCR. The problem is that the identity of the assignment is not known until the assigment is...assigned. Therefore it's not possible to provide the needed permissions upfront. It might be possible to get an output of the assignment, a feature which might come in a later revision.  

## Deployment with user-assigned identities

In this scenario, everything is fully automated. The same managed identity is used by the policy assignment, and by the Azure Monitor Agent on the VMs. All the necessary permissions are provided upfront.

## Choosing the deployment method

If the policy initiative assignment should be done manually, the system-assigned version is acceptable. 
If full automation is required, the user-assigned version is the only option.
