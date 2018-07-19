Function Get-Hash_SystemID_DisplayName ()
{

    $SystemsHash =  New-Object System.Collections.Hashtable

    $Systems = Get-JCSystem -returnProperties displayName

        foreach ($System in $Systems)
        {
            $SystemsHash.Add($System._id, $System.DisplayName)

        }
    return $SystemsHash
}