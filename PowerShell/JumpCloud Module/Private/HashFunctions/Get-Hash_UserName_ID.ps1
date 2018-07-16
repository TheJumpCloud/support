Function Get-Hash_UserName_ID ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser -returnProperties username

    foreach ($User in $Users)
    {
        $UsersHash.Add($User.username, $User._id)

    }
    return $UsersHash
}