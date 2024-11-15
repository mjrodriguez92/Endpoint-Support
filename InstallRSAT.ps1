<#/
This script will install RSAT Tools otherwise known as the Active Directory console.
/#>

Get-WindowsCapability -Name rsat.activedirectory.* -Online | Add-WindowsCapability -Online