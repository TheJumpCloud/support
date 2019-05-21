#### Name

Set Desktop Wallpaper - Single User | v1.0 JCCG

#### commandType

windows

#### Command

```
$DownloadURL = ''

## Ensure that the extension matches the filetype that you are downloading
$FileName = 'wallpaper.jpg'
$FilePath = "C:\Windows\Temp\$FileName"


##Enter the username of the user whose wallpaper you would like to set
$Username = ''

#------- Do not modify below this line ------


$User = New-Object System.Security.Principal.NTAccount($Username)

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile($DownloadURL,$FilePath)

    $sid = $User.Translate([System.Security.Principal.SecurityIdentifier]).value

    New-PSDrive HKU Registry HKEY_USERS
    Set-ItemProperty -path "HKU:\$sid\Control Panel\Desktop" -Name 'Wallpaper' -value $FilePath
} catch [Exception] {
    Write-Output $_.Exception.GetType().FullName, $_.Exception.Message
    exit 1
}
```

#### Description

Download an image from a URL and set the Desktop wallpaper to that image for a single user.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'Create and enter Git.io URL'
```
