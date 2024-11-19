Function Remove-JCPolicy () {
    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0,
            HelpMessage = 'The PolicyID of the JumpCloud policy you wish to remove.')]
        [Alias('_id', 'id')]
        [String]$PolicyID,
        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Name',
            HelpMessage = 'The Name of the JumpCloud policy you wish to remove.')]
        [String]$Name,
        [Parameter(HelpMessage = 'A SwitchParameter which suppresses the warning message when removing a JumpCloud Policy.')]
        [Switch]
        $force
    )
    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }

        if ($PsCmdlet.ParameterSetName -eq "Name") {
            $policyHash = Get-JCPolicy | Select-Object Id, Name
        }

        $deletedArray = @()
    }
    process {
        switch ($PsCmdlet.ParameterSetName) {
            ByID {
                if (!$force) {
                    Write-Warning "Are you sure you wish to delete policy: $PolicyID ?" -WarningAction Inquire

                    try {
                        $removePolicy = Remove-JcSdkPolicy -Id $PolicyID -ErrorAction Stop
                        $Status = 'Deleted'
                    } catch {
                        $Status = $_.ErrorDetails
                    }

                    $FormattedResults = [PSCustomObject]@{
                        'Policy'  = $PolicyID
                        'Results' = $Status
                    }
                } else {
                    try {
                        $removePolicy = Remove-JcSdkPolicy -Id $PolicyID -ErrorAction Stop
                        $Status = 'Deleted'
                    } catch {
                        $Status = $_.ErrorDetails
                    }

                    $FormattedResults = [PSCustomObject]@{
                        'Policy'  = $PolicyID
                        'Results' = $Status
                    }
                }
                $deletedArray += $FormattedResults
            }
            Name {
                # Check if Policy exists with given name
                if ($policyHash.Name -ccontains ($Name)) {
                    $Policy = $policyHash | Where-Object Name -CEQ $Name
                } else {
                    throw "Policy does not exist. Run 'Get-JCPolicy | Select-Object Name' to see a list of all your JumpCloud policies"
                }

                if (!$force) {

                    Write-Warning "Are you sure you wish to delete policy: $Name ?" -WarningAction Inquire
                    try {
                        $removePolicy = Remove-JcSdkPolicy -Id $Policy.id -ErrorAction Stop
                        $Status = 'Deleted'
                    } catch {
                        $Status = $_.ErrorDetails
                    }
                    $FormattedResults = [PSCustomObject]@{
                        'Policy'  = $Policy.Name
                        'Results' = $Status
                    }
                } else {
                    try {
                        $removePolicy = Remove-JcSdkPolicy -Id $Policy.id -ErrorAction Stop
                        $Status = 'Deleted'
                    } catch {
                        $Status = $_.ErrorDetails
                    }
                    $FormattedResults = [PSCustomObject]@{
                        'Policy'  = $Policy.Name
                        'Results' = $Status
                    }
                }
                $deletedArray += $FormattedResults
            }
        }
    }
    end {
        return $deletedArray
    }
}