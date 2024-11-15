<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

#>

<#
.SYNOPSIS
Retreives a all relevant drivers using the dism utility to a saved repository.

.DESCRIPTION
This script retreives all the software and firmware drivers related to the endpoint this is executed on
to the listed destination path. This strategy is useful when you have a large amount of endpoints that
are of the same manufacturer & model and this export allows for injecting the repository of drivers into
a Windows iso provisioning package to streamline device re-imaging.

#>


dism /online /export-driver /destination:C:\temp\<filename> 