<#/ This process will modify the tzautoupdate key in the Windows registry to force the timezone in
Windows to dynamically change based on user location. Once this change has been made then the
Windows time service is then reset to ensure the changes have been applied to the endpoint /#> 

# Enable "Set time zone automatically" setting
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name Start -Value 2

# Restart the Windows Time service to apply changes
Restart-Service w32time
