Function Get-Hash()
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$URL,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$Method,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][string]$Key,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 3)][ValidateNotNullOrEmpty()][array]$Values,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateNotNullOrEmpty()][int]$Limit,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][string]$Body
    )
    $Values += $Key
    If ($Body)
    {
        $DataSet = Invoke-JCApi -Url:($URL) -Method:($Method) -Fields:($Values) -Paginate -Body:($Body)
    }
    Else
    {
        $DataSet = Invoke-JCApi -Url:($URL) -Method:($Method) -Fields:($Values) -Paginate
    }
    $Hashtable = New-Object System.Collections.Hashtable
    ForEach ($Item In $DataSet)
    {
        $Hashtable.Add($Item.$Key, $Item)
    }
    Return $Hashtable
}