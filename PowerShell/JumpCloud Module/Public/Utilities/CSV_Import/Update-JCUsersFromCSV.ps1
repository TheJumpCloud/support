Function Update-JCUsersFromCSV ()
{
    [CmdletBinding(DefaultParameterSetName = 'GUI')]
    param
    (
        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'GUI')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]

        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'force')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]

        [string]$CSVFilePath,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force


    )

    begin
    {
        $UserUpdateParams = @{ }
        $UserUpdateParams.Add("Username", "Username")
        $UserUpdateParams.Add("FirstName", "FirstName")
        $UserUpdateParams.Add("LastName", "LastName")
        $UserUpdateParams.Add("Email", "Email")
        $UserUpdateParams.Add("Password", "Password")
        $UserUpdateParams.Add("middlename", "middlename")
        $UserUpdateParams.Add("preferredName", "preferredName")
        $UserUpdateParams.Add("jobTitle", "jobTitle")
        $UserUpdateParams.Add("employeeIdentifier", "employeeIdentifier")
        $UserUpdateParams.Add("department", "department")
        $UserUpdateParams.Add("costCenter", "costCenter")
        $UserUpdateParams.Add("company", "company")
        $UserUpdateParams.Add("employeeType", "employeeType")
        $UserUpdateParams.Add("description", "description")
        $UserUpdateParams.Add("location", "location")
        $UserUpdateParams.Add("work_streetAddress", "work_streetAddress")
        $UserUpdateParams.Add("work_poBox", "work_poBox")
        $UserUpdateParams.Add("work_locality", "work_locality")
        $UserUpdateParams.Add("work_region", "work_region")
        $UserUpdateParams.Add("work_city", "work_city")
        $UserUpdateParams.Add("work_state", "work_state")
        $UserUpdateParams.Add("work_postalCode", "work_postalCode")
        $UserUpdateParams.Add("work_country", "work_country")
        $UserUpdateParams.Add("home_poBox", "home_poBox")
        $UserUpdateParams.Add("home_locality", "home_locality")
        $UserUpdateParams.Add("home_region", "home_region")
        $UserUpdateParams.Add("home_city", "home_city")
        $UserUpdateParams.Add("home_state", "home_state")
        $UserUpdateParams.Add("home_postalCode", "home_postalCode")
        $UserUpdateParams.Add("home_country", "home_country")
        $UserUpdateParams.Add("home_streetAddress", "home_streetAddress")
        $UserUpdateParams.Add("mobile_number", "mobile_number")
        $UserUpdateParams.Add("home_number", "home_number")
        $UserUpdateParams.Add("work_number", "work_number")
        $UserUpdateParams.Add("work_mobile_number", "work_mobile_number")
        $UserUpdateParams.Add("work_fax_number", "work_fax_number")
        $UserUpdateParams.Add("account_locked", "account_locked")
        $UserUpdateParams.Add("allow_public_key", "allow_public_key")
        $UserUpdateParams.Add("enable_managed_uid", "enable_managed_uid")
        $UserUpdateParams.Add("enable_user_portal_multifactor", "enable_user_portal_multifactor")
        $UserUpdateParams.Add("externally_managed", "externally_managed")
        $UserUpdateParams.Add("external_dn", "external_dn")
        $UserUpdateParams.Add("external_source_type", "external_source_type")
        $UserUpdateParams.Add("ldap_binding_user", "ldap_binding_user")
        $UserUpdateParams.Add("passwordless_sudo", "passwordless_sudo")
        $UserUpdateParams.Add("sudo", "sudo")
        $UserUpdateParams.Add("unix_guid", "unix_guid")
        $UserUpdateParams.Add("password_never_expires", "password_never_expires")










        Write-Verbose "$($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -eq 'GUI')
        {

            Write-Verbose 'Verifying JCAPI Key'
            if ($JCAPIKEY.length -ne 40) { Connect-JConline }

            $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                                  User Update
"@

            If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) { Clear-Host }
            Write-Host $Banner -ForegroundColor Green
            Write-Host ""

            $UpdateUsers = Import-Csv -Path $CSVFilePath

            $CustomAttributes = $UpdateUsers | Get-Member | Where-Object Name -Like "*Attribute*" | Select-Object Name


            foreach ($attr in $CustomAttributes )
            {
                $UserUpdateParams.Add($attr.name, $attr.name)
            }

            $employeeIdentifierCheck = $UpdateUsers | Where-Object { ($_.employeeIdentifier -ne $Null) -and ($_.employeeIdentifier -ne "") }

            if ($employeeIdentifierCheck.Count -gt 0)
            {
                Write-Host ""
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($employeeIdentifierCheck.employeeIdentifier.Count) employeeIdentifiers"

                $ExistingEmployeeIdentifierCheck = Get-Hash_employeeIdentifier_username

                foreach ($User in $employeeIdentifierCheck)
                {
                    if ($ExistingEmployeeIdentifierCheck.ContainsKey($User.employeeIdentifier))
                    {
                        Write-Warning "The user $($ExistingEmployeeIdentifierCheck.($User.employeeIdentifier)) has the employeeIdentifier: $($User.employeeIdentifier). User $($User.username) will not be updated."
                    }
                    else
                    {
                        Write-Verbose "$($User.employeeIdentifier) does not exist"
                    }
                }

                $employeeIdentifierDup = $employeeIdentifierCheck | Group-Object employeeIdentifier

                ForEach ($U in $employeeIdentifierDup)
                {
                    if ($U.count -gt 1)
                    {

                        Write-Warning "Duplicate employeeIdentifier: $($U.name) in import file. employeeIdentifier must be unique. To resolve eliminate the duplicate employeeIdentifiers."
                    }
                }

                Write-Host -BackgroundColor Green -ForegroundColor Black "employeeIdentifier check complete"
            }

            $SystemCount = $UpdateUsers.SystemID | Where-Object Length -gt 1 | Select-Object -unique

            if ($SystemCount.count -gt 0)
            {
                Write-Host ""
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($SystemCount.count) Systems"
                $SystemCheck = Get-Hash_SystemID_HostName

                foreach ($User in $UpdateUsers)
                {
                    if (($User.SystemID).length -gt 1)
                    {

                        if ($SystemCheck.ContainsKey($User.SystemID))
                        {
                            Write-Verbose "$($User.SystemID) exists"
                        }
                        else
                        {
                            Write-Warning "A system with SystemID: $($User.SystemID) does not exist and will not be bound to user $($User.Username)"
                        }
                    }
                    else { Write-Verbose "No system" }
                }

                $Permissions = $UpdateUsers.Administrator | Where-Object Length -gt 1 | Select-Object -unique

                foreach ($Value in $Permissions)
                {

                    if ( ($Value -notlike "*true" -and $Value -notlike "*false") )
                    {

                        Write-Warning "Administrator must be a boolean value and set to either '`$True/True' or '`$False/False' please correct value: $Value "


                    }

                }

                Write-Host -BackgroundColor Green -ForegroundColor Black "System check complete"
                Write-Host ""
                #Group Check
            }

            $GroupArrayList = New-Object System.Collections.ArrayList

            ForEach ($User in $UpdateUsers)
            {

                $Groups = $User | Get-Member -Name Group* | Select-Object Name

                foreach ($Group in $Groups)
                {
                    $CheckGroup = [pscustomobject]@{
                        Type  = 'GroupName'
                        Value = $User.($Group.Name)
                    }

                    if ($CheckGroup.Value.Length -gt 1)
                    {

                        $GroupArrayList.Add($CheckGroup) | Out-Null

                    }

                    else { }

                }

            }

            $UniqueGroups = $GroupArrayList | Select-Object Value -Unique

            if ($UniqueGroups.count -gt 0)
            {
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($UniqueGroups.count) Groups"
                $GroupCheck = Get-Hash_UserGroupName_ID

                foreach ($GroupTest in $UniqueGroups)
                {
                    if ($GroupCheck.ContainsKey($GroupTest.Value))
                    {
                        Write-Verbose "$($GroupTest.Value) exists"
                    }
                    else
                    {
                        Write-Host "The JumpCloud Group:" -NoNewLine
                        Write-Host " $($GroupTest.Value)" -ForegroundColor Yellow -NoNewLine
                        Write-Host " does not exist. Users will not be added to this Group."
                    }
                }

                Write-Host -BackgroundColor Green -ForegroundColor Black "Group check complete"
                Write-Host ""
            }



            $ResultsArrayList = New-Object System.Collections.ArrayList

            $NumberOfNewUsers = $UpdateUsers.username.count

            $title = "Import Summary:"

            $menu = @"

    Number Of Users To Update = $NumberOfNewUsers

    Would you like to update these users?

"@

            Write-Host $title -ForegroundColor Red
            Write-Host $menu -ForegroundColor Yellow


            while ($Confirm -ne 'Y' -and $Confirm -ne 'N')
            {
                $Confirm = Read-Host "Press Y to confirm or N to quit"
            }

            if ($Confirm -eq 'Y')
            {

                Write-Host ''
                Write-Host "Hang tight! Updating your users. " -NoNewline
                Write-Host "DO NOT shutdown the console." -ForegroundColor Red
                Write-Host ''
                Write-Host "It takes ~ 1 minute per 100 users."

            }

            elseif ($Confirm -eq 'N')
            {
                break
            }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $UpdateUsers = Import-Csv -Path $CSVFilePath
            $NumberOfNewUsers = $UpdateUsers.username.count
            $ResultsArrayList = New-Object System.Collections.ArrayList

            $CustomAttributes = $UpdateUsers | Get-Member | Where-Object Name -Like "*Attribute*" | Select-Object Name


            foreach ($attr in $CustomAttributes )
            {
                $UserUpdateParams.Add($attr.name, $attr.name)
            }
        }

    } #begin block end

    process
    {
        [int]$ProgressCounter = 0

        foreach ($UserUpdate in $UpdateUsers)
        {
            $UpdateParamsRaw = $UserUpdate.psobject.properties | Where-Object { ($_.Value -ne $Null) -and ($_.Value -ne "") } | Select-Object Name, Value
            $UpdateParams = @{ }

            foreach ($Param in $UpdateParamsRaw)
            {
                if ($UserUpdateParams.$($Param.name))
                {
                    $UpdateParams.Add($Param.name, $Param.value)
                }

            }

            $ProgressCounter++

            $GroupAddProgressParams = @{

                Activity        = "Updating $($UserUpdate.username)"
                Status          = "User update $ProgressCounter of $NumberOfNewUsers"
                PercentComplete = ($ProgressCounter / $NumberOfNewUsers) * 100

            }

            Write-Progress @GroupAddProgressParams

            $NewUser = $Null
            $Status = $Null
            $UserGroupArrayList = $Null
            $SystemAddStatus = $Null
            $FormatGroupOutput = $Null
            $CustomGroupArrayList = $Null

            $CustomAttributes = $UserUpdate | Get-Member | Where-Object Name -Like "*Attribute*" | Where-Object { $_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null" } | Select-Object Name

            Write-Verbose $CustomAttributes.name.count

            if ($CustomAttributes.name.count -gt 1)
            {
                try
                {
                    $NumberOfCustomAttributes = ($CustomAttributes.name.count) / 2

                    $UpdateParams.Add("NumberOfCustomAttributes", $NumberOfCustomAttributes)

                    $JSONParams = $UpdateParams | ConvertTo-Json

                    Write-Verbose "$($JSONParams)"

                    $NewUser = Set-JCUser @UpdateParams

                    if ($NewUser._id)
                    {

                        $Status = 'User Updated'
                    }

                    elseif (-not $NewUser._id)
                    {
                        $Status = 'User does not exist'
                    }

                    try #User is created
                    {
                        if ($UserUpdate.SystemID)
                        {

                            if ($UserUpdate.Administrator)
                            {

                                if ($UserUpdate.Administrator -like "*True")
                                {

                                    Write-Verbose "Admin set to true"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserUpdate.Administrator -like "*False")
                                {

                                    Write-Verbose "Admin set to false"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }

                                }

                            }

                            else
                            {

                                Write-Verbose "No admin set"

                                try
                                {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                }
                                catch
                                {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }
                        }
                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserUpdate | Get-Member | Where-Object Name -Like "*Group*" | Where-Object { $_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null" } | Select-Object Name

                        foreach ($Group in $CustomGroups)
                        {
                            $GetGroup = [pscustomobject]@{
                                Type  = 'GroupName'
                                Value = $UserUpdate.($Group.Name)
                            }

                            $CustomGroupArrayList.Add($GetGroup) | Out-Null

                        }

                        $UserGroupArrayList = New-Object System.Collections.ArrayList

                        foreach ($Group in $CustomGroupArrayList)
                        {
                            try
                            {

                                $GroupAdd = Add-JCUserGroupMember -ByID -UserID $NewUser._id -GroupName $Group.value

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch
                            {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    }
                    catch
                    {

                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $NewUser.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserUpdate.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }



                }

                catch
                {

                    $Status = 'User does not exist'

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $UpdateParams.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserUpdate.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }


                }

                $ResultsArrayList.Add($FormattedResults) | Out-Null
                $SystemAddStatus = $null


            }

            else
            {
                try
                {
                    $JSONParams = $UpdateParams | ConvertTo-Json

                    Write-Verbose "$($JSONParams)"

                    $NewUser = Set-JCUser @UpdateParams

                    if ($NewUser._id)
                    {

                        $Status = 'User Updated'
                    }

                    elseif (-not $NewUser._id)
                    {
                        $Status = 'User does not exist'
                    }


                    try #User is created
                    {
                        if ($UserUpdate.SystemID)
                        {

                            if ($UserUpdate.Administrator)
                            {

                                Write-Verbose "Admin set"

                                if ($UserUpdate.Administrator -like "*True")
                                {

                                    Write-Verbose "Admin set to true"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserUpdate.Administrator -like "*False")
                                {

                                    Write-Verbose "Admin set to false"

                                    try
                                    {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    }
                                    catch
                                    {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }

                                }


                            }

                            else
                            {

                                Write-Verbose "No admin set"

                                try
                                {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                }
                                catch
                                {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }



                        }

                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserUpdate | Get-Member | Where-Object Name -Like "*Group*" | Where-Object { $_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null" } | Select-Object Name

                        foreach ($Group in $CustomGroups)
                        {
                            $GetGroup = [pscustomobject]@{
                                Type  = 'GroupName'
                                Value = $UserUpdate.($Group.Name)
                            }

                            $CustomGroupArrayList.Add($GetGroup) | Out-Null

                        }

                        $UserGroupArrayList = New-Object System.Collections.ArrayList

                        foreach ($Group in $CustomGroupArrayList)
                        {
                            try
                            {

                                $GroupAdd = Add-JCUserGroupMember -ByID -UserID $NewUser._id -GroupName $Group.value

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch
                            {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    }
                    catch
                    {

                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $NewUser.username
                        'Status'    = $Status
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserUpdate.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }




                }

                catch
                {
                    $Status = "$($_.ErrorDetails)"

                    if (-not (Get-JCUser -username $UpdateParams.username -returnProperties username))
                    {
                        $Status = 'User does not exist'
                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'  = $UpdateParams.username
                        'Status'    = "$Status"
                        'UserID'    = $NewUser._id
                        'GroupsAdd' = $UserGroupArrayList
                        'SystemID'  = $UserUpdate.SystemID
                        'SystemAdd' = $SystemAddStatus

                    }


                }

                $ResultsArrayList.Add($FormattedResults) | Out-Null
                $SystemAddStatus = $null

            }

        }
    }

    end
    {
        return $ResultsArrayList
    }
}