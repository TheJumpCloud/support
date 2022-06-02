Function Get-Hash_ID_Sudo()
{
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName, HelpMessage = 'Boolean: $true to run in parallel, $false to run in sequential; Default value: false')]
        [Bool]$Parallel=$false
    )

    begin {

        $UsersHash = New-Object System.Collections.Hashtable

        if ($Parallel) {
            $Users = Get-JCUser -parallel $true -sudo $true -returnProperties sudo
        }
        else {
            $Users = Get-JCUser -sudo $true -returnProperties sudo
        }

        foreach ($User in $Users) {
                $UsersHash.Add($User._id, $User.sudo)
        }

        return $UsersHash
    }
}