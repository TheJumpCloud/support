Function Get-Hash_CommandID_Name ()
{

    $CommandHash =  New-Object System.Collections.Hashtable

    $Commands = Get-JCCommand

        foreach ($Command in $Commands)
        {
            $CommandHash.Add($Command._id, $Command.name)
        }
    return $CommandHash
}