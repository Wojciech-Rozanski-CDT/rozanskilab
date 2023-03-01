## RTT02-4 Check patch status

### Access / Permission Level

| Required AAD role | Required RBAC role     |
|-------------------|------------------------|
| None              | Reader                 |

### Steps

1. Log on to Azure
2. Navigate to Automation Accounts
3. Open the blade for [automation account used for patch management]
4. Navigate to Update Management
5. Check for any non-compliant machines and machines with update agent with an error status
6. Raise a JIRA ticket for any machine found

Important note: It is crucial to have this task completed on Monday due to the fact that, at least with Microsoft, regular patches are released on the second Tuesday of each month. Out-of-band patches are released ahead of schedule. 
