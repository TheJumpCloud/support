Function Get-Hash_SystemGroupName_ID ()
{

    $UserSystemHash = New-Object System.Collections.Hashtable

    $UserSystems = Get-JCGroup -Type System

    foreach ($System in $UserSystems)
    {
        $UserSystemHash.Add($System.name, $System.id)
    }
    return $UserSystemHash
}