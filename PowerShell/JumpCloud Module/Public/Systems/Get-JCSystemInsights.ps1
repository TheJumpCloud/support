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
        [System.String[]]
        # Name of the SystemInsights table to query. See docs.jumpcloud.com for list of avalible table endpoints.
        $Table,

        [Parameter()]
        [System.String[]]
        # Supported values and operators are specified for each table. See docs.jumpcloud.com and search for specific talbe for a list of avalible filter options.
        ${Filter},

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
        $Results = @()
    }
    Process
    {
        $PSBoundParameters.Remove('Table') | Out-Null
        $Command = "JumpCloud.SDK.V2\Get-JcSdkSystemInsight$($Table) @PSBoundParameters"
        $Results = Invoke-Expression -Command:($Command)
    }
    End
    {
        Return $Results
    }
}