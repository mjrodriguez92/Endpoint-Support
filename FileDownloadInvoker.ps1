# Define the URL of the installer
$url = "<url goes here in quotes>"

# Define the directory path where the file will be saved
$outDir = "C:\temp"
$outpath = "$outDir\<filename.extension goes here>"

try {
    # Check if the directory exists, if not, create it
    if (-not (Test-Path -Path $outDir -PathType Container)) {
        New-Item -Path $outDir -ItemType Directory | Out-Null
    }

    # Download the file
    Invoke-WebRequest -Uri $url -OutFile $outpath
    
    # Run the installer
    Start-Process -FilePath "c:\FilePath\<filename.extension goes here>" -Wait
}
catch {
    Write-Host "Error: $_"
}
