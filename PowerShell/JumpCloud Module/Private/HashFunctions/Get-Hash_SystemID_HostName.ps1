Function Get-Hash_SystemID_HostName ()
{

    $SystemsHash = New-Object System.Collections.Hashtable

    $Systems = Get-JCsystem -returnProperties hostname

    foreach ($System in $Systems)
    {
        $SystemsHash.Add($System._id, $System.HostName)

    }
    return $SystemsHash
}