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
$SystemInsightsTables = [Ordered]@{};
$Commands = Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$($SystemInsightsPrefix)*");
$Commands | ForEach-Object {
    $Help = Get-Help -Name:($_.Name);
    $SystemInsightsTables.Add($_.Name.Replace($SystemInsightsPrefix, ''), $Help.Description.Text + ' ' + $Help.parameters.parameter.Where( { $_.Name -eq 'filter' }).Description.Text + ' EX: {field}:{operator}:{searchValue}' );
};
Register-ArgumentCompleter -CommandName Get-JCSystemInsights -ParameterName Table -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $FilterFilter = $fakeBoundParameter.Filter;
    $SystemInsightsTables.Keys | Where-Object { $_ -like "${wordToComplete}*" } | Where-Object { $SystemInsightsTables.$_ -like "${FilterFilter}*" } | ForEach-Object {
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
    $SystemInsightsTables.Keys | Where-Object { $_ -like "${TypeFilter}*" } | ForEach-Object { $SystemInsightsTables.$_ | Where-Object { $_ -like "${wordToComplete}*" } } | Sort-Object -Unique | ForEach-Object {
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
        # Name of the SystemInsights table to query. See docs.jumpcloud.com for list of avalible table endpoints.
        $Table,

        [Parameter()]
        [System.String[]]
        [Alias('_id', 'id', 'system_id')]
        # Id of system to filter on.
        $SystemId,

        [Parameter()]
        [System.String[]]
        # Supported values and operators are specified for each table. See docs.jumpcloud.com and search for specific talbe for a list of avalible filter options.
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