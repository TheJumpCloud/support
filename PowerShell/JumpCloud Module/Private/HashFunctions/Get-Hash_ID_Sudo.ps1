Function Get-Hash_ID_Sudo()
{

    $UsersHash = New-Object System.Collections.Hashtable

    $Users = Get-JCUser -sudo $true -returnProperties sudo

    foreach ($User in $Users)
    {
        $UsersHash.Add($User._id, $User.sudo)

    }
    return $UsersHash
}