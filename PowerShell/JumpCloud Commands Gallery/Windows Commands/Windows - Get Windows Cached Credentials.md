#### Name

Windows - Get Windows Cached Credentials | v1.0 JCCG

#### commandType

windows

#### Command

```
function Test-ServiceForUserAccount {
    param (
        $StartName
    )

    if (-not $StartName) {
        $false
        return
    }

    $AccountName = $StartName.Trim().ToLower()

    if (-not $AccountName) {
        $false
        return
    }
    if ($AccountName -eq 'localsystem') {
        $false
        return
    }
    if ($AccountName.StartsWith('nt authority\')) {
        $false
        return
    }

    $true
}

function Write-ServiceInfos {
    param (
        [Parameter(ValueFromPipeline)]
        [object[]]
        $ServiceInfos
    )

    BEGIN {}

    PROCESS {
        foreach ($ServiceInfo in $ServiceInfos) {
            Write-Output('')
            Write-Output('    Name: ' + $ServiceInfo.Name)
            Write-Output('    PathName: ' + $ServiceInfo.PathName)
            Write-Output('    StartMode: ' + $ServiceInfo.StartMode)
            Write-Output('    State: ' + $ServiceInfo.State)
            Write-Output('    ProcessId: ' + $ServiceInfo.ProcessId)
            Write-Output('    StartName: ' + $ServiceInfo.StartName)
        }
    }
    END {}
}

function Test-TaskForUserAccount {
    param (
        $Principal
    )

    if (($Principal.LogonType -eq 'Password') -or ($Principal.LogonType -eq 'InteractiveOrPassword')) {

        if (!($Principal.userid) -or ($Principal.userid -eq "SYSTEM") -or ($Principal.userid -eq "LOCAL SERVICE") -or ($Principal.userid -eq "NETWORK SERVICE")) {
            $false
            return
        }

        $true
        return

    }

    $false
}

function Write-TaskInfos {
    param (
        [Parameter(ValueFromPipeline)]
        [object[]]
        $TaskInfos
    )

    BEGIN {}

    PROCESS {
        foreach ($TaskInfo in $TaskInfos) {
            Write-Output('')
            Write-Output('    TaskName: ' + $TaskInfo.TaskName)
            Write-Output('    UserId: ' + $TaskInfo.Principal.UserId)
            Write-Output('    LogonType: ' + $TaskInfo.Principal.LogonType)
            Write-Output('    Execute: ' + [System.IO.Path]::GetFileName([System.Environment]::ExpandEnvironmentVariables($TaskInfo.Actions.Execute).Trim('"')))
            Write-Output('    Arguments: ' + [System.Environment]::ExpandEnvironmentVariables($TaskInfo.Actions.Arguments))
        }
    }
    END {}
}

Write-Output('Services that run in a user account context:')
Get-WmiObject Win32_Service | Where { Test-ServiceForUserAccount($_.startname) } | Write-ServiceInfos

Write-Output('')
Write-Output('Scheduled tasks that run in a user account context:')
Get-ScheduledTask | Where { Test-TaskForUserAccount($_.Principal) } | Write-TaskInfos

& cmdkey.exe /list
```

#### Description

Executes a script to help identify Windows services, scheduled tasks, or third-party applications that use stored credentials and may potentially cause lockouts if the credentials get stale, usually after password changes.

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Get%20Windows%20Cached%20Credentials.md"
```
