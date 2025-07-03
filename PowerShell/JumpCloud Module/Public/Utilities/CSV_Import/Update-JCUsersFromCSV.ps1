Function Update-JCUsersFromCSV () {
    [CmdletBinding(DefaultParameterSetName = 'GUI')]
    param
    (
        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'GUI',
            HelpMessage = 'The full path to the CSV file you wish to import. You can use tab complete to search for .csv files.')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]

        [Parameter(Mandatory,
            position = 0,
            ParameterSetName = 'force',
            HelpMessage = 'The full path to the CSV file you wish to import. You can use tab complete to search for .csv files.')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]

        [string]$CSVFilePath,

        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'A SwitchParameter which suppresses the GUI and data validation when using the Update-JCUsersFromCSV command.')]
        [Switch]
        $force


    )

    begin {
        $UserUpdateParams = @{ }
        $UserUpdateParams.Add("Username", "Username")
        $UserUpdateParams.Add("FirstName", "FirstName")
        $UserUpdateParams.Add("LastName", "LastName")
        $UserUpdateParams.Add("Email", "Email")
        $UserUpdateParams.Add("Password", "Password")
        $UserUpdateParams.Add("alternateEmail", "alternateEmail")
        $UserUpdateParams.Add("recoveryEmail", "recoveryEmail")
        $UserUpdateParams.Add("manager", "manager")
        $UserUpdateParams.Add("managedAppleId", "managedAppleId")
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
        $UserUpdateParams.Add("EnrollmentDays", "EnrollmentDays")# MFA
        $UserUpdateParams.Add("externally_managed", "externally_managed")
        $UserUpdateParams.Add("external_dn", "external_dn")
        $UserUpdateParams.Add("external_source_type", "external_source_type")
        $UserUpdateParams.Add("ldap_binding_user", "ldap_binding_user")
        $UserUpdateParams.Add("passwordless_sudo", "passwordless_sudo")
        $UserUpdateParams.Add("sudo", "sudo")
        $UserUpdateParams.Add("unix_guid", "unix_guid")
        $UserUpdateParams.Add("unix_uid", "unix_uid")
        $UserUpdateParams.Add("password_never_expires", "password_never_expires")










        Write-Verbose "$($PSCmdlet.ParameterSetName)"

        if ($PSCmdlet.ParameterSetName -eq 'GUI') {

            Write-Verbose 'Verifying JCAPI Key'
            if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
                Connect-JCOnline
            }

            $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                                  User Update
"@

            If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) {
                Clear-Host
            }
            Write-Host $Banner -ForegroundColor Green
            Write-Host ""

            $UpdateUsers = Import-Csv -Path $CSVFilePath
            $CustomAttributes = $UpdateUsers | Get-Member | Where-Object Name -Like "*Attribute*" | Select-Object Name

            foreach ($attr in $CustomAttributes ) {
                $UserUpdateParams.Add($attr.name, $attr.name)
            }
            $employeeIdentifierCheck = $UpdateUsers | Where-Object { ($_.employeeIdentifier -ne $Null) -and ($_.employeeIdentifier -ne "") }

            if ($employeeIdentifierCheck.Count -gt 0) {
                Write-Host ""
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($employeeIdentifierCheck.employeeIdentifier.Count) employeeIdentifiers"

                $ExistingEmployeeIdentifierCheck = Get-DynamicHash -Object User -returnProperties username, employeeIdentifier

                foreach ($User in $employeeIdentifierCheck) {
                    if ($ExistingEmployeeIdentifierCheck.Values.employeeIdentifier -contains ($User.employeeIdentifier)) {
                        Write-Warning "The user $($ExistingEmployeeIdentifierCheck.GetEnumerator().Where({$_.Value.employeeIdentifier -contains $User.employeeIdentifier}).username) has the employeeIdentifier: $($User.employeeIdentifier). User $($User.username) will not be updated."
                    } else {
                        Write-Verbose "$($User.employeeIdentifier) does not exist"
                    }
                }

                $employeeIdentifierDup = $employeeIdentifierCheck | Group-Object employeeIdentifier

                ForEach ($U in $employeeIdentifierDup) {
                    if ($U.count -gt 1) {

                        Write-Warning "Duplicate employeeIdentifier: $($U.name) in import file. employeeIdentifier must be unique. To resolve eliminate the duplicate employeeIdentifiers."
                    }
                }

                Write-Host -BackgroundColor Green -ForegroundColor Black "employeeIdentifier check complete"
            }

            $SystemCount = $UpdateUsers.SystemID | Where-Object Length -GT 1 | Select-Object -Unique

            if ($SystemCount.count -gt 0) {
                Write-Host ""
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($SystemCount.count) Systems"
                $SystemCheck = Get-DynamicHash -Object System -returnProperties hostname

                foreach ($User in $UpdateUsers) {
                    if (($User.SystemID).length -gt 1) {

                        if ($SystemCheck[$User.SystemID]) {
                            Write-Verbose "$($User.SystemID) exists"
                        } else {
                            Write-Warning "A system with SystemID: $($User.SystemID) does not exist and will not be bound to user $($User.Username)"
                        }
                    } else {
                        Write-Verbose "No system"
                    }
                }

                $Permissions = $UpdateUsers.Administrator | Where-Object Length -GT 1 | Select-Object -Unique

                foreach ($Value in $Permissions) {

                    if ( ($Value -notlike "*true" -and $Value -notlike "*false") ) {

                        Write-Warning "Administrator must be a boolean value and set to either '`$True/True' or '`$False/False' please correct value: $Value "


                    }

                }

                Write-Host -BackgroundColor Green -ForegroundColor Black "System check complete"
                Write-Host ""
                #Group Check
            }

            $GroupArrayList = New-Object System.Collections.ArrayList

            ForEach ($User in $UpdateUsers) {

                $Groups = $User | Get-Member -Name Group* | Select-Object Name

                foreach ($Group in $Groups) {
                    $CheckGroup = [pscustomobject]@{
                        Type  = 'GroupName'
                        Value = $User.($Group.Name)
                    }

                    if ($CheckGroup.Value.Length -gt 1) {

                        $GroupArrayList.Add($CheckGroup) | Out-Null

                    } else {
                    }

                }

            }

            $UniqueGroups = $GroupArrayList | Select-Object Value -Unique

            if ($UniqueGroups.count -gt 0) {
                Write-Host -BackgroundColor Green -ForegroundColor Black "Validating $($UniqueGroups.count) Groups"
                $GroupCheck = Get-DynamicHash -Object Group -GroupType User -returnProperties name

                foreach ($GroupTest in $UniqueGroups) {
                    if ($GroupCheck.Values.name -contains ($GroupTest.Value)) {
                        Write-Verbose "$($GroupTest.Value) exists"
                    } else {
                        Write-Host "The JumpCloud Group:" -NoNewline
                        Write-Host " $($GroupTest.Value)" -ForegroundColor Yellow -NoNewline
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


            while ($Confirm -ne 'Y' -and $Confirm -ne 'N') {
                $Confirm = Read-Host "Press Y to confirm or N to quit"
            }

            if ($Confirm -eq 'Y') {

                Write-Host ''
                Write-Host "Hang tight! Updating your users. " -NoNewline
                Write-Host "DO NOT shutdown the console." -ForegroundColor Red
                Write-Host ''
                Write-Host "It takes ~ 1 minute per 100 users."

            }

            elseif ($Confirm -eq 'N') {
                break
            }

        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force') {

            $UpdateUsers = Import-Csv -Path $CSVFilePath
            $NumberOfNewUsers = $UpdateUsers.username.count
            $ResultsArrayList = New-Object System.Collections.ArrayList

            $CustomAttributes = $UpdateUsers | Get-Member | Where-Object Name -Like "*Attribute*" | Select-Object Name


            foreach ($attr in $CustomAttributes ) {
                $UserUpdateParams.Add($attr.name, $attr.name)
            }
        }

    } #begin block end

    process {
        [int]$ProgressCounter = 0

        foreach ($UserUpdate in $UpdateUsers) {
            $UniqueAttrValues = @()
            $UpdateParamsAttrValidate = $UserUpdate.psobject.properties | Where-Object { ($_.Name -match "Attribute") } |  Select-Object Name, Value
            foreach ($Param in $UpdateParamsAttrValidate) {
                If (($Param.Name -match "_name") -And (![string]::IsNullOrEmpty($Param.Value))) {
                    $matchingValueField = $Param.Name.Replace("_name", "_value")
                    $matchingValue = $UpdateParamsAttrValidate | Where-Object { ($_.Name -eq $matchingValueField) }
                    if ([string]::IsNullOrEmpty($matchingValue.Value)) {
                        Throw "A Custom Attribute name: $($Param.Name):$($Param.Value) was specified but is missing a corresponding value: $($matchingValue.Name):$($matchingValue.Value). Null attribute values are not supported"
                    } else {
                        $UniqueAttrValues += $matchingValue.Value
                    }
                }
            }
            $UpdateParamsRaw = $UserUpdate.psobject.properties | Where-Object { ($_.Value -ne $Null) -and ($_.Value -ne "") } | Select-Object Name, Value
            $UpdateParams = @{ }

            foreach ($Param in $UpdateParamsRaw) {
                if ($UserUpdateParams.$($Param.name) -eq "ldap_binding_user") {
                    continue
                } elseif ($UserUpdateParams.$($Param.name) -eq "ldapserver_id") {
                    continue
                } elseif ($UserUpdateParams.$($Param.name) -eq "enable_user_portal_multifactor") {
                    $enable_mfa_boolean = [System.Convert]::ToBoolean($Param.value)
                    $UpdateParams.Add($Param.name, $enable_mfa_boolean)
                } elseif ($UserUpdateParams.$($Param.name)) {
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

            # Get all the custom attributes that are not null
            $CustomAttributes = $UserUpdate | Get-Member | Where-Object Name -Like "*Attribute*" | Where-Object { $_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null" }

            # Sort the attributes by number and name
            $CustomAttributes = $CustomAttributes | Sort-Object {
                [int]([regex]::Match($_.Name, '\d+').Value) },
            { $_.Name }

            if ($CustomAttributes.name.count -gt 1) {
                try {
                    # Counter is used to create a clean list of attributes
                    $counter = 1
                    # Create a clean list of attributes
                    $CustomAttributes | ForEach-Object {
                        # Current value of the attribute from Definition property
                        $value = $_.Definition -split '=' | Select-Object -Last 1

                        # If attribute has a name
                        if ($_.Name -like "*_name") {
                            # If current attribute is the same as counter, skip since it is already in the UpdateParams
                            if ($_.Name -eq "Attribute$($counter)_name") {
                            } else {
                                # Add the new AttributeName and current value to the UpdateParams
                                $UpdateParams.Add("Attribute$($counter)_name", $value)
                                # Remove the Current AttributeName from the UpdateParams since we overwrote it with the new name
                                $UpdateParams.Remove($_.Name)
                            }
                        }
                        # If attribute has a value
                        if ($_.Name -like "*_value") {
                            # If current attribute is the same as counter, skip since it is already in the UpdateParams
                            if ($_.Name -eq "Attribute$($counter)_value") {
                                $counter++
                            } else {
                                # Add the new AttributeValue and current value to the UpdateParams
                                $UpdateParams.Add("Attribute$($counter)_value", $value)
                                # Remove the Current AttributeValue from the UpdateParams since we overwrote it with the new value
                                $UpdateParams.Remove($_.Name)
                                $counter++
                            }
                        }
                    }

                    Write-Verbose "Attributes are $($UpdateParams)"

                    $NumberOfCustomAttributes = $UpdateParams.Keys | Where-Object { $_ -like "*Attribute*" } | Measure-Object | Select-Object -ExpandProperty Count

                    $UpdateParams.Add("NumberOfCustomAttributes", $NumberOfCustomAttributes / 2)

                    $JSONParams = $UpdateParams | ConvertTo-Json

                    $NewUser = Set-JCUser @UpdateParams

                    if ($NewUser._id) {

                        $Status = 'User Updated'
                    }

                    elseif (-not $NewUser._id) {
                        $Status = 'User does not exist'
                    }

                    try {
                        #User is created
                        if ($UserUpdate.ldapserver_id) {

                            try {
                                $LdapAdd = Set-JcSdkLdapServerAssociation -LdapserverId $UserUpdate.ldapserver_id -Id $NewUser._id -Op "add" -Type "user"
                            } catch {
                                $LdapBindStatus =
                                if ($_.ErrorDetails) {
                                    $_.ErrorDetails
                                } elseif ($_.Exception) {
                                    $_.Exception.Message
                                }
                            }
                            try {
                                $ldap_bind_boolean = [System.Convert]::ToBoolean($UserUpdate.ldap_binding_user)
                                $ldap_bind = Set-JCUser -UserID $NewUser._id -ldap_binding_user $ldap_bind_boolean
                                $LdapBindStatus = $ldap_bind.ldap_binding_user

                            } catch {
                                $LdapBindStatus =
                                if ($_.ErrorDetails) {
                                    $_.ErrorDetails
                                } elseif ($_.Exception) {
                                    $_.Exception.Message
                                }
                            }

                        }

                        if ($UserUpdate.SystemID) {

                            if ($UserUpdate.Administrator) {

                                if ($UserUpdate.Administrator -like "*True") {

                                    Write-Verbose "Admin set to true"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    } catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserUpdate.Administrator -like "*False") {

                                    Write-Verbose "Admin set to false"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    } catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }

                                }

                            }

                            else {

                                Write-Verbose "No admin set"

                                try {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                } catch {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }
                        }
                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserUpdate | Get-Member | Where-Object Name -Like "*Group*" | Where-Object { $_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null" } | Select-Object Name

                        foreach ($Group in $CustomGroups) {
                            $GetGroup = [pscustomobject]@{
                                Type  = 'GroupName'
                                Value = $UserUpdate.($Group.Name)
                            }

                            $CustomGroupArrayList.Add($GetGroup) | Out-Null

                        }

                        $UserGroupArrayList = New-Object System.Collections.ArrayList

                        foreach ($Group in $CustomGroupArrayList) {
                            try {

                                $GroupAdd = Add-JCUserGroupMember -ByID -UserID $NewUser._id -GroupName $Group.value

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    } catch {

                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'     = $NewUser.username
                        'Status'       = $Status
                        'UserID'       = $NewUser._id
                        'GroupsAdd'    = $UserGroupArrayList
                        'SystemID'     = $UserUpdate.SystemID
                        'SystemAdd'    = $SystemAddStatus
                        'LdapUserBind' = $LdapBindStatus
                    }



                }

                catch {
                    If ($_.ErrorDetails) {
                        $Status = $_.ErrorDetails
                    } elseif ($_.Exception) {
                        $Status = $_.Exception.Message
                    }
                    if (-not (Get-JCUser -username $UpdateParams.username -returnProperties username)) {
                        $Status = 'User does not exist'
                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'     = $UpdateParams.username
                        'Status'       = $Status
                        'UserID'       = $NewUser._id
                        'GroupsAdd'    = $UserGroupArrayList
                        'SystemID'     = $UserUpdate.SystemID
                        'SystemAdd'    = $SystemAddStatus
                        'LdapUserBind' = $LdapBindStatus
                    }


                }

                $ResultsArrayList.Add($FormattedResults) | Out-Null
                $SystemAddStatus = $null


            }

            else {
                try {
                    $JSONParams = $UpdateParams | ConvertTo-Json

                    Write-Verbose "$($JSONParams)"

                    $NewUser = Set-JCUser @UpdateParams

                    if ($NewUser._id) {

                        $Status = 'User Updated'
                    }

                    elseif (-not $NewUser._id) {
                        $Status = 'User does not exist'
                    }


                    try {
                        #User is created
                        if ($UserUpdate.ldapserver_id) {

                            try {
                                $LdapAdd = Set-JcSdkLdapServerAssociation -LdapserverId $UserUpdate.ldapserver_id -Id $NewUser._id -Op "add" -Type "user"
                            } catch {
                                $LdapBindStatus =
                                if ($_.ErrorDetails) {
                                    $_.ErrorDetails
                                } elseif ($_.Exception) {
                                    $_.Exception.Message
                                }
                            }
                            try {
                                $ldap_bind_boolean = [System.Convert]::ToBoolean($UserUpdate.ldap_binding_user)
                                $ldap_bind = Set-JCUser -UserID $NewUser._id -ldap_binding_user $ldap_bind_boolean
                                $LdapBindStatus = $ldap_bind.ldap_binding_user

                            } catch {
                                $LdapBindStatus =
                                if ($_.ErrorDetails) {
                                    $_.ErrorDetails
                                } elseif ($_.Exception) {
                                    $_.Exception.Message
                                }
                            }

                        }
                        if ($UserUpdate.SystemID) {

                            if ($UserUpdate.Administrator) {

                                Write-Verbose "Admin set"

                                if ($UserUpdate.Administrator -like "*True") {

                                    Write-Verbose "Admin set to true"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $true
                                        $SystemAddStatus = $SystemAdd.Status
                                    } catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }
                                }

                                elseif ($UserUpdate.Administrator -like "*False") {

                                    Write-Verbose "Admin set to false"

                                    try {
                                        $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id -Administrator $false
                                        $SystemAddStatus = $SystemAdd.Status
                                    } catch {
                                        $SystemAddStatus = $_.ErrorDetails
                                    }

                                }


                            }

                            else {

                                Write-Verbose "No admin set"

                                try {
                                    $SystemAdd = Add-JCSystemUser -SystemID $UserUpdate.SystemID -UserID $NewUser._id
                                    Write-Verbose  "$($SystemAdd.Status)"
                                    $SystemAddStatus = $SystemAdd.Status
                                } catch {
                                    $SystemAddStatus = $_.ErrorDetails
                                }

                            }



                        }

                        $CustomGroupArrayList = New-Object System.Collections.ArrayList

                        $CustomGroups = $UserUpdate | Get-Member | Where-Object Name -Like "*Group*" | Where-Object { $_.Definition -NotLike "*=" -and $_.Definition -NotLike "*null" } | Select-Object Name

                        foreach ($Group in $CustomGroups) {
                            $GetGroup = [pscustomobject]@{
                                Type  = 'GroupName'
                                Value = $UserUpdate.($Group.Name)
                            }

                            $CustomGroupArrayList.Add($GetGroup) | Out-Null

                        }

                        $UserGroupArrayList = New-Object System.Collections.ArrayList

                        foreach ($Group in $CustomGroupArrayList) {
                            try {

                                $GroupAdd = Add-JCUserGroupMember -ByID -UserID $NewUser._id -GroupName $Group.value

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $GroupAdd.Status
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }

                            catch {

                                $FormatGroupOutput = [PSCustomObject]@{

                                    'Group'  = $Group.value
                                    'Status' = $_.ErrorDetails
                                }

                                $UserGroupArrayList.Add($FormatGroupOutput) | Out-Null
                            }
                        }
                    } catch {

                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'     = $NewUser.username
                        'Status'       = $Status
                        'UserID'       = $NewUser._id
                        'GroupsAdd'    = $UserGroupArrayList
                        'SystemID'     = $UserUpdate.SystemID
                        'SystemAdd'    = $SystemAddStatus
                        'LdapUserBind' = $LdapBindStatus

                    }




                }

                catch {
                    If ($_.ErrorDetails) {
                        $Status = $_.ErrorDetails
                    } elseif ($_.Exception) {
                        $Status = $_.Exception.Message
                    }

                    if (-not (Get-JCUser -username $UpdateParams.username -returnProperties username)) {
                        $Status = 'User does not exist'
                    }

                    $FormattedResults = [PSCustomObject]@{

                        'Username'     = $UpdateParams.username
                        'Status'       = "$Status"
                        'UserID'       = $NewUser._id
                        'GroupsAdd'    = $UserGroupArrayList
                        'SystemID'     = $UserUpdate.SystemID
                        'SystemAdd'    = $SystemAddStatus
                        'LdapUserBind' = $LdapBindStatus

                    }


                }

                $ResultsArrayList.Add($FormattedResults) | Out-Null
                $SystemAddStatus = $null

            }

        }
    }

    end {
        return $ResultsArrayList
    }
}