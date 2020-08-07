<#
.Synopsis
JumpCloud's System Insights feature provides admins with the ability to easily interrogate their
fleet of systems to find important pieces of information. Using this function you
can easily gather heightened levels of information from your fleet of JumpCloud managed
systems.
.Description
Using Get-JCSystemInsights will allow you to easily query JumpCloud's RESTful API to return information from your fleet of JumpCloud managed
systems.

.Example
PS C:\> Get-JCSystemInsights -Table:('App');

Get all Apps from systems with system insights enabled.

.Example
PS C:\> Get-JCSystemInsights -Table:('App') -SystemId:('5d66e0ac51db1e789bb17c77', '5e0e19831bc893319ae068b6');

Get all Apps from the specific systems.

.Example
PS C:\> Get-JCSystemInsights -Table:('App') -Filter:('system_id:eq:5d66e0ac51db1e789bb17c77', 'bundle_name:eq:storeuid');

Get systems that have a specific App on a specific system where the filter is multiple strings.

.Example
PS C:\> Get-JCSystemInsights -Table:('App') -Filter:('system_id:eq:5d66e0ac51db1e789bb17c77, bundle_name:eq:storeuid');

Get systems that have a specific App on a specific system where the filter is a string.

.Link
https://github.com/TheJumpCloud/support/wiki/Get-JCSystemInsights
#>
# Populate values for function parameters. "Dynamic ValidateSet"
$SystemInsightsPrefix = 'Get-JcSdkSystemInsight';
$SystemInsightsDataSet = [Ordered]@{}
Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$($SystemInsightsPrefix)*") | ForEach-Object {
    $Help = Get-Help -Name:($_.Name);
    $Table = $_.Name.Replace($SystemInsightsPrefix, '')
    $HelpDescription = $Help.Description.Text
    $FilterDescription = $Help.parameters.parameter.Where( { $_.Name -eq 'filter' }).Description.Text
    $FilterNames = ($HelpDescription | Select-String -Pattern:([Regex]'(?<=\ `)(.*?)(?=\`)') -AllMatches).Matches.Value
    $Operators = ($FilterDescription -Replace ('Supported operators are: ', '')).Trim()
    If ([System.String]::IsNullOrEmpty($HelpDescription) -or [System.String]::IsNullOrEmpty($FilterNames) -or [System.String]::IsNullOrEmpty($Operators))
    {
        Write-Error ('Get-JCSystemInsights parameter help info is missing.')
    }
    Else
    {
        $Filters = $FilterNames | ForEach-Object {
            $FilterName = $_
            $Operators | ForEach-Object {
                $Operator = $_
                ("'{0}:{1}:{2}'" -f $FilterName, $Operator, '[SearchValue <String>]');
            }
        }
        $SystemInsightsDataSet.Add($Table, $Filters )
    }
};
Register-ArgumentCompleter -CommandName Get-JCSystemInsights -ParameterName Table -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $FilterFilter = $fakeBoundParameter.Filter;
    $SystemInsightsDataSet.Keys | Where-Object { $_ -like "${wordToComplete}*" } | Where-Object { $SystemInsightsDataSet.$_ -like "${FilterFilter}*" } | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsights -ParameterName Filter -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $TypeFilter = $fakeBoundParameter.Table;
    $SystemInsightsDataSet.Keys | Where-Object { $_ -like "${TypeFilter}*" } | ForEach-Object { $SystemInsightsDataSet.$_ | Where-Object { $_ -like "${wordToComplete}*" } } | Sort-Object -Unique | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Function Get-JCSystemInsights
{
    [CmdletBinding(DefaultParameterSetName = 'List', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [System.String]
        # Name of the SystemInsights table to query.
        # See docs.jumpcloud.com for list of avalible table endpoints.
        $Table,

        [Parameter()]
        [System.String[]]
        [Alias('_id', 'id', 'system_id')]
        # Id of system to filter on.
        $SystemId,

        [Parameter()]
        [System.String[]]
        # Supported values and operators are specified for each table.
        # See docs.jumpcloud.com and search for specific table for a list of avalible filter options.
        # Use tab complete to see avalible filters.
        $Filter,

        [Parameter()]
        [System.String[]]
        # The comma separated fields used to sort the collection.
        # Default sort is ascending, prefix with `-` to sort descending.
        ${Sort},

        [Parameter(DontShow)]
        [System.Boolean]
        # Set to $true to return all results. This will overwrite any skip and limit parameter.
        $Paginate = $true
    )
    Begin
    {
        $CommandTemplate = "JumpCloud.SDK.V2\Get-JcSdkSystemInsight{0} @PSBoundParameters"
        $Results = @()
        If (-not [System.String]::IsNullOrEmpty($PSBoundParameters.Filter))
        {
            $PSBoundParameters.Filter = $PSBoundParameters.Filter -replace (', ', ',') -join ','
        }
        If (-not [System.String]::IsNullOrEmpty($PSBoundParameters.SystemId))
        {
            $SystemIdFilter = $PSBoundParameters.SystemId | ForEach-Object {
                $SystemIdFilterString = "system_id:eq:$($_)"
                If (-not [System.String]::IsNullOrEmpty($PSBoundParameters.Filter))
                {
                    "$($SystemIdFilterString),$($PSBoundParameters.Filter)"
                }
                Else
                {
                    $SystemIdFilterString
                }
            }
        }
        $PSBoundParameters.Remove('Table') | Out-Null
        $PSBoundParameters.Remove('SystemId') | Out-Null
    }
    Process
    {
        $Results = If (-not [System.String]::IsNullOrEmpty($SystemIdFilter))
        {
            $SystemIdFilter | ForEach-Object {
                $PSBoundParameters.Filter = $_
                Invoke-Expression -Command:($CommandTemplate -f $Table)
            }
        }
        Else
        {
            Invoke-Expression -Command:($CommandTemplate -f $Table)
        }
    }
    End
    {
        Return $Results
    }
}