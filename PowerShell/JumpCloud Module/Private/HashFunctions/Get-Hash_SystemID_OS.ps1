Function Get-Hash_SystemID_OS ()
{

    $SystemHash =  New-Object System.Collections.Hashtable

    $Systems = Get-JCSystem -returnProperties os

        foreach ($System in $Systems)
        {
            $SystemHash.Add($System._id, $System.os)
        }
        
    return $SystemHash
}