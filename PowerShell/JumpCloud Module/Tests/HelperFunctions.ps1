Function New-RandomString ()
{
    [CmdletBinding()]

    param(

        [Parameter(Mandatory)] ##Test this to see if this can be modified.
        [ValidateRange(0, 52)]
        [Int]
        $NumberOfChars

    )
    begin { }
    process
    {
        $Random = -join ((65..90) + (97..122) | Get-Random -Count $NumberOfChars | ForEach-Object { [char]$_ })
    }
    end { Return $Random }


}
Function New-RandomUser  ()
{
    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [String]
        $Domain,

        [Parameter(ParameterSetName = 'Attributes')] ##Test this to see if this can be modified.
        [switch]
        $Attributes

    )

    if (($PSCmdlet.ParameterSetName -eq 'NoAttributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
        $email = $username + "@$Domain.com"

        $RandomUser = [ordered]@{
            FirstName = 'Pester'
            LastName  = 'Test'
            Username  = $username
            Email     = $email
            Password  = 'Temp123!'
        }

        $NewRandomUser = New-Object PSObject -Property $RandomUser
    }

    if (($PSCmdlet.ParameterSetName -eq 'Attributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
        $email = $username + "@$Domain.com"

        $RandomUser = [ordered]@{
            FirstName                = 'Pester'
            LastName                 = 'Test'
            Username                 = $username
            Email                    = $email
            Password                 = 'Temp123!'
            NumberOfCustomAttributes = 3
            Attribute1_name          = 'Department'
            Attribute1_value         = 'Sales'
            Attribute2_name          = 'Office'
            Attribute2_value         = '456789'
            Attribute3_name          = 'Lang'
            Attribute3_value         = 'French'
        }
        $NewRandomUser = New-Object PSObject -Property $RandomUser
    }


    return $NewRandomUser
}
Function New-RandomUserCustom  ()
{
    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [String]
        $Domain,

        [Parameter(ParameterSetName = 'Attributes')] ##Test this to see if this can be modified.
        [switch]
        $Attributes

    )

    if (($PSCmdlet.ParameterSetName -eq 'NoAttributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
        $email = $username + "@$Domain.com"

        $RandomUser = [ordered]@{
            FirstName = 'Pester'
            LastName  = 'Test'
            Username  = $username
            Email     = $email
            Password  = 'Temp123!'
        }

        $NewRandomUser = New-Object PSObject -Property $RandomUser
    }

    if (($PSCmdlet.ParameterSetName -eq 'Attributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
        $email = $username + "@$Domain.com"

        $RandomUser = [ordered]@{
            FirstName                = 'Pester'
            LastName                 = 'Test'
            Username                 = $username
            Email                    = $email
            Password                 = 'Temp123!'
            NumberOfCustomAttributes = 3
            Attribute1_name          = 'Department'
            Attribute1_value         = 'Sales'
            Attribute2_name          = 'Office'
            Attribute2_value         = '456789'
            Attribute3_name          = 'Lang'
            Attribute3_value         = 'French'
        }
        $NewRandomUser = New-Object PSObject -Property $RandomUser
    }


    return $NewRandomUser
}
Function New-RandomStringLower ()
{
    [CmdletBinding()]
    param(

        [Parameter()]
        [ValidateRange(0, 52)]
        [Int]
        $NumberOfChars = 8

    )
    begin { }
    process
    {
        $Random = -join ((65..90) + (97..122) | Get-Random -Count $NumberOfChars | ForEach-Object { [char]$_ })
    }
    end { Return $Random.ToLower() }
}
Function Connect-JCOnlineTest ()
{
    Connect-JCOnline -JumpCloudAPIKey $TestOrgAPIKey -force
}
Function Connect-JCOnlineMultiTenant ($JumpCloudOrgID)
{
    Connect-JCOnline -JumpCloudAPIKey $MultiTenantAPIKey -force -JumpCloudOrgID $JumpCloudOrgID
}