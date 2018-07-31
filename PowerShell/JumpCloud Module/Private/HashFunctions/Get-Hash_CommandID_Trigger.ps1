Function Get-Hash_CommandID_Trigger ()
{

    $CommandHash =  New-Object System.Collections.Hashtable

    $Commands = Get-JCCommand

        foreach ($Command in $Commands)
        {
            $CommandHash.Add($Command._id, $Command.trigger)
        }
    return $CommandHash
}