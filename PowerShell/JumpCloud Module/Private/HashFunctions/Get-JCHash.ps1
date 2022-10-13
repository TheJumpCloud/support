Function Get-JCHash() {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$Method,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][string]$Key,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][ValidateNotNullOrEmpty()][array]$Values = @(),
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateNotNullOrEmpty()][string]$Body = '',
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][int]$Limit = 100,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 6)][ValidateNotNullOrEmpty()][int]$Skip = 0
    )
    Begin {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process {
        # Add key to values
        If ($Values) { $Values += $Key }
        $DataSet = Invoke-JCApi -Url:($Url) -Method:($Method) -Fields:($Values) -Body:($Body) -Paginate:($true) -Limit:($Limit) -Skip:($Skip)
        #Convert $DataSet from Object to Hashtable with Object data as Values to make searchable
        $Hashtable = New-Object System.Collections.Hashtable
        ForEach ($Item In $DataSet) {
            $Hashtable.Add($Item.$Key, $Item)
        }
    }
    End {
        Return $Hashtable
    }
}