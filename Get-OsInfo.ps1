<#PSScriptInfo

.VERSION 1.0

.AUTHOR Michael Rodriguez


.RELEASENOTES
Version 1.0:  Original published version.

#>

<#
.SYNOPSIS
Retreives information related to existing endpoint.

.DESCRIPTION
This script retreives data such as the service pack and OS versions, model, and manufacturer of connected endpoints.
Endpoints that fail to connect will output an error message indicating a failure to connect and retrieve device information. 

#>



[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelinePropertyName=$True,
    HelpMessage='The. Computer. Name.')]
)

BEGIN {}
PROCESS {
    foreach ($Computer in $ComputerName) {
        try {
            $session = New-CimSession -ComputerName $Computer -ErrorAction Stop
            $os = Get-CimInstance -Verbose:$false -CimSession $session -ClassName win32_operatingsystem
            $cs = Get-CimInstance -Verbose:$false -CimSession $session -ClassName win32_computersystem
            $properties = @{ComputerName = $Computer
                            Status = 'Connected'
                            SPVersion = $os.ServicePackMajorVersion
                            OSVersion = $os.ServicePackMajorVersion
                            Model = $cs.Model
                            Mfgr = $cs.Manufacturer}
        } catch {
            Write-Verbose "Couldn't connect to $computer"
            $properties = @{ComputerName = $Computer
                            Status = 'Disconnected'
                            SPVersion = $null
                            OSVersion = $null
                            Model = $null
                            Mfgr = $null}
        } finally {
            $obj = New-Object -TypeName PSObject -Property $properties
            Write-Output $obj
        }
    }
}
END {}