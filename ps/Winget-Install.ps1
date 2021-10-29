<# 
- winget KB -- https://docs.microsoft.com/en-us/windows/package-manager/winget/
- To search for a new package, use "winget search <package>". 
- Select only packages from the 'winget' source and use the package ID when adding to the $packages variable below.
- VMware Workstation Prereqs -- https://kb.vmware.com/s/article/55798  
#>

#clear console
Clear-Host

#start time
Get-Date 

#variable for list packages
$packages = '7zip.7zip',
            'BraveSoftware.BraveBrowser',
            'Devolutions.RemoteDesktopManagerFree',
            'Jabra.Direct',
            'Microsoft.Teams', 
            'Microsoft.Office',
            'Notepad++.Notepad++', 
            'TechSmith.Snagit',
            'VideoLAN.VLC',
            'WinSCP.WinSCP'

#install loop
foreach ($package in $packages) {
    winget install $package -e --force
}

#end time
Get-Date