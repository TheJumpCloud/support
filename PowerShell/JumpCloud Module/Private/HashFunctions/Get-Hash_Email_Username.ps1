Function Get-Hash_Email_Username ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser -returnProperties email, username

    foreach ($User in $Users)
    {
        $UsersHash.Add($User.Email, $User.username)

    }
    return $UsersHash
}