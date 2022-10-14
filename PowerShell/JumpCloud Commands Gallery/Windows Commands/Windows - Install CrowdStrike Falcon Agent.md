#### Name

Windows - Install CrowdStrike Falcon Agent | v2.0 JCCG

#### commandType

windows

#### Command

```powershell
$CSBaseAddress = ""
$CSClientID = ""
$CSClientSecret = ""

############### Do Not Edit Below This Line ###############
function Connect-CrowdStrike {
    param(
        [Parameter(Position = 1)]
        [ValidateSet('https://api.crowdstrike.com', 'https://api.us-2.crowdstrike.com',
            'https://api.eu-1.crowdstrike.com', 'https://api.laggar.gcw.crowdstrike.com')]
        [string] $CSBaseAddress,

        [Parameter(Position = 2)]
        [ValidatePattern('\w{32}')]
        [string] $CSClientId,

        [Parameter(Position = 3)]
        [ValidatePattern('\w{40}')]
        [string] $CSClientSecret
    )
    begin {
        $ApiBody = @{
            "client_id"     = $CSClientId
            "client_secret" = $CSClientSecret
        }
        $Headers = @{
            "Accept"       = "application/json";
            "Content-Type" = "application/x-www-form-urlencoded"
        }
        $global:CSBaseAddress = $CSBaseAddress
    }
    process {
        $Response = Invoke-WebRequest -Uri "$CSBaseAddress/oauth2/token" -Method Post -Headers $Headers -Body $ApiBody -UseBasicParsing

        if ($Response.headers."X-Ratelimit-Remaining" -le 0) {
            Write-Host "Too many requests are being made to CrowdStrike services..."
            exit 429
        }
        if ($Response.StatusCode -eq 201) {
            Write-Host "Successfully authenticated; Access Token created"
            $CrowdStrikeAccessToken = [regex]::Matches($Response.Content, '"(?<name>access_token)": "(?<access_token>.*)",')[0].Groups['access_token'].Value
            $global:CrowdStrikeAccessToken = $CrowdStrikeAccessToken
        }
    }
}
function Get-CrowdStrikeCcid {
    begin {
        $CrowdStrikeAuthHeader = @{
            "Authorization" = "bearer $CrowdStrikeAccessToken"
            "Accept"        = "application/json"
        }
    }
    process {
        $Response = Invoke-WebRequest -Uri "$CSBaseAddress/sensors/queries/installers/ccid/v1" -method Get -Headers $CrowdStrikeAuthHeader -UseBasicParsing

        if ($Response.headers."X-Ratelimit-Remaining" -le 0) {
            Write-Host "Too many requests are being made to CrowdStrike services..."
            exit 429
        }

        $Ccid = [regex]::Matches($Response, '(?<ccid>\w{32}-\w{2})')[0].Groups['ccid'].Value
    }
    end {
        return $Ccid
    }
}

function Get-CrowdStrikeSensorInstaller {
    param (
        [Parameter(Position = 1)]
        [ValidateSet('windows')]
        [string] $operatingSystem
    )
    begin {
        $CrowdStrikeAuthHeader = @{
            "Authorization" = "bearer $CrowdStrikeAccessToken"
            "Accept"        = "application/json"
        }
    }
    process {
        $Response = Invoke-WebRequest -Uri "$CSBaseAddress/sensors/combined/installers/v1" -method Get -Headers $CrowdStrikeAuthHeader -UseBasicParsing

        if ($Response.headers."X-Ratelimit-Remaining" -le 0) {
            Write-Host "Too many requests are being made to CrowdStrike services..."
            exit 429
        }

        $Installers = $Response.Content | ConvertFrom-Json
        $Installers = $Installers.Resources | Group-Object platform

        switch ($operatingSystem) {
            windows {
                $WindowsInstallers = $Installers | Where-Object Name -eq 'windows'
                $SortedInstallers = $WindowsInstallers.Group | Sort-Object release_date -Descending
            }
        }
        $LatestInstaller = $SortedInstallers | Select-Object -First 1
    }
    end {
        return $LatestInstaller
    }
}

try {
    Write-Host "Connecting to CrowdStrike Tenant..."
    Connect-CrowdStrike -CSBaseAddress $CSBaseAddress -CSClientId $CSClientId -CSClientSecret $CSClientSecret
} catch {
    Write-Error "Unable to connect to CrowdStrike..."
    exit 1
}

Write-Host "Gathering CCID information..."
$CID = Get-CrowdStrikeCcid

Write-Host "Finding latest Windows installer..."
$LatestInstaller = Get-CrowdStrikeSensorInstaller -operatingSystem 'windows'

$installerURL = "$CSBaseAddress/sensors/entities/download-installer/v1?id=$($LatestInstaller.sha256)"
$CrowdStrikeAuthHeader = @{
    "Authorization" = "bearer $CrowdStrikeAccessToken"
    "Accept"        = "application/octet-stream"
}

$installerTempLocation = "C:\Windows\Temp\CSFalconAgentInstaller.exe"

if (Get-Service "CSFalconService" -ErrorAction SilentlyContinue) {
    Write-Host "Falcon Agent already installed, nothing to do."
    exit 0
}
Write-Host "Falcon Agent not installed."

Write-Host "Downloading Falcon Agent installer now."
try {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Headers $CrowdStrikeAuthHeader -Uri $installerURL -UseBasicParsing -OutFile $installerTempLocation
} catch {
    Write-Error "Unable to download Falcon Agent installer."
    exit 1
}
Write-Host "Finished downloading Falcon Agent installer."

Write-Host "Installing Falcon Agent now, this may take a few minutes."
try {
    $args = @("/install", "/quiet", "/norestart", "CID=$CID")
    $installerProcess = Start-Process -FilePath $installerTempLocation -Wait -PassThru -ArgumentList $args
} catch {
    Write-Error "Failed to run Falcon Agent installer."
    exit 1
}
Write-Host "Falcon Agent installer returned $($installerProcess.ExitCode)."

exit $installerProcess.ExitCode

```

#### Description

This command will download and install the CrowdStrike Falcon Agent to the device if it isn't already installed. The command will leverage CrowdStrike's API to find and download the latest version of the Falcon Agent onto the local machine.

Follow the instructions from the [Installing the CrowdStrike Falcon Agent KB](https://support.jumpcloud.com/s/article/Installing-the-Crowdstrike-Falcon-Agent#InstallWindows)

In order to use this command:

1. Create a CrowdStrike API Client with the "SENSOR DOWNLOAD" Read scope and make note of the ClientID and ClientSecret Refer to CrowdStrike's article [Getting Access to the CrowdStrike API](https://www.crowdstrike.com/blog/tech-center/get-access-falcon-apis/) for further information
2. Set the 3 variables (CSBaseAddress, CSClientID, CSClientSecret) to their respective values for your CrowdStrike API Client
3. Extend the command timeout to a value that makes sense in your environment. The suggested command timeout for an environment with average network speeds on devices with average computing power is 10 minutes. Note that the command may timeout with a 124 error code in the command result window if not extended, but the script will continue to run.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Install%20CrowdStrike%20Falcon%20Agent.md"
```
