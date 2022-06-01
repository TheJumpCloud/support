Function Get-Hash_ID_Sudo()
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName, HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )

    begin {

        $UsersHash = New-Object System.Collections.Hashtable

        $URL = "{0}/api/search/systemusers" -f $JCUrlBasePath
        $Search = @{
            filter = @(
                @{"sudo"=$true}
            )
            fields = "sudo"
        }
        $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

        if ($Parallel) {
            $UsersObject = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1000 -parallel $true
        }
        else {
            $UsersObject = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1000
        }
        
        $UsersObject | ForEach-Object {
            $UsersHash.Add($_._id, $_.sudo)
        }

        return $UsersHash
    }
}