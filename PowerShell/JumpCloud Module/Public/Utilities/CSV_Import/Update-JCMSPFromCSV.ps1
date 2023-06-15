Function Update-JCMSPFromCSV () {
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

        # import the CSV, it should already be validated with the parameter set
        $orgsToUpdate = Import-Csv -Path $CSVFilePath

        # Validate non-null name values
        $orgNameCheck = $orgsToUpdate | Where-Object { ($_.name -ne $Null) -and ($_.name -ne "") }

        if ($orgNameCheck.Count -gt 0) {
            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($orgNameCheck.name.Count) orgs"

            # get all orgs:
            $ExistingOrgCheck = Get-JCSdkOrganization
            # Check for orgs that do not exist:
            foreach ($Org in $orgNameCheck) {
                if ($ExistingOrgCheck.id -contains ($Org.id)) {
                    Write-Host "Organization: $($Org.Name) will be updated."
                } else {
                    Write-Host "Organization: $($Org.Name) with id: $($Org.id) does not exist on console.jumpcloud.com"
                    throw "Organization name: $($Org.Name) with id: $($Org.id) does not exist on console.jumpcloud.com"
                }
            }

            # check for duplicate orgs
            $orgDup = $orgNameCheck | Group-Object Name

            ForEach ($U in $orgDup) {
                if ($U.count -gt 1) {
                    Write-Host "Organization: $($U.Name) is duplicated in update file."
                    throw "Duplicate organization name: $($U.Name) in update file. organiztion name already exists."
                }
            }

            Write-Host "organiztion check complete"
        } else {
            Write-Host "no orgs to update"
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
    } # begin block end

    process {
        Write-Host $Banner -ForegroundColor Green
        Write-Host ""
        Write-host "Update Summary:"
        $orgNameCheck | Format-Table

        # PromptForChoice Args
        $Title = "Number Of Orgs To update: $NumberOfOrgs"
        $Prompt = "Would you like to update these orgs?"

        $Choices = @(
            [System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Begin updating the validated organizations")
            [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Do not update and exit")
        )
        $Default = 0

        # Prompt for the choice
        $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices, $Default)

        # Action based on the choice
        switch ($Choice) {
            0 {
                Write-Host ''
                Write-Host "Hang tight! Updating your organizations. " -NoNewline
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
                        Id             = $OrgUpdate.Id
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
                        $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/providers/$($ENV:JCProviderID)/organizations/$($OrgUpdate.id)" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body -ErrorVariable errMsg
                        # Add to result array
                        $ResultsArrayList.Add(
                            [PSCustomObject]@{
                                'name'           = $response.name
                                'maxSystemUsers' = $response.maxSystemUsers
                                'id'             = $response.id
                                'status'         = 'Updated'
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
                                'status'         = "Not Updated: $status"
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