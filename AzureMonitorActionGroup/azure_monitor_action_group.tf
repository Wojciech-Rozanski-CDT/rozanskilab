resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.azure_monitor_action_group_rg
  short_name          = var.action_group_short_name

  dynamic "arm_role_receiver" {
    for_each = local.arm_role_receivers
    content{
      name                    = arm_role_receiver.value["name"]
      role_id                 = arm_role_receiver.value["id"]
      use_common_alert_schema = true
    }
    
  }

  dynamic "email_receiver" {
    for_each = local.email_receivers
    content {
      name                    = email_receiver.value["name"]
      email_address           = email_receiver.value["email_address"]
      use_common_alert_schema = true
    }
    
  }

  dynamic "sms_receiver" {
    for_each = local.sms_receivers
    content{
      name         = sms_receiver.value["name"]
      country_code = sms_receiver.value["code"]
      phone_number = sms_receiver.value["number"]
    }
    
  }

}