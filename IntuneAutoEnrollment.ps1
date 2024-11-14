# Function to check if a service is running
function Is-ServiceRunning($serviceName) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    return $service -ne $null -and $service.Status -eq 'Running'
}

# Function to start a service
function Start-ServiceAndWait($serviceName) {
    Start-Service $serviceName
    Start-Sleep -Seconds 30
}

# Function to set the service startup type to Automatic (Delayed Start)
function Set-ServiceStartupTypeAuto($serviceName) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        $currentStartType = (Get-Service -Name = $serviceName)
        if ($currentStartType -ne "Automatic") {
            Write-Host "Setting $serviceName to Automatic"
            Set-Service -Name $serviceName -StartupType Automatic
        } else {
            Write-Host "$serviceName is already set to Automatic (Delayed Start)."
        }
    } else {
        Write-Host "$serviceName not found."
    }
}

# Check if dmwappushservice is running
$serviceName = "dmwappushservice"
$maxAttempts = 3
$attempts = 0

# Ensure the service is set to Automatic (Delayed Start)
Set-ServiceStartupTypeAuto $serviceName

# Check if the service is already running
if (Is-ServiceRunning $serviceName) {
    Write-Host "$serviceName is already running. Continuing with the script..."
}
else {
    while ($attempts -lt $maxAttempts -and !(Is-ServiceRunning $serviceName)) {
        $attempts++
        Write-Host "$serviceName is not running. Attempting to start the service (Attempt $attempts)..."

        Start-ServiceAndWait $serviceName
    }

    # Check if the service is running after the attempts
    if (Is-ServiceRunning $serviceName) {
        Write-Host "$serviceName has been started. Continuing with the script..."
    }
    else {
        Write-Host "Failed to start $serviceName after $maxAttempts attempts. Exiting script with error code 1001."
        exit 1001
    }
}

# Rest of your script goes here...

# Set MDM Enrollment URL's
$key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'

try{
    $keyinfo = Get-Item "HKLM:\$key"
}
catch{
    Write-Host "Tenant ID is not found!"
    exit 1001
}

$url = $keyinfo.name
$url = $url.Split("\")[-1]
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"
if(!(Test-Path $path)){
    Write-Host "KEY $path not found!"
    exit 1001
}else{
    try{
        Get-ItemProperty $path -Name MdmEnrollmentUrl
    }
    catch{
        Write_Host "MDM Enrollment registry keys not found. Registering now..."
        New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
        New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
        New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;
    }
    finally{
    # Trigger AutoEnroll with the deviceenroller
        try{
            C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM
            Write-Host "Triggering device enroller to enroll autopilot device!"
           exit 0
        }
        catch{
            Write-Host "Something went wrong (C:\Windows\system32\deviceenroller.exe)"
           exit 1001          
        }

    }
}
exit 0
