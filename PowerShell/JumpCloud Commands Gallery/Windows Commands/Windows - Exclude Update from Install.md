#### Name

Windows - Exclude Update from Install | v1.0 JCCG

#### commandType

windows

#### Command

```
########################################################
# To target a specific update, replace the <Update_KB_Article_Id> text with the target update KB ID.
# Example: $kbArticleId = 'KB1234567'
########################################################

# KB Article Id of the target update
$kbArticleId = '<Update_KB_Article_Id>'

# Install Module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force
    
# Check if update is already installed
$update = Get-WindowsUpdate -IsInstalled -KBArticleID $kbArticleId
if($update) {
    Write-Output("Update $kbArticleId has already been installed on device")
    exit 1
}

# Verify update is available before we attempt to block/hide it
$update = Get-WindowsUpdate -KBArticleID $kbArticleId
if(!$update) {
    Write-Output("Windows Update KB ID: $kbArticleId is not available or was not found")
    exit 1
}

# Removes the windows update from the update list that the update service installs.
Hide-WindowsUpdate -KBArticleID $kbArticleId -Confirm:$false
    
# Verify that the update was disabled and appropriately listed as hidden.
$update = Get-WindowsUpdate -IsHidden -KBArticleID $kbArticleId
if(!$update) {
    Write-Output("Windows Update KB ID: $kbArticleId was not disabled")
    exit 1
}

Write-Output("Windows Update KB ID: $kbArticleId was successfully disabled")

exit 0
```

#### Description

This command will download the PSWindowsUpdate module and disable the Update that the user supplies

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Exclude%20Update%20from%20Install.md'
```
