Function Update-JCDeviceFromCSV () {
    [CmdletBinding(DefaultParameterSetName = 'GUI')]
    param
    (
        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'GUI',
            HelpMessage = 'The full path to the CSV file you wish to import. You can use tab complete to search for .csv files.')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]
        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'force',
            HelpMessage = 'The full path to the CSV file you wish to import. You can use tab complete to search for .csv files.')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]
        [string]$CSVFilePath,
        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'A SwitchParameter which suppresses the GUI and data validation when using the Update-JCDeviceFromCSV command.')]
        [Switch]
        $force
    )
    begin {
        Write-Verbose "$($PSCmdlet.ParameterSetName)"
        $systems = Get-DynamicHash -Object System -returnProperties displayName
        if ($PSCmdlet.ParameterSetName -eq 'GUI') {
            Write-Verbose 'Verifying JCAPI Key'
            if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
                Connect-JCOnline
            }
            $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                                  Device Update
"@
            If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) {
                Clear-Host
            }
            Write-Host $Banner -ForegroundColor Green
            Write-Host ""
            $UpdateDevices = Import-Csv -Path $CSVFilePath
            $ResultsArrayList = New-Object System.Collections.ArrayList
            $NumberOfDevices = $UpdateDevices.deviceID.count
            $title = "Update Summary:"
            $menu = @"

    Number Of Devices To Update = $NumberOfDevices

    Would you like to update these Devices?

"@
            Write-Host $title -ForegroundColor Red
            Write-Host $menu -ForegroundColor Yellow
            while ($Confirm -ne 'Y' -and $Confirm -ne 'N') {
                $Confirm = Read-Host "Press Y to confirm or N to quit"
            }
            if ($Confirm -eq 'Y') {
                Write-Host ''
                Write-Host "Hang tight! Updating your Devices. " -NoNewline
                Write-Host "DO NOT shutdown the console." -ForegroundColor Red
                Write-Host ''
                Write-Host "It takes ~ 1 minute per 100 Devices."
            } elseif ($Confirm -eq 'N') {
                break
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'force') {
            $UpdateDevices = Import-Csv -Path $CSVFilePath
            $NumberOfDevices = $UpdateDevices.deviceId.count
            $ResultsArrayList = New-Object System.Collections.ArrayList
        }
    }
    process {
        [int]$ProgressCounter = 0
        foreach ($DeviceUpdate in $UpdateDevices) {
            $ProgressCounter++
            $GroupAddProgressParams = @{
                Activity        = "Updating $($DeviceUpdate.displayName)"
                Status          = "Device update $ProgressCounter of $NumberOfDevices"
                PercentComplete = ($ProgressCounter / $NumberOfDevices) * 100
            }
            Write-Progress @GroupAddProgressParams

            if ($DeviceUpdate.DeviceID -notin $systems.Keys) {
                throw "DeviceID: $($DeviceUpdate.DeviceID) does not exist in JumpCloud. Please validate that this device exists in JumpCloud"
            }

            # Get the names of the properties to keep. Exclude DeviceID and hostname
            $devicePropertiesToKeep = $DeviceUpdate.psobject.properties | Where-Object {
                $_.MemberType -eq "NoteProperty" -and $_.Name -ne "DeviceID" -and $_.Name -ne "hostname"
            } | Select-Object -ExpandProperty Name

            # Create a new PSCustomObject with only those properties
            $DeviceParams = $DeviceUpdate | Select-Object -Property $devicePropertiesToKeep
            $DeviceHash = @{}
            $DeviceParams.psobject.properties | ForEach-Object {
                if (($_.Value -eq '$true') -or ($_.Value -eq 'true')) {
                    $DeviceHash[$_.Name] = $true
                } elseif (($_.Value -eq '$false') -or ($_.Value -eq 'false')) {
                    $DeviceHash[$_.Name] = $false
                } elseif ($_.Value -eq "") {
                    return
                } else {
                    $DeviceHash[$_.Name] = $_.Value
                }
            }
            $UpdatedDevice = Set-JCSystem @DeviceHash -SystemID $DeviceUpdate.DeviceID
            $ResultsArrayList.Add($UpdatedDevice) | Out-Null
        }
    }
    end {
        return $ResultsArrayList
    }
}