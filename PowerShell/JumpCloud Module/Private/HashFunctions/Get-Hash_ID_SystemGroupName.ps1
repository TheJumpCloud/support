Function Get-Hash_ID_SystemGroupName ()
{

    $SystemGroupHash =  New-Object System.Collections.Hashtable

    $SystemGroups = Get-JCGroup -Type System

        foreach ($SystemGroup in $SystemGroups)
        {
            $SystemGroupHash.Add($SystemGroup.id, $SystemGroup.name)
        }
    return $SystemGroupHash
}