# Priviliged Role Assignment Tracker

## Background

Policies are one of the primary methods used to ensure that the Client's Azure environment is kept secure and adhers to our standards.
But just assigning the policies is not enough. There is no purpose in auditing the environment, if no action is taken to make it 100% compliant. 

This document will be used to track the compliance of policy assignments across the Client's subscriptions.
The table should be copied over on a monthly basis, with new policy assignments being added at the bottom, and a delta from the existing assignments is calculated. 

A list of all JIRA tickets raised to handle the non-compliant resources should be kept for reference.

## Compliance table

### March 2023

| Name | Scope | Resource Compliance | Non-compliant resources | Non-compliant policies | Delta |
|:----:|------:|---------------------|-------------------------|------------------------|-------|
|ASC Default (subscription: cd4eb8cc-a8ef-4d64-a048-1fcdf51495fd)|Visual Studio Enterprise-Abonnement – MPN|11%|16|66|-1%|
|CIS Microsoft Azure Foundations Benchmark v1.4.0|Visual Studio Enterprise-Abonnement – MPN|57%|15|22|+13%|

### February 2023

| Name | Scope | Resource Compliance | Non-compliant resources | Non-compliant policies | Delta |
|:----:|------:|---------------------|-------------------------|------------------------|-------|
|ASC Default (subscription: cd4eb8cc-a8ef-4d64-a048-1fcdf51495fd)|Visual Studio Enterprise-Abonnement – MPN|12%|15|66| - |
|CIS Microsoft Azure Foundations Benchmark v1.4.0|Visual Studio Enterprise-Abonnement – MPN|44%|10|35| - |

## JIRA Tickets

| Ticket Number | Policy Name | Resources Affected | Decision |
|:-------------:|------------:|-------------------:|---------:|
| XXXXXX | CIS Microsoft Azure Foundations Benchmark v1.4.0 | lin-defender | Remediation|
| XXXXXX | CIS Microsoft Azure Foundations Benchmark v1.4.0 | win-defender | Exemption - Waiver|
