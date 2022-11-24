resource "azurerm_monitor_data_collection_rule" "dcr-cdt-detailed" {
  name                = "dcr-performancedata-detailed-cdt"
  resource_group_name = azurerm_resource_group.rg-monitoring-euw-001.name
  location            = azurerm_resource_group.rg-monitoring-euw-001.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law-VmInsights-001.id
      name                  = "logAnalyticsWorkspace-default"
    }

    azure_monitor_metrics {
      name = "azureMonitorMetrics-default"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["azureMonitorMetrics-default"]
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Perf"]
    destinations = ["logAnalyticsWorkspace-default"]
  }

  data_sources {

    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 10
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
      name = "perfCounterDataSource10"
    }
  }
}