Function Get-Hash_UserGroupName_ID ()
{
    $UserGroupHash = New-Object System.Collections.Hashtable
    $UserGroups = Get-JCGroup -Type User
    foreach ($Group in $UserGroups)
    {
        If (-not $UserGroupHash.ContainsKey($Group.name))
        {
            $UserGroupHash.Add($Group.name, $Group.id)
        }
    }
    return $UserGroupHash
}