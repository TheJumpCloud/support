Function Import-JCMSPFromCSV () {
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
            HelpMessage = 'A SwitchParameter which suppresses the GUI and data validation when using the Update-JCMSPFromCSV command.')]
        [Switch]
        $force,

        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'Your Provider ID'
        )]
        [String]
        $ProviderID
    )
    begin {
        $ResultsArrayList = New-Object System.Collections.ArrayList
        Write-Verbose "$($PSCmdlet.ParameterSetName)"

        $orgsToUpdate = Import-Csv -Path $CSVFilePath

        # first validate:
        $orgNameCheck = $orgsToUpdate | Where-Object { ($_.name -ne $Null) -and ($_.name -ne "") }

        if ($orgNameCheck.Count -gt 0) {
            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($orgNameCheck.Name.Count) orgs"

            $ExistingorgNameCheck = Get-JCSdkOrganization

            foreach ($Org in $orgNameCheck) {
                if ($ExistingorgNameCheck.DisplayName -notcontains ($Org.Name)) {
                    Write-Host "Organization: $($Org.Name) will be imported."
                } elseif ($ExistingorgNameCheck.DisplayName -contains ($Org.Name)) {
                    Write-Host "Organization: $($Org.Name) already exists on console.jumpcloud.com"
                    throw "Duplicate organization name: $($Org.Name) already exists on console.jumpcloud.com"
                }
            }

            $orgDup = $orgNameCheck | Group-Object Name

            ForEach ($U in $orgDup) {
                if ($U.count -gt 1) {
                    Write-Host "Organization: $($U.Name) is duplicated in import file."
                    throw "Duplicate organization name: $($U.Name) in import file. organiztion name already exists."
                }
            }

            Write-Host "organiztion check complete"
        } else {
            Write-Host "no orgs to import"
        }

        $NumberOfOrgs = $orgsToUpdate.name.count

        if ($PSCmdlet.ParameterSetName -eq 'GUI') {

            Write-Verbose 'Verifying JCAPI Key'
            if ($JCAPIKEY.length -ne 40) {
                Connect-JCOnline
            }
            if (-Not $Env:JCProviderID) {
                $PID = Read-Host "Please enter your Provider ID"
                $Env:JCProviderID = $PID
            }

            $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                                  MSP Update
"@

            If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) {
                Clear-Host
            }
        }
    }
    process {
        Write-Host $Banner -ForegroundColor Green
        Write-Host ""
        Write-Host "Import Summary:"
        $orgNameCheck | Format-Table

        # only check non-null orgs in CSV
        # PromptForChoice Args
        $Title = "Number Of Orgs To import: $NumberOfOrgs"
        $Prompt = "Would you like to import these orgs?"

        $Choices = @(
            [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Begin importing the validated organizations")
            [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Do not import and exit")
        )
        $Default = 0

        # Prompt for the choice
        $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

        # Action based on the choice
        switch ($Choice) {
            0 {
                Write-Host ''
                Write-Host "Hang tight! Importing your organizations. " -NoNewline
                Write-Host "DO NOT shutdown the console." -ForegroundColor Red
                Write-Host ''
                Write-Host "It takes ~ 1 minute per 100 organizations."
                # Define headers
                $headers = @{
                    "x-api-key"    = $ENV:JCApiKey
                    "content-type" = "application/json"
                }

                [int]$ProgressCounter = 0
                foreach ($OrgUpdate in $orgsToUpdate) {
                    $ProgressCounter++
                    $ProgressParams = @{

                        Activity        = "Updating $($OrgUpdate.Name)"
                        Status          = "Org update $ProgressCounter of $NumberOfOrgs"
                        PercentComplete = ($ProgressCounter / $NumberOfOrgs) * 100

                    }

                    Write-Progress @ProgressParams
                    $UpdateParams = [PSCustomObject]@{
                        Name           = $OrgUpdate.Name
                        MaxSystemUsers = $OrgUpdate.MaxSystemUsers
                    }

                    # update body variable before calling api
                    $body = @{
                        name           = $OrgUpdate.Name
                        maxSystemUsers = [int]$OrgUpdate.MaxSystemUsers
                    } | ConvertTo-Json

                    # Clear the response variable if it exists:
                    if ($response) {
                        Clear-Variable -Name response
                    }
                    Try {
                        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/providers/$($ENV:JCProviderID)/organizations" -Method POST -Headers $headers -ContentType 'application/json' -Body $body -ErrorVariable errMsg
                        # Add to result array
                        $ResultsArrayList.Add(
                            [PSCustomObject]@{
                                'name'           = $response.name
                                'maxSystemUsers' = $response.maxSystemUsers
                                'id'             = $response.id
                                'status'         = 'Imported'
                            }) | Out-Null
                    } catch {
                        If ($errMsg.Message) {
                            $Status = $errMsg.Message
                        } elseif ($errMsg.ErrorDetails) {
                            $Status = $errMsg.ErrorDetails
                        }
                        # Add to result array
                        $ResultsArrayList.Add(
                            [PSCustomObject]@{
                                'name'           = $OrgUpdate.Name
                                'maxSystemUsers' = [int]$OrgUpdate.MaxSystemUsers
                                'id'             = $OrgUpdate.id
                                'status'         = 'Not Imported: ' + $Status
                            }) | Out-Null
                    }
                }
            }
            1 {
                break
            }
        }
    }
    end {
        return $ResultsArrayList
    }
}