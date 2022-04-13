#Sets UAC to 0
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

#Restores right click context menu
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
timeout /t 2
#Disables rounded window edges
start-process .\win11sc.exe
timeout /t 10
taskkill /f /im explorer.exe
timeout /t 1
start-process explorer.exe
timeout /t 1
 # Removes Task View from the Taskbar
New-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0" -PropertyType Dword
Set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value "0"

# Removes Widgets from the Taskbar
New-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0" -PropertyType Dword
Set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value "0"
 
# Removes Chat from the Taskbar
New-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0" -PropertyType Dword
Set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value "0"

 # Default StartMenu alignment 0=Left
New-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value "0" -PropertyType Dword
 
# Removes search from the Taskbar
Set-ItemProperty -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value "0"

#Uninstalls Bloatware
Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *WindowsMaps* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *GetHelp* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *Todos* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *ZuneVideo* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *BingNews* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *OneDriveSync* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *People* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *SkypeApp* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *BingWeather* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *YourPhone* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *Microsoft.Microsoft3DViewer* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *Disney.37853FC22B2CE* | Remove-AppPackage
timeout /t 2
Get-AppxPackage *WebpImageExtension* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *Microsoft.Whiteboard* | Remove-AppxPackage
timeout /t 2
Get-AppxPackage *Microsoft.MixedReality.Portal* | Remove-AppxPackage
timeout /t 2
##Removes Cache of Teams
## Remove the all users' cache. This reads all user subdirectories in each user folder matching
## all folder names in the cache and removes them all
Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Teams\*" -Directory | `
	Where-Object Name -in ('application cache','blob_storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
	ForEach {Remove-Item $_.FullName -Recurse -Force}

## Remove every user's cache. This reads all subdirectories in the $env:APPDATA\Microsoft\Teams folder matching
## all folder names in the cache and removes them all
Get-ChildItem -Path "$env:APPDATA\Microsoft\Teams\*" -Directory | `
	Where-Object Name -in ('application cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | `
	ForEach {Remove-Item $_.FullName -Recurse -Force}
##Removes Installer
function unInstallTeams($path) {
    $clientInstaller = "$($path)\Update.exe"
    
     try {
          $process = Start-Process -FilePath "$clientInstaller" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction STOP
          if ($process.ExitCode -ne 0)
      {
        Write-Error "UnInstallation failed with exit code  $($process.ExitCode)."
          }
      }
      catch {
          Write-Error $_.Exception.Message
      }
  }
  # Remove Teams Machine-Wide Installer
  Write-Host "Removing Teams Machine-wide Installer" -ForegroundColor Yellow
  $MachineWide = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Teams Machine-Wide Installer"}
  $MachineWide.Uninstall()
  # Remove Teams for Current Users
  $localAppData = "$($env:LOCALAPPDATA)\Microsoft\Teams"
  $programData = "$($env:ProgramData)\$($env:USERNAME)\Microsoft\Teams"
  If (Test-Path "$($localAppData)\Current\Teams.exe") 
  {
    unInstallTeams($localAppData)
      
  }
  elseif (Test-Path "$($programData)\Current\Teams.exe") {
    unInstallTeams($programData)
  }
  else {
    Write-Warning  "Teams installation not found"
  }
  
Restart-Computer

