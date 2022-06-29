Function Get-Hash_SystemID_HostName ()
{
    begin {
        $SystemsHash = New-Object System.Collections.Hashtable

        $Systems = Get-JCSystem -returnProperties hostname

        foreach ($System in $Systems) {
                $SystemsHash.Add($System._id, $System.hostname)
        }

        return $SystemsHash
    }
}