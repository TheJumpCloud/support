Function New-JCImportTemplate() {
    [CmdletBinding()]

    param
    (
        [Parameter(
            ParameterSetName = 'force',
            HelpMessage = 'Parameter to force populate CSV with all headers when creating an update template ')]
        [Switch]
        $force
    )

    begin {
        $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  /
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/
                       /_/
                                    CSV User Import Template
"@

        $date = Get-Date -Format MM-dd-yyyy


        $Heading2 = 'The CSV file will be created within the directory:'

        If (!(Get-PSCallStack | Where-Object { $_.Command -match 'Pester' })) {
            Clear-Host
        }

        Write-Host $Banner -ForegroundColor Green
        Write-Host "`n$Heading2`n"
        Write-Host " $PWD" -ForegroundColor Yellow
        Write-Host ""


        while ($ConfirmFile -ne 'Y' -and $ConfirmFile -ne 'N') {
            $ConfirmFile = Read-Host  "Enter Y to confirm or N to change output location" #Confirm .csv file location creation
        }

        if ($ConfirmFile -eq 'Y') {

            $ExportLocation = $PWD
        }

        elseif ($ConfirmFile -eq 'N') {
            $ExportLocation = Read-Host "Enter the full path to the folder you wish to create the import file in"

            while (-not(Test-Path -Path $ExportLocation -PathType Container)) {
                Write-Host -BackgroundColor Yellow -ForegroundColor Red "The location $ExportLocation does not exist. Try another"
                $ExportLocation = Read-Host "Enter the full path to the folder you wish to create the import file in"

            }
            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "The CSV file will be created within the $ExportLocation directory"
            Pause

        }

    }

    process {

        Write-Host "`nDo you want to create an import CSV template for creating new users or for updating existing users?"
        Write-Host 'Enter "N" for to create a template for ' -NoNewline
        Write-Host -ForegroundColor Yellow 'new users'
        Write-Host 'Enter "U" for creating a template for ' -NoNewline
        Write-Host -ForegroundColor Yellow "updating existing users"


        while ($ConfirmUpdateVsNew -ne 'N' -and $ConfirmUpdateVsNew -ne 'U') {
            $ConfirmUpdateVsNew = Read-Host  "Enter N for 'new users' or U for 'updating users'"
        }

        if (($ConfirmUpdateVsNew -eq 'U' -and $PSCmdlet.ParameterSetName -eq 'force') -or ($ConfirmUpdateVsNew -eq 'N' -and $PSCmdlet.ParameterSetName -eq 'force')) {
            $CSV = [ordered]@{
                Username                       = $null
                FirstName                      = $null
                LastName                       = $null
                Password                       = $null
                Email                          = $null
                alternateEmail                 = $null
                manager                        = $null
                managedAppleId                 = $null
                middlename                     = $null
                preferredName                  = $null
                jobTitle                       = $null
                employeeIdentifier             = $null
                department                     = $null
                costCenter                     = $null
                company                        = $null
                employeeType                   = $null
                description                    = $null
                location                       = $null
                home_streetAddress             = $null
                home_city                      = $null
                home_state                     = $null
                home_postalCode                = $null
                home_poBox                     = $null
                home_country                   = $null
                work_streetAddress             = $null
                work_poBox                     = $null
                work_city                      = $null
                work_state                     = $null
                work_postalCode                = $null
                mobile_number                  = $null
                home_number                    = $null
                work_number                    = $null
                work_mobile_number             = $null
                work_fax_number                = $null
                unix_guid                      = $null
                unix_uid                       = $null
                enable_user_portal_multifactor = $null
                EnrollmentDays                 = $null
                ldap_binding_user              = $null
                ldapserver_id                  = $null
                account_locked                 = $null
                allow_public_key               = $null
                enable_managed_uid             = $null
                externally_managed             = $null
                external_dn                    = $null
                external_source_type           = $null
                passwordless_sudo              = $null
                sudo                           = $null
                password_never_expires         = $null
            }
            $fileName = 'JCUserUpdateImport_' + $date + '.csv'
            Write-Debug $fileName
            $CSVheader = New-Object psobject -Property $Csv


            if ($ConfirmUpdateVsNew -eq 'U') {
                $ExistingUsers = Get-DynamicHash -Object User -returnProperties username
                $CSVheader = @()
                foreach ($User in $ExistingUsers.GetEnumerator()) {
                    $CSVUserAdd = $CSV
                    $CSVUserAdd.Username = $User.value.username
                    $UserObject = New-Object psobject -Property $CSVUserAdd
                    $CSVheader += $UserObject
                }
            }
        } elseif ($ConfirmUpdateVsNew) {
            if ($ConfirmUpdateVsNew -eq 'N') {
                $CSV = [ordered]@{
                    FirstName = $null
                    LastName  = $null
                    Username  = $null
                    Password  = $null
                    Email     = $null

                }

                $fileName = 'JCUserImport_' + $date + '.csv'
                Write-Debug $fileName
            } elseif ($ConfirmUpdateVsNew -eq 'U') {
                $fileName = 'JCUserUpdateImport_' + $date + '.csv'
                Write-Debug $fileName

                $CSV = [ordered]@{
                    Username = $null
                }

                Write-Host "`nWould you like to populate this update template with all of your existing users?"
                Write-Host -ForegroundColor Yellow 'You can remove users you do not wish to modify from the import file after it is created.'


                while ($ConfirmUserPop -ne 'Y' -and $ConfirmUserPop -ne 'N') {
                    $ConfirmUserPop = Read-Host  "Enter Y for Yes or N for No"
                }

                if ($ConfirmUserPop -eq 'Y') {
                    Write-Verbose 'Verifying JCAPI Key'
                    if ($JCAPIKEY.length -ne 40) {
                        Connect-JConline
                    }
                    $ExistingUsers = Get-DynamicHash -Object User -returnProperties username
                }

                elseif ($ConfirmUserPop -eq 'N') {
                }


                Write-Host "`nWould you like to update users email addresses?"

                while ($ConfirmEmailAddress -ne 'Y' -and $ConfirmEmailAddress -ne 'N') {
                    $ConfirmEmailAddress = Read-Host  "Enter Y for Yes or N for No"
                }

                if ($ConfirmEmailAddress -eq 'Y') {
                    $CSV.add('email', $null)
                }

                elseif ($ConfirmEmailAddress -eq 'N') {
                }
            }

            Write-Host "`nDo you want to add extended user information attributes available over JumpCloud LDAP to your users during import?"
            Write-Host 'Extended user information attributes include: ' -NoNewline
            Write-Host -ForegroundColor Yellow 'AlternateEmail, Manager, ManagedAppleId, MiddleName, preferredName, jobTitle, employeeIdentifier, department, costCenter, company, employeeType, description, and location'


            while ($ConfirmLDAPAttributes -ne 'Y' -and $ConfirmLDAPAttributes -ne 'N') {
                $ConfirmLDAPAttributes = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmLDAPAttributes -eq 'Y') {
                $CSV.add('alternateEmail', $null)
                $CSV.add('manager', $null)
                $CSV.add('managedAppleId', $null)
                $CSV.add('MiddleName', $null)
                $CSV.add('preferredName', $null)
                $CSV.add('jobTitle', $null)
                $CSV.add('employeeIdentifier', $null)
                $CSV.add('department', $null)
                $CSV.add('costCenter', $null)
                $CSV.add('company', $null)
                $CSV.add('employeeType', $null)
                $CSV.add('description', $null)
                $CSV.add('location', $null)

            }

            elseif ($ConfirmLDAPLocationAttributes -eq 'N') {
            }

            Write-Host "`nDo you want to add extended user location attributes available over JumpCloud LDAP to your users during import?"
            Write-Host 'Extended user location attributes include: ' -NoNewline
            Write-Host -ForegroundColor Yellow 'home_streetAddress, home_poBox, home_city, home_state, home_postalCode, home_country, work_streetAddress, work_poBox, work_city, work_state, work_postalCode, work_country'


            while ($ConfirmLDAPLocationAttributes -ne 'Y' -and $ConfirmLDAPLocationAttributes -ne 'N') {
                $ConfirmLDAPLocationAttributes = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmLDAPLocationAttributes -eq 'Y') {

                $CSV.add('home_streetAddress', $null)
                $CSV.add('home_poBox', $null)
                $CSV.add('home_city', $null)
                $CSV.add('home_state', $null)
                $CSV.add('home_postalCode', $null)
                $CSV.add('home_country', $null)
                $CSV.add('work_streetAddress', $null)
                $CSV.add('work_poBox', $null)
                $CSV.add('work_city', $null)
                $CSV.add('work_state', $null)
                $CSV.add('work_postalCode', $null)
                $CSV.add('work_country', $null)

            }

            elseif ($ConfirmLDAPLocationAttributes -eq 'N') {
            }

            Write-Host "`nDo you want to add extended user telephony attributes available over JumpCloud LDAP to your users during import?"
            Write-Host 'Extended user telephony attributes include: ' -NoNewline
            Write-Host  'mobile_number, home_number, work_number, work_mobile_number, work_fax_number' -ForegroundColor Yellow

            while ($ConfirmLDAPTelephonyAttributes -ne 'Y' -and $ConfirmLDAPTelephonyAttributes -ne 'N') {
                $ConfirmLDAPTelephonyAttributes = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmLDAPTelephonyAttributes -eq 'Y') {

                $CSV.add('mobile_number', $null)
                $CSV.add('home_number', $null)
                $CSV.add('work_number', $null)
                $CSV.add('work_mobile_number', $null)
                $CSV.add('work_fax_number', $null)
            }

            elseif ($ConfirmLDAPTelephonyAttributes -eq 'N') {
            }

            Write-Host "`nDo you want to set unix UID/GUID values during import?"
            Write-Host 'UID/GUID value attributes include: ' -NoNewline
            Write-Host  'unix_uid, unix_guid' -ForegroundColor Yellow

            while ($ConfirmUIDGUIDAttributes -ne 'Y' -and $ConfirmUIDGUIDAttributes -ne 'N') {
                $ConfirmUIDGUIDAttributes = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmUIDGUIDAttributes -eq 'Y') {

                $CSV.add('unix_uid', $null)
                $CSV.add('unix_guid', $null)
            }

            elseif ($ConfirmUIDGUIDAttributes -eq 'N') {
            }

            Write-Host "`nDo you want to require MFA to user?"
            Write-Host  'enable_user_portal_multifactor, EnrollmentDays' -ForegroundColor Yellow
            while ($MFAOption -ne 'Y' -and $MFAOption -ne 'N') {
                $MFAOption = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($MFAOption -eq 'Y') {
                $CSV.add('enable_user_portal_multifactor', $null)
                $CSV.add('EnrollmentDays', $null)
            } elseif ($MFAOption -eq 'N') {
            }

            Write-Host "`nDo you want to bind the user to LDAP during import"
            Write-Host -ForegroundColor Yellow 'Ldap_Binding_User, Ldapserver_id'
            while ($ConfirmLDAPBind -ne 'Y' -and $ConfirmLDAPBind -ne 'N') {
                $ConfirmLDAPBind = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmLDAPBind -eq 'Y') {
                $CSV.add('ldap_binding_user', $null)
                $CSV.add('ldapserver_id', $null)
            } elseif ($ConfirmLDAPBind -eq 'N') {
            }

            Write-Host "`nDo you want to bind your users to existing JumpCloud systems during import?"

            while ($ConfirmSystem -ne 'Y' -and $ConfirmSystem -ne 'N') {
                $ConfirmSystem = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmSystem -eq 'Y') {

                $CSV.add('SystemID', $null)
                $CSV.add('Administrator', $null)

                $ExistingSystems = Get-JCSystem -returnProperties hostname, displayName | Select-Object HostName, DisplayName, @{Name = 'SystemID'; Expression = { $_._id } }, lastContact

                $SystemsName = 'JCSystems_' + $date + '.csv'

                $ExistingSystems | Export-Csv -path "$ExportLocation/$SystemsName" -NoTypeInformation

                Write-Host 'Creating file '  -NoNewline
                Write-Host $SystemsName -ForegroundColor Yellow -NoNewline
                Write-Host ' with all existing systems in the location' -NoNewline
                Write-Host " $ExportLocation" -ForegroundColor Yellow

            }

            elseif ($ConfirmAttributes -eq 'N') {
            }

            Write-Host ""
            Write-Host 'Do you want to add the users to JumpCloud user groups during import?'

            while ($ConfirmGroups -ne 'Y' -and $ConfirmGroups -ne 'N') {
                $ConfirmGroups = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmGroups -eq 'Y') {
                [int]$GroupNumber = Read-Host  "What is the maximum number of groups you want to add a single user to during import? ENTER A NUMBER"
                [int]$NewGroup = 0
                [int]$GroupID = 1
                $GroupsArray = @()

                while ($NewGroup -ne $GroupNumber) {
                    $GroupsArray += "Group$GroupID"
                    $NewGroup++
                    $GroupID++
                }

                foreach ($Group in $GroupsArray) {
                    $CSV.add($Group, $null)
                }

            }

            elseif ($ConfirmGroups -eq 'N') {
            }


            Write-Host ""
            Write-Host 'Do you want to add any custom attributes to your users during import? Note, customAttribute values must be unique'

            while ($ConfirmAttributes -ne 'Y' -and $ConfirmAttributes -ne 'N') {
                $ConfirmAttributes = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($ConfirmAttributes -eq 'Y') {
                [int]$AttributeNumber = Read-Host  "What is the maximum number of custom attributes you want to add to a single user during import? ENTER A NUMBER"
                [int]$NewAttribute = 0
                [int]$AttributeID = 1
                $NewAttributeArrayList = New-Object System.Collections.ArrayList

                while ($NewAttribute -ne $AttributeNumber) {
                    $temp = New-Object PSObject
                    $temp | Add-Member -MemberType NoteProperty -Name AttributeName  -Value "Attribute$AttributeID`_name"
                    $temp | Add-Member -MemberType NoteProperty -Name AttributeValue  -Value "Attribute$AttributeID`_value"
                    $NewAttributeArrayList.Add($temp) | Out-Null
                    $NewAttribute ++
                    $AttributeID ++
                }


                foreach ($Attribute in $NewAttributeArrayList) {
                    $CSV.add($Attribute.AttributeName, $null)
                    $CSV.add($Attribute.AttributeValue, $null)
                }

            }

            elseif ($ConfirmAttributes -eq 'N') {
            }

            $CSVheader = New-Object psobject -Property $Csv

            if ($ExistingUsers) {
                $CSVheader = @()

                foreach ($User in $ExistingUsers.GetEnumerator()) {
                    $CSVUserAdd = $CSV
                    $CSVUserAdd.Username = $User.value.username
                    $UserObject = New-Object psobject -Property $CSVUserAdd
                    $CSVheader += $UserObject
                }
            }
        }
    }



    end {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if (!$ExportPath ) {
            Write-Host ""
            $CSVheader | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file'  -NoNewline
            Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        } else {
            Write-Host ""
            Write-Warning "The file $fileName already exists do you want to overwrite it?" -WarningAction Inquire
            Write-Host ""
            $CSVheader | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file '  -NoNewline
            Write-Host $FileName -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "Do you want to open the file" -NoNewLine
        Write-Host " $FileName`?" -ForegroundColor Yellow

        while ($Open -ne 'Y' -and $Open -ne 'N') {
            $Open = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($Open -eq 'Y') {
            Invoke-Item -path "$ExportLocation/$FileName"

        }
        if ($Open -eq 'N') {
        }
    }
}