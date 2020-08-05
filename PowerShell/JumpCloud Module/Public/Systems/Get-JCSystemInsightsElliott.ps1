# Populate values for function parameters
$SystemInsightsPrefix = 'Get-JcSdkSystemInsight'
$SystemInsightsTables = @{}
$Commands = Get-Command -Module:('JumpCloud.SDK.V2') -Name:("$SystemInsightsPrefix*")
ForEach ($Command In $Commands)
{
    $Help = Get-Help -Name:($Command)
    $SystemInsightsTables.Add($Command.Name.Replace($SystemInsightsPrefix, ''), $Help.Description.Text + ' ' + $Help.parameters.parameter.Where( { $_.Name -eq 'filter' }).Description.Text + ' EX: {field}:{operator}:{searchValue}' )
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsightsElliott -ParameterName Table -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $FilterFilter = $fakeBoundParameter.Filter
    $SystemInsightsTables.Keys | Where-Object { $_ -like "${wordToComplete}*" } | Where-Object {
        $SystemInsightsTables.$_ -like "${FilterFilter}*"
    } | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Register-ArgumentCompleter -CommandName Get-JCSystemInsightsElliott -ParameterName Filter -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $TypeFilter = $fakeBoundParameter.Table
    $SystemInsightsTables.Keys | Where-Object { $_ -like "${TypeFilter}*" } | ForEach-Object { $SystemInsightsTables.$_ |
        Where-Object { $_ -like "${wordToComplete}*" } } |
    Sort-Object -Unique | ForEach-Object {
        New-Object System.Management.Automation.CompletionResult (
            $_,
            $_,
            'ParameterValue',
            $_
        )
    }
}
Function Get-JCSystemInsightsElliott
{
    [CmdletBinding(DefaultParameterSetName = 'List', PositionalBinding = $false)]
    Param(
        [Parameter(Mandatory)]
        [JumpCloud.SDK.V2.Category('Query')]
        [System.String[]]
        # Name of the SystemInsights table to query. See docs.jumpcloud.com for list of avalible table endpoints.
        $Table,

        [Parameter()]
        [JumpCloud.SDK.V2.Category('Query')]
        [System.String[]]
        # Supported operators are: eq
        ${Filter},

        [Parameter()]
        [JumpCloud.SDK.V2.Category('Query')]
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
        $Command = "JumpCloud.SDK.V2\Get-JcSdkSystemInsight$Table @PSBoundParameters"
        $Results = Invoke-Expression -Command:($Command)
    }
    End
    {
        Return $Results
    }
}