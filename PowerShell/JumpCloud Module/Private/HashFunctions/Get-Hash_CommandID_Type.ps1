Function Get-Hash_CommandID_Type ()
{

    $CommandHash =  New-Object System.Collections.Hashtable

    $Commands = Get-JCCommand

        foreach ($Command in $Commands)
        {
            $CommandHash.Add($Command._id, $Command.commandType)
        }
    return $CommandHash
}