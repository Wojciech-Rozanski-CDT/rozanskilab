## RTT02-3 Check for unassigned resources

Included in: Cloud.GO

### Access / Permission Level

| Required AAD role | Required RBAC role     |
|-------------------|------------------------|
| None              | Reader                 |

### Steps

1. Open a powershell session and connect to Azure.
2. Run the following code to check for unassigned disks:

`$subsscriptions = @(`
    `"xxx-xxx-xxx",`
    `"xxx-xxx-xxx",`
    `"xxx-xxx-xxx",`
    `"xxx-xxx-xxx"`
`)`
`$table = @()`
`foreach ($subscription in $subscriptions){`
    `set-azcontext -Subscription `
    `$subscription.name`
    `$disks = Get-AzDisk | ? {$_.DiskState -eq "Unattached"} | select name, resourcegroupname`
    `foreach ($disk in $disks){`
        `$sub = Get-AzContext`
        `$props = @{`
            `'Subscription' = $sub.Subscription.Name`
            `'Disk' = $disk.Name`
            `'Size' = $disk.DiskSizeGB`
            `'Resource Group Name' = $disk.ResourceGroupName`
        `}`
        `$obj = New-Object -TypeName PSObject -Property $props`
        `$table += $obj`
    `}`
    `Start-Sleep -Seconds 10`
`}`
`$table | export-csv -Path ""`

3. Open up a JIRA ticket.

If no unassigned resources have been found the ticket can be closed immediately with the appropriate comment.
In case any unassigned resources are found, the csv should be uploaded and the squad lead and the Client should be notified. The contact on the Customer's side can be found by checking the appropriate tag of the Resource Group in which the unassigned resource is located.
