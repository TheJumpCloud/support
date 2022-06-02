Function Get-Hash_ID_Username ()
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName, HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )

    begin {

        $UsersHash = New-Object System.Collections.Hashtable

        if ($Parallel) {
            $Users = Get-JCUser -parallel $true -returnProperties username
        }
        else {
            $Users = Get-JCUser -returnProperties username
        }

        foreach ($User in $Users) {
                $UsersHash.Add($User._id, $User.username)
        }

        return $UsersHash
    }
}