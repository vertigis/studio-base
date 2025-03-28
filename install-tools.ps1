Get-WindowsCapability -Online -Name RSAT.ActiveDirectory.* | Add-WindowsCapability -Online
Add-WindowsCapability -Online -Name OpenSSH.Client | Add-WindowsCapability -Online
Import-Module ActiveDirectory
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/I AzureCLI.msi /quiet' -Wait
Remove-Item AzureCLI.msi
