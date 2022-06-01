Function Get-Hash_SystemID_HostName ()
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName, HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )

    begin {
        $SystemsHash = New-Object System.Collections.Hashtable

        $URL = "{0}/api/search/systems" -f $JCUrlBasePath
        $Search = @{
            filter = @(
                @{}
            )
            fields = "hostname"
        }
        $SearchJSON = $Search | ConvertTo-Json -Compress -Depth 4

        if ($Parallel) {
            $SystemsObject = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1000 -parallel $true
        }
        else {
            $SystemsObject = Get-JCResults -Url $URL -method "POST" -body $SearchJSON -limit 1000
        }
        
        $SystemsObject | ForEach-Object {
            $SystemsHash.Add($_._id, $_.hostname)
        }

        return $SystemsHash
    }
}