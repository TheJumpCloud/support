Function New-JCDeviceUpdateTemplate {
    [CmdletBinding()]

    param
    (
        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'Parameter to force populate CSV with all headers when creating an update template. When selected this option will forcefully replace existing files in the current working directory',
            Mandatory = $false)]
        [Switch]
        $Force
    )

    begin {
        $date = Get-Date -Format MM-dd-yyyy
        if ($PSCmdlet.ParameterSetName -eq 'force') {
            $ExportLocation = $PWD
        } else {

            $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                    CSV Device Import Template
"@

            $Heading2 = 'The CSV file will be created within the directory:'

            If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) {
                Clear-Host
            }

            Write-Host $Banner -ForegroundColor Green
            Write-Host "`n$Heading2`n"
            Write-Host " $PWD" -ForegroundColor Yellow
            Write-Host ""


            while ($ConfirmFile -ne 'Y' -and $ConfirmFile -ne 'N') {
                $ConfirmFile = Read-Host  "Enter Y to confirm or N to change output location" #Confirm .csv file location creation
            }

            if ($ConfirmFile -eq 'Y') {

                $ExportLocation = $PWD
            }

            elseif ($ConfirmFile -eq 'N') {
                $ExportLocation = Read-Host "Enter the full path to the folder you wish to create the import file in"

                while (-not(Test-Path -Path $ExportLocation -PathType Container)) {
                    Write-Host -BackgroundColor Yellow -ForegroundColor Red "The location $ExportLocation does not exist. Try another"
                    $ExportLocation = Read-Host "Enter the full path to the folder you wish to create the import file in"

                }
                Write-Host ""
                Write-Host -BackgroundColor Green -ForegroundColor Black "The CSV file will be created within the $ExportLocation directory"
                Pause

            }
        }
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'force') {
            $CSV = [ordered]@{
                DeviceID                       = $null
                displayName                    = $null
                hostname                       = $null
                description                    = $null
                allowSshPasswordAuthentication = $null
                allowSshRootLogin              = $null
                allowMultiFactorAuthentication = $null
                allowPublicKeyAuthentication   = $null
                systemInsights                 = $null
                primarySystemUser              = $null

            }
            $fileName = 'JCDeviceUpdateImport_' + $date + '.csv'
            Write-Debug $fileName
            $CSVheader = New-Object psobject -Property $Csv
            $systems = Get-DynamicHash -Object System -returnProperties displayName, description, allowSshPasswordAuthentication, allowSshRootLogin, allowMultiFactorAuthentication, allowPublicKeyAuthentication, systemInsights, hostname
            $CSVheader = @()
            foreach ($System in $Systems.GetEnumerator()) {
                $CSVDeviceUpdate = $CSV
                $CSVDeviceUpdate.DeviceID = $System.Key
                $CSVDeviceUpdate.displayName = $System.value.displayname
                $CSVDeviceUpdate.hostname = $System.value.hostname
                $SystemObject = New-Object psobject -Property $CSVDeviceUpdate
                $CSVheader += $SystemObject
            }
        } else {
            $fileName = 'JCDeviceUpdateImport_' + $date + '.csv'
            Write-Debug $fileName

            $CSV = [ordered]@{
                DeviceID    = $null
                displayname = $null
                hostname    = $null
            }

            Write-Host "`nWould you like to populate this update template with all of your existing systems?"
            Write-Host -ForegroundColor Yellow 'You can remove systems you do not wish to modify from the import file after it is created.'


            while ($ConfirmDevicePop -ne 'Y' -and $ConfirmDevicePop -ne 'N') {
                $ConfirmDevicePop = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmDevicePop -eq 'Y') {
                Write-Verbose 'Verifying JCAPI Key'
                if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
                    Connect-JCOnline
                }
                $systems = Get-DynamicHash -Object System -returnProperties displayName, description, allowSshPasswordAuthentication, allowSshRootLogin, allowMultiFactorAuthentication, allowPublicKeyAuthentication, systemInsights, hostname
            }

            elseif ($ConfirmDevicePop -eq 'N') {
            }


            Write-Host "`nWould you like to update device descriptions?"

            while ($ConfirmDeviceDescription -ne 'Y' -and $ConfirmDeviceDescription -ne 'N') {
                $ConfirmDeviceDescription = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmDeviceDescription -eq 'Y') {
                $CSV.add('description', $null)
            }

            elseif ($ConfirmDeviceDescription -eq 'N') {
            }

            Write-Host "`nWould you like to update allowing SSH Password Authentication?"

            while ($ConfirmSshPasswordAuth -ne 'Y' -and $ConfirmSshPasswordAuth -ne 'N') {
                $ConfirmSshPasswordAuth = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmSshPasswordAuth -eq 'Y') {
                $CSV.add('allowSshPasswordAuthentication', $null)
            }

            elseif ($ConfirmSshPasswordAuth -eq 'N') {
            }

            Write-Host "`nWould you like to update allowing SSH Root Login?"

            while ($ConfirmSshRootLogin -ne 'Y' -and $ConfirmSshRootLogin -ne 'N') {
                $ConfirmSshRootLogin = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmSshRootLogin -eq 'Y') {
                $CSV.add('allowSshRootLogin', $null)
            }

            elseif ($ConfirmSshRootLogin -eq 'N') {
            }

            Write-Host "`nWould you like to update allowing MFA?"

            while ($ConfirmMFA -ne 'Y' -and $ConfirmMFA -ne 'N') {
                $ConfirmMFA = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmMFA -eq 'Y') {
                $CSV.add('allowMultiFactorAuthentication', $null)
            }

            elseif ($ConfirmMFA -eq 'N') {
            }

            Write-Host "`nWould you like to update allowing Public Key Authentication?"

            while ($ConfirmPublicKeyAuth -ne 'Y' -and $ConfirmPublicKeyAuth -ne 'N') {
                $ConfirmPublicKeyAuth = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmPublicKeyAuth -eq 'Y') {
                $CSV.add('allowPublicKeyAuthentication', $null)
            }

            elseif ($ConfirmPublicKeyAuth -eq 'N') {
            }

            Write-Host "`nWould you like to update enabling System Insights?"

            while ($ConfirmSystemInsights -ne 'Y' -and $ConfirmSystemInsights -ne 'N') {
                $ConfirmSystemInsights = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmSystemInsights -eq 'Y') {
                $CSV.add('systemInsights', $null)
            }

            elseif ($ConfirmSystemInsights -eq 'N') {
            }

            Write-Host "`nWould you like to set a primary system user?"

            while ($ConfirmPrimarySystemUser -ne 'Y' -and $ConfirmPrimarySystemUser -ne 'N') {
                $ConfirmPrimarySystemUser = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmPrimarySystemUser -eq 'Y') {
                $CSV.add('primarySystemUser', $null)
            }

            elseif ($ConfirmPrimarySystemUser -eq 'N') {
            }

            $CSVheader = New-Object psobject -Property $Csv

            if ($systems) {
                $CSVheader = @()

                foreach ($System in $Systems.GetEnumerator()) {
                    $CSVDeviceUpdate = $CSV
                    $CSVDeviceUpdate.DeviceID = $System.Key
                    $CSVDeviceUpdate.displayName = $System.value.displayname
                    $CSVDeviceUpdate.hostname = $System.value.hostname
                    $SystemObject = New-Object psobject -Property $CSVDeviceUpdate
                    $CSVheader += $SystemObject
                }
            }
        }
    }
    end {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if ($PSCmdlet.ParameterSetName -eq 'force') {
            if (!$ExportPath ) {
                Write-Host ""
                $CSVheader | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file '  -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            } else {
                Write-Warning "The file $fileName already exists, overwriting..."
                $CSVheader | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file '  -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            }
        } Else {
            if (!$ExportPath ) {
                Write-Host ""
                $CSVheader | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file'  -NoNewline
                Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            } else {
                Write-Host ""
                Write-Warning "The file $fileName already exists do you want to overwrite it?" -WarningAction Inquire
                Write-Host ""
                $CSVheader | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file '  -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host "Do you want to open the file" -NoNewline
            Write-Host " $FileName`?" -ForegroundColor Yellow

            while ($Open -ne 'Y' -and $Open -ne 'N') {
                $Open = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($Open -eq 'Y') {
                Invoke-Item -Path "$ExportLocation/$FileName"

            }
            if ($Open -eq 'N') {
            }
        }
    }
}