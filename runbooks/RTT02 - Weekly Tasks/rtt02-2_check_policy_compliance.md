## RTT02-2 Check for policy compliance

### Access / Permission Level

| Required AAD role | Required RBAC role     |
|-------------------|------------------------|
| None              | Reader                 |

### Steps

1. Log on to Azure.
2. Open the Azure Resource Graph Explorer.
3. Set the scope for the correct subscription.
4. Run the following query:

`PolicyResources`
`| where type =~ 'Microsoft.PolicyInsights/PolicyStates'`
`| extend complianceState = tostring(properties.complianceState)`
`| extend`
	`resourceId = tostring(properties.resourceId),`
	`policyAssignmentId = tostring(properties.policyAssignmentId),`
	`policyAssignmentScope = tostring(properties.policyAssignmentScope),`
	`policyAssignmentName = tostring(properties.policyAssignmentName),`
	`policyDefinitionId = tostring(properties.policyDefinitionId),`
	`policyDefinitionReferenceId = tostring(properties.policyDefinitionReferenceId),`
	`stateWeight = iff(complianceState == 'NonCompliant', int(300), iff(complianceState == 'Compliant', int(200), iff(complianceState == 'Conflict', int(100), iff(complianceState == 'Exempt', int(50), int(0)))))`
`| summarize max(stateWeight) by resourceId, policyAssignmentId, policyAssignmentScope, policyAssignmentName`
`| summarize counts = count() by policyAssignmentId, policyAssignmentScope, max_stateWeight, policyAssignmentName`
`| summarize overallStateWeight = max(max_stateWeight),`
`nonCompliantCount = sumif(counts, max_stateWeight == 300),`
`compliantCount = sumif(counts, max_stateWeight == 200),`
`conflictCount = sumif(counts, max_stateWeight == 100),`
`exemptCount = sumif(counts, max_stateWeight == 50) by policyAssignmentId, policyAssignmentScope, policyAssignmentName`
`| extend totalResources = todouble(nonCompliantCount + compliantCount + conflictCount + exemptCount)`
`| extend compliancePercentage = iff(totalResources == 0, todouble(100), 100 * todouble(compliantCount + exemptCount) / totalResources)`
`| project policyAssignmentName, scope = policyAssignmentScope,`
`complianceState = iff(overallStateWeight == 300, 'noncompliant', iff(overallStateWeight == 200, 'compliant', iff(overallStateWeight == 100, 'conflict', iff(overallStateWeight == 50, 'exempt', 'notstarted')))),`
`compliancePercentage,`
`compliantCount,`
`nonCompliantCount,`
`conflictCount,`
`exemptCount`

5. Export the compliance results to a .csv file.
6. Repeat the process for all subscriptions.
7. Create a JIRA ticket and assign all the csv files to it.

For any non-compliance resource found, a JIRA ticket dedicated to that resource should be raised. Based on the outcome of the ticket, the following actions might occur:
- the resource will be remediated
- a proper exception shall be raised with the ticket number in the description
