# Cloudeteer Prerequisites

Some of the daily tasks require usage of Powershell. 

## Installing Powershell on Windows

Powershell is installed by default on all Windows systems. It is recommended to ensure that the latest stable version is present, and upgrade if necessary.
To perform this check, the following steps need to be completed:

1) Open Poweshell as administrator
2) Run the *$PSversionTable.PsVersion* command
3) Check the existing major and minor version
4) Run the  *winget search Microsoft.PowerShell* command
5) If the found version is newer than the one installed, run the *winget install --id Microsoft.Powershell --source winget* command.
6) Reboot the PC after the installation
7) Verify if Powershell has been upgraded with the *$PSversionTable.PsVersion* command
