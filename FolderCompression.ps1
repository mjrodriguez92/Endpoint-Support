# Set the path of the folder to compress
$folderPath = "C:\PathToFile"

# Set the path and name of the zip file to create
$zipFilePath = "C:\PathToFile\<filename>.zip"

# Check if the folder exists
if (Test-Path $folderPath) {
    # Create a new zip file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($folderPath, $zipFilePath)
    Write-Host "Folder compressed successfully."
} else {
    Write-Host "Folder does not exist."
}
