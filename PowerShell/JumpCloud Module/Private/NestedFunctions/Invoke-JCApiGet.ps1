Function Invoke-JCApiGet
{ 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()][ValidateRange(1, [int]::MaxValue)][int]$Limit = 100
    )
    Begin
    {

        #Set JC headers
        Write-Verbose 'Verifying JCAPI Key'
        If ($JCAPIKEY.length -ne 40) {Connect-JCOnline}
        Write-Verbose 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }
        If ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }
    }
    Process
    {
        $Skip = 0
        $UriQueryString_Template = '{0}{1}limit={2}&skip={3}'
        $Results_Output = @()
        If ($Url -like '*`?*')
        {
            $SearchOperator = '&'
        }
        Else
        {
            $SearchOperator = '?'
        }
        Do
        {
            $Uri = $UriQueryString_Template -f $Url, $SearchOperator, $Limit, $Skip
            Write-Verbose ('Connecting to: ' + $Uri)
            $Results = Invoke-RestMethod -Method:('GET') -Headers:($hdrs) -Uri:($Uri)
            If ($Results)
            {
                $ResultsPopulated = $false
                If ($Results | Get-Member | Where-Object {$_.Name -eq 'results'})
                {
                    $ResultsCount = $Results.results.Count
                    If ($ResultsCount -gt 0)
                    {
                        $ResultObjects = $Results.results
                        $ResultsPopulated = $true
                    }
                }
                Else
                {
                    $ResultsCount = $Results.Count
                    $ResultObjects = $Results
                    $ResultsPopulated = $true
                }
                If ($ResultsPopulated)
                {
                    Write-Verbose ('Returned ' + [string]$ResultsCount + ' results.')
                    $Skip += $ResultsCount
                    $Results_Output += $ResultObjects
                }
            }
            Else
            {
                Write-Verbose ('No results found.')
            }
            # If ($Results) {Write-Host "Results are true" -BackgroundColor Cyan } Else {Write-Host "Results are false" -BackgroundColor red}
            # If ($ResultsCount -ge 1) {Write-Host ("Result count is greater than or equal to 1. Current count:" + [string]$ResultsCount ) -BackgroundColor Cyan} Else {Write-Host ("Result count is less than 1. Current count:" + [string]$ResultsCount ) -BackgroundColor red}
        }
        While ($ResultsCount -eq $Limit)
    }
    End
    {
        If ($Results_Output)
        {
            Return $Results_Output
        }
    }
}
