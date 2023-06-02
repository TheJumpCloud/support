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
        # $OrgUpdateParams = @{ }
        # $OrgUpdateParams.Add("Name", "Name")
        # $OrgUpdateParams.Add("maxSystemUsers", "maxSystemUsers")
        # $OrgUpdateParams.Add("provider_id", $ProviderID)
        # $OrgUpdateParams.Add("id", "id")
        $ResultsArrayList = New-Object System.Collections.ArrayList
        Write-Verbose "$($PSCmdlet.ParameterSetName)"

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
            Write-Host $Banner -ForegroundColor Green
            Write-Host ""

            $orgsToUpdate = Import-Csv -Path $CSVFilePath
            # only check non-null orgs in CSV
            $orgNameCheck = $orgsToUpdate | Where-Object { ($_.name -ne $Null) -and ($_.name -ne "") }

            if ($orgNameCheck.Count -gt 0) {
                Write-Host ""
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($orgNameCheck.name.Count) orgs"

                $ExistingorgNameCheck = Get-JCSdkOrganization
                # $ExistingorgNameCheck = Get-DynamicHash -Object User -returnProperties username, employeeIdentifier

                foreach ($Org in $orgNameCheck) {
                    if ($ExistingorgNameCheck.DisplayName -contains ($Org.name)) {
                        Write-Host "Organization: $($Org.Name) will be updated."
                    } else {
                        Write-Verbose "$($Org.Name) does not exist"
                    }
                }

                $orgDup = $orgNameCheck | Group-Object Name

                ForEach ($U in $orgDup) {
                    if ($U.count -gt 1) {

                        Write-Warning "Duplicate organization name: $($U.name) in import file. organiztion names must be unique."
                    }
                }

                Write-Host -BackgroundColor Green -ForegroundColor Black "organiztion check complete"
            }


            $NumberOfNewUsers = $orgsToUpdate.name.count

            $title = "Import Summary:"

            $menu = @"

    Number Of Orgs To Update = $NumberOfNewUsers

    Would you like to update these orgs?

"@
            Write-Host $title -ForegroundColor Red
            Write-Host $menu -ForegroundColor Yellow


            while ($Confirm -ne 'Y' -and $Confirm -ne 'N') {
                $Confirm = Read-Host "Press Y to confirm or N to quit"
            }

            if ($Confirm -eq 'Y') {

                Write-Host ''
                Write-Host "Hang tight! Updating your users. " -NoNewline
                Write-Host "DO NOT shutdown the console." -ForegroundColor Red
                Write-Host ''
                Write-Host "It takes ~ 1 minute per 100 users."

            }

            elseif ($Confirm -eq 'N') {
                break
            }
        }
    } #begin block end

    process {
        [int]$ProgressCounter = 0
        foreach ($OrgUpdate in $orgsToUpdate) {
            $ProgressCounter++
            $GroupAddProgressParams = @{

                Activity        = "Updating $($OrgUpdate.Name)"
                Status          = "Org update $ProgressCounter of $NumberOfNewUsers"
                PercentComplete = ($ProgressCounter / $NumberOfNewUsers) * 100

            }

            Write-Progress @GroupAddProgressParams
            Write-Host $OrgUpdate
            $UpdateParams = [PSCustomObject]@{
                Name           = $OrgUpdate.Name
                Id             = $OrgUpdate.Id
                MaxSystemUsers = $OrgUpdate.MaxSystemUsers
                # provider_id    = $Env:JCProviderID
            }
            # $UpdateParams.name = $OrgUpdate.Name
            # $UpdateParams.id = $OrgUpdate.id
            # $UpdateParams.provider_id = $OrgUpdate.provider_id
            # $UpdateParams.maxSystemUsers = $OrgUpdate.maxSystemUsers

            # try {
            $JSONParams = $UpdateParams | ConvertTo-Json

            Write-host "$($JSONParams)"

            $headers = @{}
            $headers.Add("x-api-key", $ENV:JCApiKey)
            $headers.Add("content-type", "application/json")
            $body = @{
                name           = $OrgUpdate.Name
                maxSystemUsers = [int]$OrgUpdate.MaxSystemUsers
            } | ConvertTo-Json
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/providers/$($ENV:JCProviderID)/organizations/$($OrgUpdate.id)" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body

            Write-Host $response
            # Set-JcSdkProviderOrganization -body $UpdateParams -providerID $Env:JCProviderID
            # $NewUser = Set-JCUser @UpdateParams

            # if ($NewUser._id) {

            #     $Status = 'User Updated'
            # }

            # elseif (-not $NewUser._id) {
            #     $Status = 'User does not exist'
            # }
            # $UpdateParams.maxSystemUsers = $upda/tedOrg.maxSystemUsers

            # } catch {
            #     # If ($_.ErrorDetails) {
            #     #     $Status = $_.ErrorDetails
            #     # } elseif ($_.Exception) {
            #     #     $Status = $_.Exception.Message
            #     # }

            #     # if (-not (Get-JCUser -username $UpdateParams.username -returnProperties username)) {
            #     #     $Status = 'User does not exist'
            #     # }
            # }
            $ResultsArrayList.Add($UpdateParams) | Out-Null
        }
    }
    end {
        return $ResultsArrayList
    }
}