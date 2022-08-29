#KB Article Id of the target update
$kbArticleId = 'KB5012170'

#Install Module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force
    
#Verify update has not already been installed ont he device
$installedUpdate = Get-WindowsUpdate -IsInstalled -KBArticleID $kbArticleId
if($installedUpdate) {
    Write-Output("Windows Update KB ID: $kbArticleId has already been installed on the device")
    exit 1
}

#Verify update has not already been downloaded to the device
$downloadedUpdate =  (Get-WindowsUpdate -KBArticleID $kbArticleId).Status.Where({$_ -match "D"})
if($downloadedUpdate) {
    Write-Output("Windows Update KB ID: $kbArticleId has already been downloaded to the device")
    exit 1
}

#Verify update has not already been blocked on the device
$hiddenUpdate = Get-WindowsUpdate -IsHidden -KBArticleID $kbArticleId
if($hiddenUpdate) {
    Write-Output("Windows Update KB ID: $kbArticleId Has already been blocked on the device")
    exit 1
}

#Verify update is available before we attempt to block/hide it
$update = Get-WindowsUpdate -KBArticleID $kbArticleId
if(!$update) {
    Write-Output("Windows Update KB ID: $kbArticleId is not available or was not found")
    exit 1
}

#Removes the windows update from the update list that the update service installs.
Hide-WindowsUpdate -KBArticleID $kbArticleId -Confirm:$false
    
#Verify that the update was disabled and appropriately listed as hidden.
$hiddenUpdate = Get-WindowsUpdate -IsHidden -KBArticleID $kbArticleId

if(!$hiddenUpdate) {
    Write-Output("Windows Update KB ID: $kbArticleId was not disabled")
    exit 1
}

Write-Output("Windows Update KB ID: $kbArticleId was successfully disabled")

exit 0
