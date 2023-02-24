# Priviliged Role Assignment Tracker

## Background

Keeping track of who has permissions to different resources in the Cloud is a critical process to ensure the policy of least-privilige is followed.
This document consists of two tables.
The first table should be used to track which groups have been given permissions to which resources.
The second table should be used to track which Users have been added to different groups.

It is forbidden to assign any roles without a valid JIRA ticket first.
It is forbidden to assign any roles to indivudal Users. 

## Group/User -> Role Tracker

| Scope | Group | User | Role | JIRA Ticket |
|-------|-------|------|------|-------------|
| /subscriptions/cd4eb8cc-a8ef-4d64-a048-1fcdf51495fd |      |wr@cloudeteer.de       |Azure Kubernetes Service RBAC Cluster Admin      |  ########           |
| /subscriptions/cd4eb8cc-a8ef-4d64-a048-1fcdf51495fd | S-ADM-AZ-KubernetesRbacAdmin     |      |Azure Kubernetes Service RBAC Cluster Admin      |  ########           |
|       |       |      |      |             |

## User -> Group Tracker

| User | Group | JIRA Ticket |
|------|-------|-------------|
| wr@cloudeteer.de     | AZR-Lighouse_BlahBlah      | ##########            |
| mi-SomeManagedIdentity-euw-001     | S-ADM-AZ-KubernetesRbacAdmin       | #######            |
|      |       |             |