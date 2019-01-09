Function Invoke-JCApiGet
{ 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()][int]$Limit = 100
    )
    $Skip = 0
    $UriQueryString_Template = '{0}?limit={1}&skip={2}'
    $Results_Output = @()
    $PaginationExist = $true
    While ($PaginationExist)
    {
        $Uri = $UriQueryString_Template -f $Url, $Limit, $Skip
        Write-Debug ('Calling Uri: ' + $Uri)
        $Results = Invoke-RestMethod -Method:('GET') -Headers:($hdrs) -Uri:($Uri)
        If ($Results)
        {
            $Skip += $Results.Count
            $Results_Output += $Results
            If ($Results.Count -eq 1)
            {
                $PaginationExist = $false
            }
        }
        Else
        {
            $PaginationExist = $false
        }
    }
    If ($Results_Output)
    {
        Return $Results_Output
    }
}
