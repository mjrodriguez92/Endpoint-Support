                ### This tool will check for missing Intune certificates, if the Certificate is in the wrong certificate store, and if the certificate 
                # has been expired ######

                #################################
                #defining some functions first###
                ###################################
                
                function repair-wrongstore { 
                        $progressPreference = 'silentlyContinue'
                        Write-Host "Exporting and Importing the Intune certificate to the proper Certificate Store"
                    
                        # Download and extract PSTools
                        Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'pstools.zip'
                        Expand-Archive -Path 'pstools.zip' -DestinationPath "$env:TEMP\pstools" -Force
                        
                        # Accept the EULA for PSTools
                        reg.exe ADD HKCU\Software\Sysinternals /v EulaAccepted /t REG_DWORD /d 1 /f | Out-Null
                        
                        # Run the command to fix the certificate store
                        Start-Process -WindowStyle Hidden -FilePath "$env:TEMP\pstools\psexec.exe" -ArgumentList '-s cmd /c "powershell.exe 
            -ExecutionPolicy Bypass -encodedcommand JABjAGUAcgB0AGkAZgBpAGMAYQB0AGUAIAA9ACAARwBlAHQALQBDAGgAaQBsAGQASQB0AGUAbQAgAC0AUABhAHQAaAEMAZQBy
            AHQAOgBcAEMAdQByAHIAZQBuAHQAdQBzAGUAcgBcAE0AeQBcAAoAJABwAGEAcwBzAHcAbwByAGQAPQAgACIAcwBlAGMAcgBlAHQAIgAgAHwAIABDAG8AbgB2AGUAcgB0AFQAbwAtAF
            MAZQBjAHUAcgBlAFMAdAByAGkAbgBHAIAALQBBAHMAUABsAGEAaQBuAFQAZQB4AHQAIAAtAEYAbwByAGMAZQAKAEUAeABwAG8AcgB0AC0AUABmAHgAQwBlAHIAdABpAGYAaQBjAGEA
            dABlACAALQBDAGUAcgB0ACAAJABjAGUAcgB0AGkAZgBpAGMAYQB0AGUAIAAtAEYAaQBsAGUAUABhAHQAaAAgAGMAOgBcAGkAbgB0AHUAbgBlAC4AcABmAHgAIAAtAFAAYQBzAHMAdw
            BvAHIAZAAgACQAcABhAHMAcwB3AG8AcgBkAAoASQBtAHAAbwByAHQALQBQAGYAeABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIAAtAEUAeABwAG8AcgB0AGEAYgBsAGUAIAAtAFAAYQBz
            AHMAdwBvAHIAZAAgACQAcABhAHMAcwB3AG8AcgBkACAALQBDAGUAcgB0AFMAdABvAHIAZQBMAABvAGwAYwBhAHQAaQBvAG4AIABDAGUAcgB0ADoAXABMAG8AYwBhAGwATQBhAGMAaA
            BpAG4AZQBcAE0AeQAgAC0ARgBpAGwAZQBQAGEAdABoACAAYwA6AFwAaQBuAHQAdQBuAGUALgBwAGYAeAA="'
                    }
                    
                
                function test-certdate {
                            Write-Host "Checking If the Certificate hasn't expired"
                            if ((Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq $thumbprint -and $_.NotAfter -lt (Get-Date)}) -eq $null)
                            {
                                Write-Host "Great!!! The Intune Device Certificate is not expired!!"
                            }else{
                                Write-Host "The Intune Device Certificate is EXPIRED!"
                                test-certificate
                            }
                }
                function test-intunecert{
                                if (Get-ChildItem Cert:\LocalMachine\My\ | where{$_.issuer -like "*Microsoft Intune MDM Device CA*"}){
                                write-Host "Intune Device Certificate is in installed in the Local Machine Certificate store"
                                }else{
                                Write-Host "Intune device Certificate still seems to be missing... sorry!"   
                                }
                }
                function test-certificate { 
                                        $progressPreference = 'silentlyContinue'
                                        Write-Host "Trying to enroll your device into Intune..."
                                        test-mdmurls
                                        Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'pstools.zip'
                                        Expand-Archive -Path 'pstools.zip' -DestinationPath "$env:TEMP\pstools" -force
                                        #Move-Item -Path "$env:TEMP\pstools\psexec.exe" -force
                                        reg.exe ADD HKCU\Software\Sysinternals /v EulaAccepted /t REG_DWORD /d 1 /f | out-null
                                        $enroll = Start-Process -windowstyle hidden -FilePath "$env:TEMP\pstools\psexec.exe" -ArgumentList '-s cmd /c "powershell.exe 
                -ExecutionPolicy Bypass -encodedcommand JABSAGUAZwBpAHMAdAByAHkASwBlAHkAcwAgAD0AIAAiAEgASwBMAE0AOgBcAFMATwBGAFQAVwBBAFIARQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwAR
                QBuAHIAbwBsAGwAbQBlAG4AdABzACIALAAgACIASABLAEwATQA6AFwAUwBPAEYAVABXAEEAUgBFAFwATQBpAGMAcgBvAHMAbwBmAHQAXABFAG4AcgBvAGwAbABtAGUAbgB0AHMAXABTAHQAYQB0AHUAcw
                AiACwAIgBIAEsATABNADoAXABTAE8ARgBUAFcAQQBSAEUAXABNAGkAYwByAG8AcwBvAGYAdABcAEUAbgB0AGUAcgBwAHIAaQBzAGUAUgBlAHMAbwB1AHIAYwBlAE0AYQBuAGEAZwBlAHIAXABUAHIAYQB
                jAGsAZQBkACIALAAgACIASABLAEwATQA6AFwAUwBPAEYAVABXAEEAUgBFAFwATQBpAGMAcgBvAHMAbwBmAHQAXABQAG8AbABpAGMAeQBNAGEAbgBhAGcAZQByAFwAQQBkAG0AeABJAG4AcwB0AGEAbABs
                AGUAZAAiACwAIAAiAEgASwBMAE0AOgBcAFMATwBGAFQAVwBBAFIARQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwAUABvAGwAaQBjAHkATQBhAG4AYQBnAGUAcgBcAFAAcgBvAHYAaQBkAGUAcgBzACIALAAiA
                EgASwBMAE0AOgBcAFMATwBGAFQAVwBBAFIARQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwAUAByAG8AdgBpAHMAaQBvAG4AaQBuAGcAXABPAE0AQQBEAE0AXABBAGMAYwBvAHUAbgB0AHMAIgAsACAAIgBIAE
                sATABNADoAXABTAE8ARgBUAFcAQQBSAEUAXABNAGkAYwByAG8AcwBvAGYAdABcAFAAcgBvAHYAaQBzAGkAbwBuAGkAbgBnAFwATwBNAEEARABNAFwATABvAGcAZwBlAHIAIgAsACAAIgBIAEsATABNADo
                AXABTAE8ARgBUAFcAQQBSAEUAXABNAGkAYwByAG8AcwBvAGYAdABcAFAAcgBvAHYAaQBzAGkAbwBuAGkAbgBnAFwATwBNAEEARABNAFwAUwBlAHMAcwBpAG8AbgBzACIACgAKACQARQBuAHIAbwBsAGwA
                bQBlAG4AdABJAEQAIAA9ACAARwBlAHQALQBTAGMAaABlAGQAdQBsAGUAZABUAGEAcwBrACAALQB0AGEAcwBrAG4AYQBtAGUAIAAnAFAAdQBzAGgATABhAHUAbgBjAGgAJwAgAC0ARQByAHIAbwByAEEAY
                wB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQAgAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsAJABfAC4AVABhAHMAawBQAGEAdABoACAALQBsAGkAawBlACAAIg
                AqAE0AaQBjAHIAbwBzAG8AZgB0ACoAVwBpAG4AZABvAHcAcwAqAEUAbgB0AGUAcgBwAHIAaQBzAGUATQBnAG0AdAAqACIAfQAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAALQBFAHgAcAB
                hAG4AZABQAHIAbwBwAGUAcgB0AHkAIABUAGEAcwBrAFAAYQB0AGgAIAAtAFUAbgBpAHEAdQBlACAAfAAgAFcAaABlAHIAZQAtAE8AYgBqAGUAYwB0ACAAewAkAF8AIAAtAGwAaQBrAGUAIAAiACoALQAq
                AC0AKgAiAH0AIAB8ACAAUwBwAGwAaQB0AC0AUABhAHQAaAAgAC0ATABlAGEAZgAKAAoACQAJAGYAbwByAGUAYQBjAGgAIAAoACQASwBlAHkAIABpAG4AIAAkAFIAZQBnAGkAcwB0AHIAeQBLAGUAeQBzA
                CkAIAB7AAoACQAJAAkACQBpAGYAIAAoAFQAZQBzAHQALQBQAGEAdABoACAALQBQAGEAdABoACAAJABLAGUAeQApACAAewAKAAkACQAJAAkACQBnAGUAdAAtAEMAaABpAGwAZABJAHQAZQBtACAALQBQAG
                EAdABoACAAJABLAGUAeQAgAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsAJABfAC4ATgBhAG0AZQAgAC0AbQBhAHQAYwBoACAAJABFAG4AcgBvAGwAbABtAGUAbgB0AEkARAB9ACAAfAAgAFI
                AZQBtAG8AdgBlAC0ASQB0AGUAbQAgAC0AUgBlAGMAdQByAHMAZQAgAC0ARgBvAHIAYwBlACAALQBDAG8AbgBmAGkAcgBtADoAJABmAGEAbABzAGUAIAAtAEUAcgByAG8AcgBBAGMAdABpAG8AbgAgAFMA
                aQBsAGUAbgB0AGwAeQBDAG8AbgB0AGkAbgB1AGUACgAJAH0ACgB9AAoAJABJAG4AdAB1AG4AZQBDAGUAcgB0ACAAPQAgAEcAZQB0AC0AQwBoAGkAbABkAEkAdABlAG0AIAAtAFAAYQB0AGgAIABDAGUAc
                gB0ADoAXABMAG8AYwBhAGwATQBhAGMAaABpAG4AZQBcAE0AeQAgAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsACgAJAAkAJABfAC4ASQBzAHMAdQBlAHIAIAAtAG0AYQB0AGMAaAAgACIASQ
                BuAHQAdQBuAGUAIABNAEQATQAiACAACgAJAH0AIAB8ACAAUgBlAG0AbwB2AGUALQBJAHQAZQBtAAoAaQBmACAAKAAkAEUAbgByAG8AbABsAG0AZQBuAHQASQBEACAALQBuAGUAIAAkAG4AdQBsAGwAKQA
                gAHsAIAAKAAkAZgBvAHIAZQBhAGMAaAAgACgAJABlAG4AcgBvAGwAbABtAGUAbgB0ACAAaQBuACAAJABlAG4AcgBvAGwAbABtAGUAbgB0AGkAZAApAHsACgAJAAkACQBHAGUAdAAtAFMAYwBoAGUAZAB1
                AGwAZQBkAFQAYQBzAGsAIAB8ACAAVwBoAGUAcgBlAC0ATwBiAGoAZQBjAHQAIAB7ACQAXwAuAFQAYQBzAGsAcABhAHQAaAAgAC0AbQBhAHQAYwBoACAAJABFAG4AcgBvAGwAbABtAGUAbgB0AH0AIAB8A
                CAAVQBuAHIAZQBnAGkAcwB0AGUAcgAtAFMAYwBoAGUAZAB1AGwAZQBkAFQAYQBzAGsAIAAtAEMAbwBuAGYAaQByAG0AOgAkAGYAYQBsAHMAZQAKAAkACQAJACQAcwBjAGgAZQBkAHUAbABlAE8AYgBqAG
                UAYwB0ACAAPQAgAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAEMAbwBtAE8AYgBqAGUAYwB0ACAAcwBjAGgAZQBkAHUAbABlAC4AcwBlAHIAdgBpAGMAZQAKAAkACQAJACQAcwBjAGgAZQBkAHUAbABlAE8
                AYgBqAGUAYwB0AC4AYwBvAG4AbgBlAGMAdAAoACkACgAJAAkACQAkAHIAbwBvAHQARgBvAGwAZABlAHIAIAA9ACAAJABzAGMAaABlAGQAdQBsAGUATwBiAGoAZQBjAHQALgBHAGUAdABGAG8AbABkAGUA
                cgAoACIAXABNAGkAYwByAG8AcwBvAGYAdABcAFcAaQBuAGQAbwB3AHMAXABFAG4AdABlAHIAcAByAGkAcwBlAE0AZwBtAHQAIgApAAoACQAJAAkAJAByAG8AbwB0AEYAbwBsAGQAZQByAC4ARABlAGwAZ
                QB0AGUARgBvAGwAZABlAHIAKAAkAEUAbgByAG8AbABsAG0AZQBuAHQALAAkAG4AdQBsAGwAKQAKAH0AIAAKAH0AIAAKAAoAJABFAG4AcgBvAGwAbABtAGUAbgB0AEkARABNAEQATQAgAD0AIABHAGUAdA
                AtAFMAYwBoAGUAZAB1AGwAZQBkAFQAYQBzAGsAIAB8ACAAVwBoAGUAcgBlAC0ATwBiAGoAZQBjAHQAIAB7ACQAXwAuAFQAYQBzAGsAUABhAHQAaAAgAC0AbABpAGsAZQAgACIAKgBNAGkAYwByAG8AcwB
                vAGYAdAAqAFcAaQBuAGQAbwB3AHMAKgBFAG4AdABlAHIAcAByAGkAcwBlAE0AZwBtAHQAKgAiAH0AIAB8ACAAUwBlAGwAZQBjAHQALQBPAGIAagBlAGMAdAAgAC0ARQB4AHAAYQBuAGQAUAByAG8AcABl
                AHIAdAB5ACAAVABhAHMAawBQAGEAdABoACAALQBVAG4AaQBxAHUAZQAgAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsAJABfACAALQBsAGkAawBlACAAIgAqAC0AKgAtACoAIgB9ACAAfAAgA
                FMAcABsAGkAdAAtAFAAYQB0AGgAIAAtAEwAZQBhAGYACgAJAAkAZgBvAHIAZQBhAGMAaAAgACgAJABLAGUAeQAgAGkAbgAgACQAUgBlAGcAaQBzAHQAcgB5AEsAZQB5AHMAKQAgAHsACgAJAAkACQAJAG
                kAZgAgACgAVABlAHMAdAAtAFAAYQB0AGgAIAAtAFAAYQB0AGgAIAAkAEsAZQB5ACkAIAB7AAoACQAJAAkACQAJAGcAZQB0AC0AQwBoAGkAbABkAEkAdABlAG0AIAAtAFAAYQB0AGgAIAAkAEsAZQB5ACA
                AfAAgAFcAaABlAHIAZQAtAE8AYgBqAGUAYwB0ACAAewAkAF8ALgBOAGEAbQBlACAALQBtAGEAdABjAGgAIAAkAEUAbgByAG8AbABsAG0AZQBuAHQASQBEAE0ARABNAH0AIAB8ACAAUgBlAG0AbwB2AGUA
                LQBJAHQAZQBtACAALQBSAGUAYwB1AHIAcwBlACAALQBGAG8AcgBjAGUAIAAtAEMAbwBuAGYAaQByAG0AOgAkAGYAYQBsAHMAZQAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAb
                AB5AEMAbwBuAHQAaQBuAHUAZQAKAAkAfQAKAH0ACgBpAGYAIAAoACQARQBuAHIAbwBsAGwAbQBlAG4AdABJAEQATQBEAE0AIAAtAG4AZQAgACQAbgB1AGwAbAApACAAewAgAAoACQBmAG8AcgBlAGEAYw
                BoACAAKAAkAGUAbgByAG8AbABsAG0AZQBuAHQAIABpAG4AIAAkAGUAbgByAG8AbABsAG0AZQBuAHQAaQBkAE0ARABNACkAewAKAAkACQAJAEcAZQB0AC0AUwBjAGgAZQBkAHUAbABlAGQAVABhAHMAawA
                gAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsAJABfAC4AVABhAHMAawBwAGEAdABoACAALQBtAGEAdABjAGgAIAAkAEUAbgByAG8AbABsAG0AZQBuAHQAfQAgAHwAIABVAG4AcgBlAGcAaQBz
                AHQAZQByAC0AUwBjAGgAZQBkAHUAbABlAGQAVABhAHMAawAgAC0AQwBvAG4AZgBpAHIAbQA6ACQAZgBhAGwAcwBlAAoACQAJAAkAJABzAGMAaABlAGQAdQBsAGUATwBiAGoAZQBjAHQAIAA9ACAATgBlA
                HcALQBPAGIAagBlAGMAdAAgAC0AQwBvAG0ATwBiAGoAZQBjAHQAIABzAGMAaABlAGQAdQBsAGUALgBzAGUAcgB2AGkAYwBlAAoACQAJAAkAJABzAGMAaABlAGQAdQBsAGUATwBiAGoAZQBjAHQALgBjAG
                8AbgBuAGUAYwB0ACgAKQAKAAkACQAJACQAcgBvAG8AdABGAG8AbABkAGUAcgAgAD0AIAAkAHMAYwBoAGUAZAB1AGwAZQBPAGIAagBlAGMAdAAuAEcAZQB0AEYAbwBsAGQAZQByACgAIgBcAE0AaQBjAHI
                AbwBzAG8AZgB0AFwAVwBpAG4AZABvAHcAcwBcAEUAbgB0AGUAcgBwAHIAaQBzAGUATQBnAG0AdAAiACkACgAJAAkACQAkAHIAbwBvAHQARgBvAGwAZABlAHIALgBEAGUAbABlAHQAZQBGAG8AbABkAGUA
                cgAoACQARQBuAHIAbwBsAGwAbQBlAG4AdAAsACQAbgB1AGwAbAApAAoAfQAgAAoAJABJAG4AdAB1AG4AZQBDAGUAcgB0ACAAPQAgAEcAZQB0AC0AQwBoAGkAbABkAEkAdABlAG0AIAAtAFAAYQB0AGgAI
                ABDAGUAcgB0ADoAXABMAG8AYwBhAGwATQBhAGMAaABpAG4AZQBcAE0AeQAgAHwAIABXAGgAZQByAGUALQBPAGIAagBlAGMAdAAgAHsACgAJAAkAJABfAC4ASQBzAHMAdQBlAHIAIAAtAG0AYQB0AGMAaA
                AgACIATQBpAGMAcgBvAHMAbwBmAHQAIABEAGUAdgBpAGMAZQAgAE0AYQBuAGEAZwBlAG0AZQBuAHQAIABEAGUAdgBpAGMAZQAgAEMAQQAiACAACgAJAH0AIAB8ACAAUgBlAG0AbwB2AGUALQBJAHQAZQB
                tAAoAfQAJAAoAUwB0AGEAcgB0AC0AUwBsAGUAZQBwACAALQBTAGUAYwBvAG4AZABzACAANQAKACQARQBuAHIAbwBsAGwAbQBlAG4AdABQAHIAbwBjAGUAcwBzACAAPQAgAFMAdABhAHIAdAAtAFAAcgBv
                AGMAZQBzAHMAIAAtAEYAaQBsAGUAUABhAHQAaAAgACIAQwA6AFwAVwBpAG4AZABvAHcAcwBcAFMAeQBzAHQAZQBtADMAMgBcAEQAZQB2AGkAYwBlAEUAbgByAG8AbABsAGUAcgAuAGUAeABlACIAIAAtA
                EEAcgBnAHUAbQBlAG4AdABMAGkAcwB0ACAAIgAvAEMAIAAvAEEAdQB0AG8AZQBuAHIAbwBsAGwATQBEAE0AIgAgAC0ATgBvAE4AZQB3AFcAaQBuAGQAbwB3ACAALQBXAGEAaQB0ACAALQBQAGEAcwBzAF
                QAaAByAHUACgA="' 
    
                                Write-Host "`n"
                                Write-Host "Please give the OMA DM client some time (about 30 seconds) to sync and get your device enrolled into Intune"
                                Write-Host "`n"
                                Start-Sleep -Seconds 30
                                Write-Host "Checking the Intune Certificate Again!"
                                    test-intunecert
                                    test-dmwapservice
                                    Get-ScheduledTask | Where-Object { $_.TaskName -eq 'Schedule #1 created by enrollment client' } | Start-ScheduledTask
                                    Start-Sleep -Seconds 10
                                    $Shell = New-Object -ComObject Shell.Application
                                    $Shell.Open("intunemanagementextension://syncapp")
                                    test-dmpcert
                                    Start-Sleep -Seconds 5
                                    get-schedule1
    exit
}

                
                function test-privatekey {                 

                                if ($decision -eq 0) {
                                                Write-Host "List certificates without private key: " -NoNewline
                                            $certsWithoutKey = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.HasPrivateKey -eq $false}
                                            
                                            if($certsWithoutKey) {
                                                    Write-Host "V"
                                                    $Choice = $certsWithoutKey | Select-Object Subject, Issuer, NotAfter, ThumbPrint | Out-Gridview -Passthru
                                                    
                                                if($Choice){
                                                        Write-Host "Search private key for $($Choice.Thumbprint): " -NoNewline
                                                        $Output = certutil -repairstore my "$($Choice.Thumbprint)"
                                                        $Result = [regex]::match($output, "CertUtil: (.*)").Groups[1].Value
                                                        
                                                    if($Result -eq '-repairstore command completed successfully.') {
                                                               Write-Host "V"
                                                       }else{
                                                            Write-Host $Result
                                                        }
                                                       }else{
                                                    Write-Host "No choice was made."
                                                    }
                                            }else{
                                               Write-Host "There were no certificates found without private key."
                                            }
                                        }else{
                                               Write-Host 'You cancelled the fix...'
                                            $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                                            exit 1
                                        }
                }
                function get-privatekey{ 
                                if ((Get-ChildItem Cert:\LocalMachine\My | where {$_.Thumbprint -match $thumbprint}).HasPrivateKey){
                                 Write-Host "Nice.. your Intune Device Certificate still has its private key"
                                }else{
                                Write-Host "The certificate is missing its private key"
                                test-privatekey
                                }
                }
function test-mdmlog {
    Write-Host "Hold on a moment... Initializing a sync and checking the MDM logs for sync errors!"
    $Shell = New-Object -ComObject Shell.Application
    $Shell.Open("intunemanagementextension://syncapp")
    Start-Sleep -Seconds 5
    
    Remove-Item -Path "$env:TEMP\diag\*" -Force -ErrorAction SilentlyContinue 
    Start-Process -FilePath "MdmDiagnosticsTool.exe" -ArgumentList "-out $env:TEMP\diag\" -Wait -NoNewWindow
    
    $checkmdmlog = Select-String -Path "$env:TEMP\diag\MDMDiagReport.html" -Pattern "The last sync failed"
    if ($checkmdmlog -eq $null) {
        Write-Host "Not detecting any sync errors in the MDM log"
    } else {
        Write-Host "I have found some Intune sync issues going on, resolving this now!"
    }
}

function test-imelog {
    $path = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log"
    if (Test-Path $path) { 
        $checklog = Select-String -Path $path -Pattern "Set MdmDeviceCertificate : $thumbprint"
        if ($checklog -ne $null) {
            Write-Host "Great! The proper Intune certificate with $thumbprint is also mentioned in the IME!"
        } else {
            $checklogzero = Select-String -Path $path -Pattern "Find 0 MDM certificates"
            $firstline = $checklogzero | Select-Object -First 1         
            Write-Host "Ow my.. this could not be a good thing... $firstline"
        }
    } else {
        Write-Host "Uhhhhh... the log is missing... it seems the IME is not installed"
    }
    test-imeservice
}

                function test-dmpcert{
                                write-host "`n"
                                write-host "Determing if the certificate mentioned in the SSLClientCertreference is also configured in the Enrollments part of the 
                registry "
                try {     
                    $ProviderRegistryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments"
                    $ProviderPropertyName = "ProviderID"
                    $ProviderPropertyValue = "MS DM Server"
                    
                    $GUID = (Get-ChildItem -Path Registry::$ProviderRegistryPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object { 
                        if ((Get-ItemProperty -Name $ProviderPropertyName -Path $_.PSPath -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name $ProviderPropertyName -ErrorAction SilentlyContinue) -match $ProviderPropertyValue) { 
                            $_ 
                        } 
                    }).PSChildName
                    
                    $cert = Get-ChildItem Cert:\LocalMachine\My\ | Where-Object { $_.issuer -like "*Microsoft Intune MDM Device CA*" }
                    $certThumbprint = $cert.thumbprint
                    $certSubject = $cert.subject
                    $subject = $certSubject -replace "CN=", ""
                    
                } catch {
                    Write-Host "Failed to get GUID for enrollment from registry, device doesn't seem enrolled?"
                }
            }
                
                if((Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Enrollments\$guid").DMPCertThumbPrint -eq $certthumbprint){
                        Write-Host "Great!!! The Intune Device Certificate with the Thumbprint $certthumbprint is configured in the registry Enrollments"
                    }else{
                        Write-Host "Intune Device Certificate is not configured in the Registry Enrollments"
                        }
                        function Get-SslClientCertReference {
    try { 
        $ProviderRegistryPath = "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\"
        $ProviderPropertyName = "ServerVer"
        $ProviderPropertyValue = "4.0"
        
        $GUID = (Get-ChildItem -Path $ProviderRegistryPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object { 
            if ((Get-ItemProperty -Name $ProviderPropertyName -Path $_.PSPath -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name $ProviderPropertyName -ErrorAction SilentlyContinue) -match $ProviderPropertyValue) { 
                $_ 
            } 
        }).PSChildName
        
        $ssl = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$GUID" -ErrorAction SilentlyContinue).sslclientcertreference
        
        if ($ssl -eq $null) {
            Write-Host "That's weird, your device doesn't seem to be enrolled into Intune. Let's find out why! Hold my beer!" 
        } else {
            Write-Host "Device seems to be enrolled into Intune... proceeding"
        }
        
    } catch [System.Exception] {
        Write-Error "Failed to get Enrollment GUID or SSL Client Reference for enrollment from registry; the device doesn't seem enrolled or it needs a reboot first"
    }
}
                      
                
                                    function Test-IMEService {
                                        Write-Host "`n"
                                        Write-Host "Determining if the IME service is successfully installed" 
                                    
                                        $path = "C:\Program Files (x86)\Microsoft Intune Management Extension\Microsoft.Management.Services.IntuneWindowsAgent.exe"
                                        
                                        If (Test-Path $path) { 
                                            Write-Host "IntuneWindowsAgent.exe is available on the device"
                                            Write-Host "Going to check if the IME service is installed"
                                            
                                            $service = Get-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue
                                            
                                            if ($service.Length -gt 0) {
                                                Write-Host "Yippee ki-yay, the IME service seems to be installed!" 
                                            } else {
                                                Write-Host "Mmm okay... The IME software isn't installed"
                                            }
                                            
                                        } else {
                                            Write-Host "IntuneWindowsAgent.exe seems to be missing, checking if it's even installed" 
                                            
                                            if ((Get-WmiObject -Class Win32_Product).caption -eq "Microsoft Intune Management Extension") { 
                                                Write-Host "Yippee ki-yay, the IME software seems to be installed!"
                                            } else {
                                                Write-Host "Mmm okay... The IME software isn't installed"
                                                
                                                $ProviderRegistryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseDesktopAppManagement\S-0-0-00-0000000000-0000000000-000000000-000\MSI"    
                                                $ProviderPropertyName = "CurrentDownloadUrl"        
                                                $ProviderPropertyValue = "*IntuneWindowsAgent.msi*"    
                                                
                                                $GUID = (Get-ChildItem -Path Registry::$ProviderRegistryPath -Recurse -ErrorAction SilentlyContinue | 
                                                         ForEach-Object { 
                                                            if ((Get-ItemProperty -Name $ProviderPropertyName -Path $_.PSPath -ErrorAction SilentlyContinue | 
                                                                Get-ItemPropertyValue -Name $ProviderPropertyName -ErrorAction SilentlyContinue) -like $ProviderPropertyValue) { 
                                                                $_ 
                                                            } 
                                                        }).pschildname | Select-Object -First 1
                                                            
                                                $link = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EnterpriseDesktopAppManagement\S-0-0-00-0000000000-0000000000-000000000-000\MSI\$GUID"
                                                $link = $link.CurrentDownloadUrl
                                                
                                                Invoke-WebRequest -Uri $link -OutFile 'IntuneWindowsAgent.msi'
                                                .\IntuneWindowsAgent.msi /quiet
                                                Write-Host "IntuneWindowsAgent.msi has been downloaded and installed" 
                                            }
                                        }
                                    }                                    
function Test-EntDMID {
    Write-Host "`n"
    Write-Host "Determining if the certificate subject is also configured in the EntDMID key" 

    try {     
        $ProviderRegistryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments"
        $ProviderPropertyName = "ProviderID"
        $ProviderPropertyValue = "MS DM Server"

        $GUID = (Get-ChildItem -Path Registry::$ProviderRegistryPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object { 
            if ((Get-ItemProperty -Name $ProviderPropertyName -Path $_.PSPath -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name $ProviderPropertyName -ErrorAction SilentlyContinue) -match $ProviderPropertyValue) { 
                $_ 
            } 
        }).PSChildName
        
        $cert = (Get-ChildItem Cert:\LocalMachine\My\ | Where-Object { $_.Issuer -like "*Microsoft Intune MDM Device CA*" })
        $certThumbprint = $cert.Thumbprint
        $certSubject = $cert.Subject
        $subject = $certSubject -replace "CN=", ""

    } catch {
        Write-Host "Failed to get GUID for enrollment from registry, device doesn't seem enrolled?" 
        return
    }

    try {
        $entDMID = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Enrollments\$GUID\DMClient\MS DM Server").EntDMID
        if ($entDMID -eq $subject) {
            Write-Host "I have good news!! The subject of the Intune Certificate is also set in the EntDMID registry key!!"
        } else {
            Write-Host "I have some bad news! The EntDMID key is not configured; you probably need to reboot the device and run the test again"
        }
    } catch {
        Write-Host "Failed to get the EntDMID registry key or compare it with the certificate subject."
    }
}

                function test-dmwapservice{
                                    write-host "`n"
                                    write-host "Determing if the dmwappushservice is running because we don't want to end up with no endpoints left to the 
                endpointmapper"
                                    $ServiceName = "dmwappushservice"
                                    $ServiceStatus = (Get-Service -Name $ServiceName).status
                                        if($ServiceStatus -eq "Running")
                                        {
                                               Write-Host "I am happy...! The DMWAPPUSHSERVICE is Running!"
                                                                    }
                                        else {
                                                   Write-Host "The DMWAPPUSHSERVICE isn't running, let's kickstart that service to speed up the enrollment! " 
                                                   Start-Service $Servicename -ErrorAction SilentlyContinue    
                                            }
                }
                function get-schedule1 {
                write-host "Almost finished, checking if the EnterpriseMGT tasks are running to start the sync!"
    
                 If ((Get-ScheduledTask | Where-Object { $_.TaskName -eq 'Schedule #1 created by enrollment client' }).State -eq 'Running') {
                    write-host "`n"
                    write-host "Enrollment task is running! It looks like I fixed your sync issues!"

                        } elseif ((Get-ScheduledTask | Where-Object { $_.TaskName -eq 'Schedule #1 created by enrollment client' }).State -eq 'Ready') {
                        write-host "Enrollment task is ready!!!"
                        } else {
                        write-host "Enrollment task doesn't exist"
                }
}

                function test-mdmurls{
                            write-host "`n"
                            write-host "Determing if the required MDM enrollment urls are configured in the registry"
                
                            $key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*' 
                            $keyinfo = Get-Item "HKLM:\$key" -ErrorAction Ignore
                            $url = $keyinfo.name
                            $url = $url.Split("\")[-1]
                            $path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url" 
                
                if (test-path $path){
                $mdmurl = get-itemproperty -LiteralPath $path -Name 'MdmEnrollmentUrl'
                $mdmurl = $mdmurl.mdmenrollmenturl
                }else{
                    write-host "I guess I am missing the proper tenantinfo" 
                            }
                
                
                if($mdmurl -eq "https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc"){
                        write-host "MDM Enrollment URLS are configured the way I like it!Nice!!" 
                        
                }else{
                    write-host "MDM enrollment url's are missing! Let me get my wrench and fix it for you!" 
                    New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' 
                -PropertyType String -Force -ea SilentlyContinue;
                    New-ItemProperty -LiteralPath $path  -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String 
                -Force -ea SilentlyContinue;
                    New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType 
                String -Force -ea SilentlyContinue;                            
                            }
                }
                
                ##################################################################
                ###############starting the reallll script########################
                ##################################################################
                $RegistryKeys = "HKLM:\SOFTWARE\Microsoft\Enrollments", 
                "HKLM:\SOFTWARE\Microsoft\Enrollments\Status","HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked", 
                "HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled", 
                "HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers","HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts", 
                "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger", "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"
                
                #fetching the enrollmentid
                $task = Get-ScheduledTask -taskname 'PushLaunch' | Where-Object {$_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt*"} 
                if ($task) {
                            # Extract TaskPath and process to get EnrollmentID
                            $taskPath = $task.TaskPath
                            $filteredPath = $taskPath | Where-Object { $_ -like "*-*-*" }
                               $EnrollmentID = Split-Path -Path $filteredPath -Leaf
                }
                
                test-mdmlog
                write-host "`n"
                write-host "Determining if the device is enrolled and fetching the SSLClientCertReference registry key" 
                try { 
                    $ProviderRegistryPath = "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollmentID"
                    $ProviderPropertyName = "SslClientCertReference"
                    $GUID = (Get-Item -Path $ProviderRegistryPath -ErrorAction SilentlyContinue | ForEach-Object { 
                        if ((Get-ItemProperty -Name $ProviderPropertyName -Path $_.PSPath -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name $ProviderPropertyName -ErrorAction SilentlyContinue)) { 
                            $_ 
                        } 
                    }).PSChildName
                    
                    $ssl = (Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$guid" -ErrorAction SilentlyContinue).sslclientcertreference
                } 
                catch [System.Exception] {
                    Write-Error "Failed to get Enrollment GUID or SSL Client Reference for enrollment from registry... that's odd almost as if the Intune Certificate is gone" 
                    $result = $false
                }
                
                if ($ssl -eq $null) {
                    Write-Host "That's weird, your device doesn't seem to be enrolled into Intune, let's find out why!!"
                } else {
                    Write-Host "Device seems to be Enrolled into Intune... proceeding" 
                }
                
                Write-Host "`n"
                Write-Host "Checking the Certificate Prefix to find out if it is configured as SYSTEM or USER"
                
                try {
                    $thumbprintPrefix = "MY;System;"
                    $thumbprint = $ssl.Replace($thumbprintPrefix, "")         
                    
                    if ($ssl.StartsWith($thumbprintPrefix) -eq $true) { 
                        Write-Host "The Intune Certificate Prefix is configured as $thumbprintPrefix"
                        Write-Host "`n"
                        Write-Host "Determining if the certificate is installed in the local machine certificate store" 
                        
                        if (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }) {
                            Write-Host "Intune Device Certificate is installed in the Local Machine Certificate store" 
                            Write-Host "`n"
                            Test-CertDate
                            Write-Host "`n"
                            Write-Host "Checking if the Certificate is also mentioned in the IME log" 
                            test-IMLog
                        } else {
                            Write-Host "Intune device Certificate is missing in the Local Machine Certificate store"    
                            Test-Certificate
                            Write-Host "Running some tests to determine if the device has the SSLClientCertReference registry key configured!"
                            Get-SSLClientCertReference
                        }
                
                        Write-Host "`n"
                        Write-Host "Determining if the certificate has a Private Key Attached"
                        Get-PrivateKey
                        test-DMPCert
                
                    } else {
                        Write-Host "Damn... the SSL prefix is not configured as SYSTEM but as $SSL"
                        $thumbprintPrefix = "MY;User;"
                        $thumbprint = $ssl.Replace($thumbprintPrefix, "")
                        
                        Write-Host "`n"
                        Write-Host "Determining if the certificate is also not in the System Certificate Store" 
                        
                        if (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }) {
                            Write-Host "Intune Device Certificate is installed in the Local Machine Certificate store" 
                            Write-Host "`n"
                            Test-CertDate
                            Write-Host "`n"
                            Write-Host "Determining if the certificate has a Private Key Attached"
                            Get-PrivateKey
                            test-DMPCert
                        } else {
                            Write-Host "Intune device Certificate is installed in the wrong user store. I will fix it for you!"
                            Repair-WrongStore
                            Write-Host "Determining if the certificate is now installed in the proper store"
                            Test-IntuneCert
                        }
                    }
                }
                catch {
                    Write-Host "Failed to get the Certificate Details, device doesn't seem enrolled? Let's fix it!"
                    Test-Certificate
                }                
                
                test-entdmid  
                