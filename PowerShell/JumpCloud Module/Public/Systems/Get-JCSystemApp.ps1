function Get-JCSystemApp () {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'The System Id of the system you want to search for applications')][ValidateNotNullorEmpty()]
        [string]$SystemID,
        [Parameter(Mandatory = $false , ValueFromPipelineByPropertyName, HelpMessage = 'The type (windows, macOS, linux) of the JumpCloud system you wish to search. Ex. (Windows, MacOS, Linux, Android))')]
        [ValidateSet('Windows', 'MacOS', 'Linux', 'Android')][ValidateNotNullorEmpty()]
        [string]$SystemOS,
        [Parameter(Mandatory = $false, HelpMessage = 'The name of the application you want to search for ex. (JumpCloud-Agent, Slack).' )][ValidateNotNullorEmpty()]
        [string]$name,
        [Parameter(Mandatory = $false, HelpMessage = 'The version of the application you want to search for ex. 1.1.2')][ValidateNotNullorEmpty()]
        [string]$version,
        [Parameter(Mandatory = $false, HelpMessage = 'The operator to use for the version search ex. equals, not_equals, contains, not_contains, starts_with, ends_with')]
        [ValidateSet('equals', 'not_equals', 'contains', 'not_contains', 'starts_with', 'ends_with')][ValidateNotNullorEmpty()]
        [string]$versionOperator = 'equals'
    )
    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
        $Parallel = $JCConfig.parallel.Calculated
        $resultsArrayList = New-Object -TypeName System.Collections.ArrayList
        $formattedResultsArray = New-Object -TypeName System.Collections.ArrayList
        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"

        $bodyTemplate = @{
            fields     = @{
                include = @(
                    'device.activation_lock_enabled'
                    'software.app_platform'
                    'software.installed_date'
                    'software.last_opened'
                    'software.name'
                    'software.vendor'
                    'software.version'
                    'device.display_name'
                    'device.hostname'
                    'device.id'
                    'device.os'
                )
            }
            sort       = @()
            filters    = @()
            pagination = @{
                offset   = 0
                pageSize = 500
            }
        }
    }
    process {
        if ($SystemID) {
            $bodyTemplate.filters += @{
                field     = 'device.id'
                operation = 'equals'
                value     = $SystemID
            }
        }
        if ($SystemOS) {
            $bodyTemplate.filters += @{
                field     = 'software.app_platform'
                operation = 'equals'
                value     = $SystemOS
            }
        }
        if ($name) {
            $bodyTemplate.filters += @{
                field     = 'software.name'
                operation = 'contains'
                value     = $name
            }
        }
        if ($version) {
            $bodyTemplate.filters += @{
                field     = 'software.version'
                operation = $versionOperator
                value     = $version
            }
        }
        # Need to manually paginate
        $body = $bodyTemplate | ConvertTo-Json -Depth 99
        $results = Get-JCResults -URL 'https://console.jumpcloud.com/api/v2/search/query' -method 'POST' -body $body -limit 500
        $resultsArrayList.AddRange($results)
        while ($results.Count -ge 500) {
            $bodyTemplate.pagination.offset += 500
            $body = $bodyTemplate | ConvertTo-Json -Depth 99
            $results = Get-JCResults -URL 'https://console.jumpcloud.com/api/v2/search/query' -method 'POST' -body $body -limit 500
            $resultsArrayList.AddRange($results)
        }

        # Format the results
        $resultsArrayList | ForEach-Object {
            $fieldValues = @{}
            if ($null -ne $_.fields) {
                if ($_.fields -is [System.Array]) {
                    foreach ($entry in $_.fields) {
                        if ($null -ne $entry.field) {
                            $fieldValues[$entry.field] = $entry.value
                        }
                    }
                } else {
                    foreach ($property in $_.fields.PSObject.Properties) {
                        $fieldValues[$property.Name] = $property.Value
                    }
                }
            } else {
                foreach ($property in $_.PSObject.Properties) {
                    $fieldValues[$property.Name] = $property.Value
                }
            }

            [void]$formattedResultsArray.Add([PSCustomObject]@{
                    SystemID              = $fieldValues['device.id']
                    SystemName            = $fieldValues['device.display_name']
                    Hostname              = $fieldValues['device.hostname']
                    SystemOS              = $fieldValues['device.os']
                    ApplicationPlatform   = $fieldValues['software.app_platform']
                    SoftwareName          = $fieldValues['software.name']
                    SoftwareVersion       = $fieldValues['software.version']
                    SoftwareVendor        = $fieldValues['software.vendor']
                    SoftwareInstalledDate = $fieldValues['software.installed_date']
                    SoftwareLastOpened    = $fieldValues['software.last_opened']
                })
        }
    }
    end {
        return $formattedResultsArray
    }
}