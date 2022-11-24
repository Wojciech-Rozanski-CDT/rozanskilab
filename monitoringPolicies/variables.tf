variable "allowedExtensions" {
  type = list(string)
  default = [
    "AzureDiskEncryption",
    "AzureDiskEncryptionForLinux",
    "DependencyAgentWindows",
    "DependencyAgentLinux",
  ]
}

variable "location" {
  type = string
  default = "westeurope"
}