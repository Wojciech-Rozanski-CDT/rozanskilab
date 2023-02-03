variable "azure_monitor_action_group_rg" {
    type = string
    description = "Name of the Resource Group the Action Group should be created in"
}

variable "itsm_log_analytics_workspace_name" {
    type = string
    description = "The Azure Log Analytics workspace ID where the ITSM connection is defined."
}

variable "action_group_name" {
    type = string
    description = "Name for the action group"
}

variable "action_group_short_name" {
    type = string
    description = "The short name of the action group. This will be used in SMS messages"
}

variable "arm_role_receiver_name" {
    type = string
    description = "The name of the ARM role receiver"
    default = null
}

variable "arm_role_id" {
    type = string
    description = "The arm role id."
    default = null
}

variable "first_email_receiver_name" {
    type = string
    description = "First e-mail receiver name"
    default = null
}

variable "first_email_receiver_address" {
    type = string
    description = "First e-mail receiver address"
    default = null
}

variable "second_email_receiver_name" {
    type = string
    description = "Second e-mail receiver name"
    default = null
}

variable "second_email_receiver_address" {
    type = string
    description = "second e-mail receiver address"
    default = null
}

variable "itsm_receiver_name" {
    type = string
    description = "The name of the ITSM receiver"
    default = null
}

variable "connection_id" {
    type = string
    description = "The unique connection identifier of the ITSM connection"
    default = null
}

variable "ticket_configuration" {
    type = string
    description = "A JSON blob for the configurations of the ITSM action. CreateMultipleWorkItems option will be part of this blob as well"
    default = null
}

variable "sms_receiver_name" {
    type = string
    description = "The name of the SMS receiver. Names must be unique (case-insensitive) across all receivers within an action group"
    default = null
}

variable "sms_country_code" {
    type = number
    description = "The country code of the SMS receiver"
    default = null
}

variable "sms_phone_number" {
    type = number
    description = "The phone number of the SMS receiver"
    default = null
}