## Use this to install the AIP Service module if you don't have it. This is the information protection services module for AzureAD.
## Microsoft Learn Article - https://learn.microsoft.com/en-us/azure/information-protection/install-powershell
Install-Module -Name AIPService

<#/ The AIP service is the current method for managing email encryption templates. Any existing templates for legacy systems will
 still be active, but will need to use the AIP Service to make any changes. Any legacy templates will only be able to be 
 removed and re-imported. You can modify the templates xml file to make the changes to a legacy template.
/#>

## Use this cmdlet connect to the AIP service.
Connect-AIPService

## This will retreive all active email encrption templates.
Get-AIPServiceTemplate

<#/ Use this cmdlet to export the email encryption template to an xml as backup. Change the save path and TemplateId as needed. 
Use the import/get cmdlets once completed and to re-upload. /#>
Export-AipServiceTemplate -Path C:\PathToFile\<filename.xml> -TemplateId 34db98d8-f384-44f4-9fd6-b533a146c71a

## Remove command
Remove-AipServiceTemplate -TemplateId 34db98d8-f384-44f4-9fd6-b533a146c71a

## Import command
Import-AipServiceTemplate -Path C:\PathToFile\<filename.xml>
