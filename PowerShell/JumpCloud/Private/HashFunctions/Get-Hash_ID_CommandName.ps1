Function Get-Hash_ID_CommandName()
{

    $CommandHash = New-Object System.Collections.Hashtable

    $Commands = Get-JCCommand

        foreach ($Command in $Commands)
        {
            $CommandHash.Add($Command._id, $Command.name)

        }
    return $CommandHash
}