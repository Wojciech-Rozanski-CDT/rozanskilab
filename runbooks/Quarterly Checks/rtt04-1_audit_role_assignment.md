## RTT04-1 Audit priviliged role assignments

### Access / Permission Level

| Required AAD role | Required RBAC role     |
|-------------------|------------------------|
| None              | Reader                 |

### Steps

1. Log on to Azure.
2. Navigate to Subscriptions.
3. For each of the subscriptions perform the following tasks:
   - Select the subscription and navigate to Access Control (IAM)
   - Download the Role Assignments
   - Upload the Role Assignments to the [xxx] storage account
   - Download the two most recent reports
   - Run the following script:

     `$older = Import-CSV "[Path to the older report]" | Group-Object -AsHashTable -AsString -Property 'RoleAssignmentId'`
     `$newer = Import-CSV "[Path to the new report]"  | Group-Object -AsHashTable -AsString -Property 'RoleAssignmentId'`

     `$delta = @()`

     `ForEach ($assignment in $newer.Values) {`
       `if (!$older[$assignment.RoleAssignmentId]) {`
          `$delta += $assignment`
       `}`
     `}`
     
     `$delta | Export-CSV -NoTypeInformation -Path "C:\Temp\RoleAssignmentChanges.csv"`
  
   - Open the newly generated report.
   - Confirm that all identified changes have a valid JIRA ticket set in the Description.

If any rogue assignments are identified - raise a JIRA ticket and find the cause of it. 
