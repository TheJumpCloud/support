Function Get-Hash_employeeIdentifier_username ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser -returnProperties username, employeeIdentifier

    foreach ($User in $Users)
    {
        if ($User.employeeIdentifier -ne $null)
        {
            $UsersHash.Add($User.employeeIdentifier, $User.username )
        }
        

    }
    return $UsersHash
}