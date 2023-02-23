## RTT01-1 Check Backup Status

### Access / Permission Level

| Required AAD role | Required RBAC role     |
|-------------------|------------------------|
| None              | Reader / Backup Reader |

### Steps

1. Log on to Azure.
2. (optional) If accessing the portail via a Lighthouse account, set the subscription filter to show subscriptions from the relevant Tenant only.
3. Open the Backup Center.
4. Set the datasource type for Azure Virtual Machines.
5. Check for any failed backups from the past 24 hours.
6. Check if there are any instances with _protection stopped_.
7. Repeat steps 5 and 6 for all other datasources.

### Alternative Method - if Recovery Services Vault Diagnostics data is sent to a Log Analytics Workspace

1. Log on to Azure.
2. (optional) If accessing the portail via a Lighthouse account, set the subscription filter to show subscriptions from the relevant Tenant only.
3. Open the Backup Center.
4. Make sure all subscriptions are selected as datasource subscription
5. Navigate to Backup Reports
6. In the Get Started tab click the "Click here" button in the pink-ish box
7. Navigate to the View Reports tab
8. Open the backup job history
9. Select the workspace which is receiving the Recovery Services Vault diagnostic settings
10. Set the time range to the last 24 hours. Ensure that Datasource Location, Job Operation and Job Status are all set to "All"
11. Click the three dots in the upper right hand corner of the generated table and export it to Excel
12. Upload the exported Excel file to [location]

In case any failed backup operations are noticed, a JIRA ticket should be raised.
In case any Virtual Machine has _protection stopped_, a JIRA ticket should be raised.
The Client Contact responsible for the failed backup operation needs to be informed. 
