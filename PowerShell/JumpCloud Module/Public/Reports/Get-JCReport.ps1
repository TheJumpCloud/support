<#
.Synopsis
Ordered list of report metadata
.Description
Ordered list of report metadata
.Example
PS C:\> Get-JCReport

Returns a list of all available reports
.Example
PS C:\> Get-JCReport -Sort 'CREATED_AT'

Returns a list of all available reports, sorted by the most recently created report

.Outputs
JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem
.Link
https://github.com/TheJumpCloud/jcapi-powershell/tree/master/SDKs/PowerShell/JumpCloud.SDK.DirectoryInsights/docs/exports/Get-JcSdkReport.md
#>
Function Get-JCReport {
    [OutputType([JumpCloud.SDK.DirectoryInsights.Models.IGet200ApplicationJsonItemsItem])]
    [CmdletBinding(DefaultParameterSetName = 'List', PositionalBinding = $false)]
    Param(
        [Parameter()]
        [ArgumentCompleter([JumpCloud.SDK.DirectoryInsights.Support.Sort])]
        [JumpCloud.SDK.DirectoryInsights.Category('Query')]
        [JumpCloud.SDK.DirectoryInsights.Support.Sort]
        # Sort type and direction.
        # Default sort is descending, prefix with - to sort ascending.
        ${Sort},
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Report', HelpMessage = 'ID of the Report request.')]
        [String]$ReportID,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Report', HelpMessage = 'ID of the Artifact')]
        [String]$ArtifactID
    )
    Begin {
        Connect-JCOnline -force | Out-Null
        $Results = @()
        $headers = @{
            "accept"    = "application/json";
            "x-api-key" = $Env:JCApiKey;
            "x-org-id"  = $Env:JCOrgId
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            List {
                $Results = JumpCloud.SDK.DirectoryInsights\Get-JcSdkReport @PSBoundParameters
            }
            Report {
                $Results = Invoke-RestMethod -Uri "https://api.jumpcloud.com/insights/directory/v1/reports/$reportID/artifacts/$artifactID/content" -Method GET -Headers $headers
            }
        }
    }
    End {
        Return $Results
    }
}
