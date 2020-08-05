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