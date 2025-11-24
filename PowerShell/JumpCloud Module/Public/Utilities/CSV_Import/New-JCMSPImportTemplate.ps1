function New-JCMSPImportTemplate() {
    [CmdletBinding()]

    param
    (
        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'Parameter to force populate CSV with all headers when creating an update template. When selected this option will forcefully replace existing files in the current working directory.',
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
        Write-Verbose 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

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

            Write-Host $Banner -ForegroundColor Green
            Write-Host ""

            # PromptForChoice Args
            $Title = "The CSV template will be created in the current working directory: $PWD"
            $Prompt = "Would you like to specify a new path?"

            $Choices = @(
                [System.Management.Automation.Host.ChoiceDescription]::new("&Current directory: $PWD", "A CSV import template will be created in the current working directory")
                [System.Management.Automation.Host.ChoiceDescription]::new("&Specify a new directory", "Specify a directory in which to save the CSV import template.")
                [System.Management.Automation.Host.ChoiceDescription]::new("&Cancel", "Exit this prompt")
            )
            $Default = 0

            # Prompt for the choice
            $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

            # Action based on the choice
            switch ($Choice) {
                0 {
                    $ExportLocation = $PWD
                }
                1 {
                    $ExportLocation = Read-Host "Enter the full path to the folder you wish to create the import file in"

                    while (-not(Test-Path -Path $ExportLocation -PathType Container)) {
                        Write-Host "The location $ExportLocation does not exist. Try another"
                        $ExportLocation = Read-Host "Enter the full path to the folder you wish to create the import file in"

                    }
                    Write-Host ""
                    Write-Host "The CSV file will be created within the $ExportLocation directory"
                }
                2 {
                    break
                }
            }
        }
    }

    process {
        if ($type -eq 'Import') {
            $ConfirmUpdateVsNew = 'N'
        } elseif ($type -eq 'Update') {
            $ConfirmUpdateVsNew = 'U'
        } else {

            # PromptForChoice Args
            $Title = "Do you want to create an import CSV template for creating new MSP orgs or updating existing MSP orgs?"
            $Prompt = "Enter your choice"

            $Choices = @(
                [System.Management.Automation.Host.ChoiceDescription]::new("&New MSP Orgs", "Create template for importing new MSP Orgs")
                [System.Management.Automation.Host.ChoiceDescription]::new("&Update Existing MSP Orgs", "Get list of existing MSP Orgs and create template")
                [System.Management.Automation.Host.ChoiceDescription]::new("&Cancel", "Exit this prompt")
            )
            $Default = 1

            # Prompt for the choice
            $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

            # Action based on the choice
            switch ($Choice) {
                0 {
                    $ConfirmUpdateVsNew = 'N'
                }
                1 {
                    $ConfirmUpdateVsNew = 'U'
                }
                2 {
                    break
                }
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

                do {
                    # get results
                    $response = Invoke-RestMethod -Uri "$global:JCUrlBasePath/api/organizations?limit=$($limit)&skip=$($skip)&sortIgnoreCase=settings.name&fields%5B0%5D=id&fields%5B1%5D=displayName&fields%5B2%5D=systemsCount&fields%5B3%5D=systemUsersCount&fields%5B4%5D=highWaterMarkLastMonth&fields%5B5%5D=entitlement&fields%5B6%5D=maxSystemUsers" -Method GET -Headers $orgHeaders

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
                $CSV | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file ' -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            } else {
                Write-Warning "The file $fileName already exists, overwriting..."
                $CSV | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file ' -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            }
        } else {
            if (!$ExportPath ) {
                Write-Host ""
                $CSV | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file' -NoNewline
                Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            } else {
                Write-Host ""
                Write-Warning "The file $fileName already exists do you want to overwrite it?" -WarningAction Inquire
                Write-Host ""
                $CSV | Export-Csv -Path "$ExportLocation/$FileName" -NoTypeInformation
                Write-Host 'Creating file ' -NoNewline
                Write-Host $FileName -ForegroundColor Yellow -NoNewline
                Write-Host ' in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow
            }

            # PromptForChoice Args
            $Title = "Do you want to open the files?"
            $Prompt = "Enter Y to open the CSV, N to continue and exit"

            $Choices = @(
                [System.Management.Automation.Host.ChoiceDescription]::new("&Yes Open", "Opens the file in the defualt CSV editor")
                [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Continue and exit prompt")
            )
            $Default = 1

            # Prompt for the choice
            $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

            # Action based on the choice
            switch ($Choice) {
                0 {
                    Invoke-Item -Path "$ExportLocation/$FileName"
                }
                1 {
                    $ConfirmUpdateVsNew = 'U'
                    continue
                }
            }
        }
    }
}