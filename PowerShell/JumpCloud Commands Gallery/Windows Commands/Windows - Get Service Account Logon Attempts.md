#### Name

Windows - Get Service Account Logon Attempts | v1.0 JCCG

#### commandType

windows

#### Command

```
## Enter the date range to search on the lines below

$StartTime = '11/05/2020 08:00:00'
$EndTime = '11/05/2020 08:20:00'
$EventIdFilter = ('4624', '4625')

#------ Do not modify below this line ---------------

$Events = Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = $EventIdFilter; StartTime = $StartTime; EndTime = $EndTime; } | Where-Object { $_.Message | Select-String -Pattern:('(Logon Type:)(.*?)(5)') } | Sort-Object CreatedTimestamp
$Events | ForEach-Object {
    [PSCustomObject]@{
        Type            = Switch ($_.Id) { '4624' { 'Login Success' } '4625' { 'Login Failure' } }
        MachineName   = $_.MachineName
        TimeCreated   = $_.TimeCreated
        ElevatedToken = ($_.Message | Select-String -Pattern:('(Elevated Token:)(.*?)(\n)')).Matches.Value.Replace('Elevated Token:', '').Trim()
        AccountName   = ($_.Message | Select-String -Pattern:('(Account Name:)(.*?)(\n)')).Matches.Value.Replace('Account Name:','').Trim()
        ProcessName   = ($_.Message | Select-String -Pattern:('(Process Name:)(.*?)(\n)')).Matches.Value.Replace('Process Name:','').Trim()
    }
}
```

#### Description

Running this command will return events generated for when the Logon Title is **SERVICE** when a logon session is created or if an account logon attempt failed when the account was already locked out.

The command returns:
```
Type          : Login Success
MachineName   : My-Windows-PC
TimeCreated   : 11/5/2020 08:01:55
ElevatedToken : Yes
AccountName   : My-Windows-PC$
ProcessName   : C:\Windows\System32\services.exe

Type          : Login Success
MachineName   : My-Windows-PC
TimeCreated   : 11/5/2020 08:14:59
ElevatedToken : Yes
AccountName   : My-Windows-PC$
ProcessName   : C:\Windows\System32\services.exe
```

For more details about these event records see:
* https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624
* https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4625

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/JkUu3'
```

![Windows - Get Service Account Logon Attempts](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Windows%20-%20Get%20Service%20Account%20Logon%20Attempts.png?raw=true)
