Function Get-Hash_ID_Username ()
{
    begin {

        $UsersHash = New-Object System.Collections.Hashtable

        $Users = Get-JCUser -returnProperties username
        
        foreach ($User in $Users) {
                $UsersHash.Add($User._id, $User.username)
        }

        return $UsersHash
    }
}