<#
This script is intend to accelrate a new Windows 10 istall for myself!!
1. clean up built in crapps
2. remove some windows 'features' such as mspaint
3. unpin everything from the start menu
4. install chocolaty followed by some some apps using chocolaty. 
#>

#Clear the Console
Clear-Host

#Install third part PS Modules
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force -Confirm:$false
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name chocolatey -Confirm:$false

#First Phase - clean up Windows 10 store apps.
Write-host "Removing Appx Packages" -BackgroundColor Red -ForegroundColor Yellow
#Variables for the Appx clean up phase
$AppExPackages = "3dviewer",                    #3D Viewer
                "windowsalarms",                #Alarms & Clock 
                "windowscommunicationsapps",    #Calendar and Mail
                "Microsoft.549981C3F5F10",      #Cortana
                "WindowsFeedbackHub",           #Feedback Hub
                "gethelp",                      #Get Help
                "zunemusic",                    #Groove Music
                "windowsmaps",                  #Maps
                "solitairecollection",          #Microsoft Solitaire
                "bingfinance",                  #Microsoft Money
                "MixedReality.Portal",          #MixedReality Portal
                "zunevideo",                    #Movies & TV
                "bingnews",                     #News
                "onenote",                      #Onenote
                "Microsoft.MSPaint",            #Paint 3D
                "photos",                       #Photos
                "bingsports",                   #Sports
                "MicrosoftStickyNotes",         #Sticky Notes
                "SkypeApp",                     #Skype
                "Getstarted",                   #Tips
                "soundrecorder",                #Voice Recorder
                #"bingweather",                  #Weather
                "XboxGamingOverlay",            #Xbox Game Bar
                "xboxapp",                      #Xbox Console Companion
                "YourPhone"                     #Your Phone

#Loop through the appx packages
foreach ($AppExPackage in $AppExPackages) {
    Write-host "Removing $AppExPackage" -ForegroundColor Yellow
    Get-AppxPackage -Name *$AppExPackage* -AllUsers | Remove-AppxPackage
}

#Second Phase - Clean up legacy apps.
Write-host "Removing Appx Packages" -BackgroundColor Red -ForegroundColor Yellow

#Variables legacy apps clean up
$LegacyApps = @("MSPaint", 
                "WordPad", 
                "Notepad", 
                "Print.Fax.Scan", 
                "XPS.Viewer", 
                "Media.WindowsMediaPlayer",
                "Browser.InternetExplorer")

foreach ($LegacyApp in $LegacyApps) {
    Write-host "Removing Appx $LegacyApp" -ForegroundColor Yellow
    Get-WindowsCapability -name *$LegacyApp* -Online | Remove-WindowsCapability -Online
}     

#install choco and apps
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Import-Module -Name chocolatey
$ChocoApps= @("7zip"; "advanced-ip-scanner"; "citrix-workspace"; "firefox", "imageglass"; "notepadplusplus", "paint.net"; "powertoys"; "rufus"; "signal"; "spotify"; "telegram"; "vlc"; "vscode"; "microsoft-windows-terminal")

foreach ($ChocoApp in $ChocoApps) {
    Write-host "Installing $ChocoApp" -ForegroundColor Yellow
    Install-ChocolateyPackage $ChocoApp -AcceptLicense -Confirm:$false
}    

#Unpin all Start menu items, I can't take credit for any of this but it works
Write-host "Unpinning Apps" -BackgroundColor Red -ForegroundColor Yellow
#Requires -RunAsAdministrator

$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

$layoutFile="C:\Windows\StartMenuLayout.xml"

#Delete layout file if it already exists
If(Test-Path $layoutFile)
{
    Remove-Item $layoutFile
}

#Creates the blank layout file
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

$regAliases = @("HKLM", "HKCU")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer"
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

#Restart Explorer and delete the layout file
Stop-Process -name explorer

# Uncomment the next line to make clean start menu default for all new users
#Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

Remove-Item $layoutFile

#Start Menu - Hide Apps List
Write-host "Start Menu - Hide Apps List" -BackgroundColor Red -ForegroundColor Yellow
New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies -Name Explorer -Force
New-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name "NoStartMenuMorePrograms" -Value 3 -PropertyType "Dword" -Force
New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name "NoStartMenuMorePrograms" -Value 3 -PropertyType "Dword" -Force

#Set Time Zone to Eastern
Write-host "Setting EST time zone" -BackgroundColor Red -ForegroundColor Yellow
Set-TimeZone -Name "Eastern Standard Time"

#Turn Nightlight on auto
Write-host "Manually enable night light" -BackgroundColor Red -ForegroundColor Yellow
Start-Process ms-settings:nightlight

#Set Dark Theme
Write-host "Setting dark theme" -BackgroundColor Red -ForegroundColor Yellow
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force

#Disable Timeline
Write-host "Disabling Timeline" -BackgroundColor Red -ForegroundColor Yellow
New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name PublishUserActivities -Value 0 -Type Dword -Force

#Set Powerplan to high performance
Write-host "Setting power plan to High Performance" -BackgroundColor Red -ForegroundColor Yellow
powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

#Disable IPv6
Write-host "Disabling IPv6" -BackgroundColor Red -ForegroundColor Yellow
Disable-NetAdapterBinding –InterfaceAlias “Ethernet0” –ComponentID ms_tcpip6

#Set DNS Search Suffix
Write-host "Set DNS Search Suffic to massons.bz" -BackgroundColor Red -ForegroundColor Yellow
Set-DnsClient –InterfaceAlias “Ethernet0” -ConnectionSpecificSuffix "massons.bz"

#Reboot PC in 30 seconds to apply reg keys
Write-host "This device will restart in 30 seconds, to cancel press Ctrl-C" -BackgroundColor Red -ForegroundColor Yellow
Start-Sleep -Seconds 30
Restart-Computer #-Confirm
