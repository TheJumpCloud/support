Function Get-Hash_Email_ID ()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser -returnProperties email

    foreach ($User in $Users)
    {
        $UsersHash.Add($User.Email, $User._id)

    }
    return $UsersHash
}