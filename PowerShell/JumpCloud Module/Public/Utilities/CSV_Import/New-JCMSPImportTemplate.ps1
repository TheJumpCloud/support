Function New-JCMSPImportTemplate() {
    [CmdletBinding()]

    param
    (
        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'Parameter to force populate CSV with all headers when creating an update template. When selected this option will forcefully replace existing files in the current working directory. i.e. If you ',
            Mandatory = $false)]
        [Switch]
        $Force,
        [Parameter(ParameterSetName = 'force',
            HelpMessage = 'Type of CSV to Create. Update or Import are valid options.',
            Mandatory = $false)]
        [ValidateSet('Import', 'Update')]
        $Type
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
                                    CSV MSP Import Template
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
        if ($type -eq 'Import') {
            $ConfirmUpdateVsNew = 'N'
        } elseif ($type -eq 'Update') {
            $ConfirmUpdateVsNew = 'U'
        } Else {
            Write-Host "`nDo you want to create an import CSV template for creating new MSP orgs or updating exisitng MSP orgs?"
            Write-Host 'Enter "N" for to create a template for ' -NoNewline
            Write-Host -ForegroundColor Yellow 'new MSP orgs'
            Write-Host 'Enter "U" for creating a template for ' -NoNewline
            Write-Host -ForegroundColor Yellow "updating existing MSP orgs"


            while ($ConfirmUpdateVsNew -ne 'N' -and $ConfirmUpdateVsNew -ne 'U') {
                $ConfirmUpdateVsNew = Read-Host  "Enter N for 'new MSP orgs' or U for 'updating MSP orgs'"
            }
        }

        if ($ConfirmUpdateVsNew -eq 'U') {
            $CSV = New-Object System.Collections.ArrayList

            $fileName = 'JCMSPUpdateImport_' + $date + '.csv'
            Write-Debug $fileName

            if ($ConfirmUpdateVsNew -eq 'U') {
                ### Existing Orgs
                $orgHeaders = @{
                    "x-api-key" = $ENV:JCApiKey
                }
                $ExistingOrgs = New-Object System.Collections.ArrayList

                # paginate variables
                $skip = 0
                $limit = 10

                Do {
                    # get results
                    $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/organizations?limit=$($limit)&skip=$($skip)&sortIgnoreCase=settings.name&fields%5B0%5D=id&fields%5B1%5D=displayName&fields%5B2%5D=systemsCount&fields%5B3%5D=systemUsersCount&fields%5B4%5D=highWaterMarkLastMonth&fields%5B5%5D=entitlement&fields%5B6%5D=maxSystemUsers" -Method GET -Headers $orgHeaders

                    # add results to the ExistingOrgs
                    foreach ($item in $response.results) {
                        $ExistingOrgs.add($item) | Out-Null
                    }
                    $skip += $limit
                } until (($response.results.count -lt $limit))
                ###
                foreach ($Org in $ExistingOrgs.GetEnumerator()) {
                    $CSV.Add([pscustomobject]@{
                            Name           = $Org.displayName
                            maxSystemUsers = $org.maxSystemUsers
                            id             = $org.id
                        }) | Out-Null
                }
            }
            $fileName = 'JCMSPUpdateImport_' + $date + '.csv'
            Write-Debug $fileName
        } elseif ($ConfirmUpdateVsNew -eq 'N') {
            $CSV = New-Object System.Collections.ArrayList
            $CSV.Add( [PSCustomObject]@{
                    Name           = $null
                    maxSystemUsers = $null
                }) | Out-Null

            $fileName = 'JCMSPImport_' + $date + '.csv'
            Write-Debug $fileName
        }


    }
    end {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if ($PSCmdlet.ParameterSetName -eq 'force') {
            if (!$ExportPath ) {
                Write-Host ""
                $CSV | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file '  -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            } else {
                Write-Warning "The file $fileName already exists, overwriting..."
                $CSV | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file '  -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            }
        } Else {
            if (!$ExportPath ) {
                Write-Host ""
                $CSV | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file'  -NoNewline
                Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            } else {
                Write-Host ""
                Write-Warning "The file $fileName already exists do you want to overwrite it?" -WarningAction Inquire
                Write-Host ""
                $CSV | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file '  -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host "Do you want to open the file" -NoNewLine
            Write-Host " $FileName`?" -ForegroundColor Yellow

            while ($Open -ne 'Y' -and $Open -ne 'N') {
                $Open = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($Open -eq 'Y') {
                Invoke-Item -path "$ExportLocation/$FileName"

            }
            if ($Open -eq 'N') {
            }
        }
    }
}