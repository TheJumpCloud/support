# define the PSD1 path:
$psd1Path = "$PSScriptRoot/JumpCloud.Radius.psd1"
$logPath = "$PSScriptRoot/log.txt"
# define data file path:
$dataFilePath = "$PSScriptRoot/data/radiusMembers.json"
$certHashFilePath = "$PSScriptRoot/data/certHash.json"

Function Write-ToLog {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][Alias("LogContent")][string]$Message
        , [Parameter(Mandatory = $false)][Alias('LogPath')][string]$Path = "$logPath"
    )
    Begin {
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        If (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            New-Item $Path -Force -ItemType File
        }
        # check that the log file is not too large:
        $currentLog = get-item $path
        if ($currentLog.Length -ge 5000000) {
            # if log is larger than 5MB, rename the log to log.old.txt and create a new log file
            copy-item -path $path -destination "$path.old" -force
            New-Item $Path -Force -ItemType File
        }

    }
    process {
        Switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }
    }
    end {
        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
}

Write-ToLog -Message ('########### Begin Radius Deployment ###########')

Write-ToLog -Message ('Begin setting environment variables')
If (!(Test-Path "$PSScriptRoot/keyCert.encrypted")) {
    throw "The keyCert.encrypted file does not exist at path: $PSScriptRoot/keyCert.encrypted"
}
If (!(Test-Path "$PSScriptRoot/key.encrypted")) {
    throw "The key.encrypted file does not exist at path: $PSScriptRoot/key.encrypted"
}

$EncryptedCertData = Get-Content "$PSScriptRoot/keyCert.encrypted"
$env:certKeyPassword = $EncryptedCertData | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText
$EncryptedData = Get-Content "$PSScriptRoot/key.encrypted"
$env:JCAPIKEY = $EncryptedData | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText
# validate that the JumpCloud API key is set as an ENV var
if ( -not $env:certKeyPassword) {
    throw "the Cert Key Password is not set, please set the cert key password as an Env variable"
}
# validate API key
if ( -not $env:JCAPIKEY) {
    throw "the Api Key is not set, please set the API key as an Env variable"
} else {
    Write-ToLog -Message ("Connecting to JumpCloud Organization")
    import-module JumpCloud
    Connect-JCOnline -JumpCloudApiKey $env:JCAPIKEY -force
}

# Define list of Radius User Group IDs:
$radiusUserGroups = @(
    @{"US-Radius" = '5f3171a9232e1113939dd6a2' }
)

# For each group, update the config and
foreach ($radiusGroup in $radiusUserGroups) {
    <# $currentItemName is the current item #>
    Write-ToLog -Message ("Processing Radius User Group: $($radiusGroup.keys) | $($radiusGroup.values) ")
    Write-Warning "Processing Radius User Group: $($radiusGroup.keys) | $($radiusGroup.values) "
    # Update the userGroupID:
    Set-JCRConfig -userGroup $radiusGroup.values
    # remove the radius members data file:
    if (Test-Path -Path $dataFilePath) {
        Remove-Item $dataFilePath -Force
    }
    # remove the cert hash data file:
    if (Test-Path -Path $certHashFilePath) {
        Remove-Item $certHashFilePath -Force
    }
    # force import the radius module
    Import-Module "$psd1Path" -Force
    # this will generate a new user-to-association report and update the cached data of your radius group membership
    Write-ToLog -Message ("Begin updating global variables")
    Get-JCRGlobalVars -force *>> $logPath

    # # next generate user certificates for "new" users only — users who have not yet had a certificate generated
    Write-ToLog -Message ("Begin Certificate Generation")
    Start-GenerateUserCerts -type "New" *>> $logPath
    Write-ToLog -Message ("Finished Certificated Generation")

    # # Some users will have a cert already but it might be expiring soon, if those users are set to expire within 15 days, generate a new cert
    Write-ToLog -Message ("Begin Replacement of Certs Expiring Soon")
    Start-GenerateUserCerts -type ExpiringSoon -forceReplaceCerts *>> $logPath
    Write-ToLog -Message ("Finished Replacement of Certs Expiring Soon")

    Write-ToLog -Message ("Begin Certificate Deployment")
    # # distribute those new certificates
    Start-DeployUserCerts -type "New" -forceInvokeCommands *>> $logPath
    Write-ToLog -Message ("End Certificate Deployment")

    # # Write Report
    if (-Not (test-path -Path "$PSScriptRoot/reports/")) {
        New-Item -Path "$PSScriptRoot/" -ItemType Directory -Name reports
    }
    Write-ToLog -Message ("Begin Report Generation")
    Get-JCRCertReport -ExportFilePath "$PSScriptRoot/reports/$($radiusGroup.keys)_report.csv"
    Write-ToLog -Message ("End Report Generation")
}
Write-ToLog -Message ('########### End Radius Deployment ###########')
exit