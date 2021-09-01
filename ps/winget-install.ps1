#clear console
cls

#start time
Get-Date 

#variable for the packages
$packages = 'VMware.WorkstationPro' , 'TechSmith.Snagit' , 'Microsoft.Teams' , 'Microsoft.Office' , 'BraveSoftware.BraveBrowser' , 'Devolutions.RemoteDesktopManagerFree' , 'Jabra.Direct' , 'Notepad++.Notepad++' , 'OpenWhisperSystems.Signal' , 'VideoLAN.VLC' , 'WinSCP.WinSCP'    #'Microsoft.VC++2017Redist-x64' , '7zip.7zip'

#install loop
#Install KB -- https://docs.microsoft.com/en-us/windows/package-manager/winget/install
#VMware Workstation -- https://kb.vmware.com/s/article/55798
foreach ($package in $packages) {

winget install $package -e --force

}

#end time
Get-Date