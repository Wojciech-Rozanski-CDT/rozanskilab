## RTT03-1 Check Cost Management Recommendations

### Access / Permission Level

| Required AAD role | Required RBAC role     |
|-------------------|------------------------|
| None              | Reader                 |

### Steps

1. Log on to Azure.
2. Navigate to Advisor.
3. Navigate to Cost Recommendations
4. For each subscription under the Client's scope, identify if there are any recommendations available.
5. For each recommendation - create a JIRA ticket.

[
Discussion - handling the JIRA ticket

Proposal:
1. Validate the actual possibility of implementing the recommendation.
2. Validate the potential cost impact of the implementation (both increase or decrease)
3. Depending on the outcome of the investigation, a change request should be raised. Possible outcomes are:
   - implementation
   - postpone
   - dismissal
]
