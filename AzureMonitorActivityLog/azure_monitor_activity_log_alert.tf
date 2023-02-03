resource "azurerm_monitor_activity_log_alert" "this" {
  name                = var.alert_health
  resource_group_name = data.azurerm_resource_group.example.name
  scopes              = [data.azurerm_subscription.current.id]
  description         = var.alert_description

  criteria {
    category = var.category
	  operation_name = var.operation_name
    resource_provider = var.category == "ResourceHealth" ? var.resource_provider : null
    resource_type = var.category == "ResourceHealth" ? var.resource_type : null
    resource_group = var.category == "ResourceHealth" ? var.alert_resource_group : null
    resource_id = var.category == "ResourceHealth" ? var.resource_id : null
    caller = var.category == "Administrative" || var.category == "Policy" || var.category == "Security" ? var.caller : null
    level = var.level
    status = var.status
    sub_status = var.sub_status
    recommendation_type = var.category == "Recommendation" ? var.recommendation_type : null
    recommendation_category = var.category == "Recommendation" ? var.recommendation_category : null
    recommendation_impact = var.category == "Recommendation" ? var.recommendation_impact : null 
    
    dynamic "service_health" {
        for_each = var.category == "ServiceHealth" ? [true] : []
        content {
            locations = var.service_health_locations
            services  = var.service_health_services
        }
      }

    dynamic "resource_health" {
        for_each = var.category == "ResourceHealth" ? [true] : []
        content {
            current = var.resource_health_current
            previous = var.resource_health_previous
            reason = var.resource_healt_reason
        }
    }
	
  }

  action {
    action_group_id = var.action_group_id
  }
}