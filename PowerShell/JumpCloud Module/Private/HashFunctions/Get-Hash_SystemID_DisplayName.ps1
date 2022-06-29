Function Get-Hash_SystemID_DisplayName ()
{
    begin {
        $SystemsHash = New-Object System.Collections.Hashtable

        
        $Systems = Get-JCSystem -returnProperties displayName

        foreach ($System in $Systems) {
                $SystemsHash.Add($System._id, $System.displayName)
        }

        return $SystemsHash
    }
}