Function Get-Hash_SystemID_HostName ()
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName, HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )

    begin {
        $SystemsHash = New-Object System.Collections.Hashtable

        if ($Parallel) {
            $Systems = Get-JCSystem -parallel $true -returnProperties hostname
        }
        else {
            $Systems = Get-JCSystem -returnProperties hostname
        }

        foreach ($System in $Systems) {
                $SystemsHash.Add($System._id, $System.hostname)
        }

        return $SystemsHash
    }
}