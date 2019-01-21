Function Invoke-JCApiGet
{ 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()][int]$Limit = 100
    )
    $Skip = 0
    $UriQueryString_Template = '{0}{1}limit={2}&skip={3}'
    $Results_Output = @()
    $PaginationExist = $true
    If ($Url -like '*`?*')
    {
        $SearchOperator = '&'
    }
    Else
    {
        $SearchOperator = '?'
    }
    While ($PaginationExist)
    {
        $Uri = $UriQueryString_Template -f $Url, $SearchOperator, $Limit, $Skip
        Write-Debug ('Calling Uri: ' + $Uri)
        $Results = Invoke-RestMethod -Method:('GET') -Headers:($hdrs) -Uri:($Uri)
        If ($Results)
        {
            $Skip += $Results.Count
            $Results_Output += $Results
            If ($Results.Count -le 1)
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
