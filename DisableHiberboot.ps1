# This command will disable hiberboot in the Windows registry by modifying the HiberbootEnabled key
Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -Value 0"
