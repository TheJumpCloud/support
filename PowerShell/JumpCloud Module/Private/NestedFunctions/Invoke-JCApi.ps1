Function Invoke-JCApi
{ 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$Method,
        [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()][ValidateRange(1, [int]::MaxValue)][int]$Limit = 100,
        [Parameter(Mandatory = $false, Position = 3)][ValidateNotNullOrEmpty()][array]$Fields = '',
        [Parameter(Mandatory = $false, Position = 4)][ValidateNotNullOrEmpty()][string]$Body = '',
        [Parameter(Mandatory = $false, Position = 5)][ValidateNotNullOrEmpty()][switch]$Paginate
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
        $UriQueryString_Template = '{0}{1}limit={2}&skip={3}&fields={4}'
        $Results_Output = @()
        If ($Url -notlike ('*' + $JCUrlBasePath + '*'))
        {
            $Url = $JCUrlBasePath + $Url
        }
        If ($Url -like '*`?*')
        {
            $SearchOperator = '&'
        }
        Else
        {
            $SearchOperator = '?'
        }
        $JoinedFields = ($Fields -join ' ')
        Do
        {
            # Build body to include skip and limit by default plus what ever else is passed in.
            If ($Body)
            {
                $ObjectBody = $Body | ConvertFrom-Json
            }
            Else
            {
                $ObjectBody = ''
            }
            If ($ObjectBody.PSObject.Properties.name -eq 'skip')
            {
                $ObjectBody.skip = $Skip
            }
            Else
            {
                $ObjectBody = $ObjectBody | Select-Object @{Name = 'skip'; Expression = {$Skip}}, *
            }
            If (!($ObjectBody.PSObject.Properties.name -eq 'limit'))
            {
                $ObjectBody = $ObjectBody | Select-Object @{Name = 'limit'; Expression = {$Limit}}, *
            }
            If (!($ObjectBody.PSObject.Properties.name -eq 'fields'))
            {
                $ObjectBody = $ObjectBody | Select-Object @{Name = 'fields'; Expression = {$JoinedFields}}, *
            }
            $ObjectBody = $ObjectBody | Select-Object -Property * -ExcludeProperty Length
            $Body = $ObjectBody | ConvertTo-Json -Depth:(10) -Compress

            # Build url and query string
            $Uri = $UriQueryString_Template -f $Url, $SearchOperator, $Limit, $Skip, $JoinedFields
            Write-Verbose ('Connecting to: ' + $Uri)
            Write-Verbose ('Sending body: ' + $Body)
            $Results = Invoke-RestMethod -Method:($Method) -Headers:($hdrs) -Uri:($Uri) -Body:($Body)
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
        While ($Paginate -and $ResultsCount -eq $Limit)
    }
    End
    {
        If ($Results_Output)
        {
            Return $Results_Output
        }
    }
}
