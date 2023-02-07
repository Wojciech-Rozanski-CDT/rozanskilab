variable "azure_monitor_action_group_rg" {
    type = string
    description = "Name of the Resource Group the Action Group should be created in"
}

variable "action_group_name" {
    type = string
    description = "Name for the action group"
}

variable "action_group_short_name" {
    type = string
    description = "The short name of the action group. This will be used in SMS messages"
}