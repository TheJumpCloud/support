Describe -Tag:('JCUsersFromCSV') "Import-JCUsersFromCSV 1.8.0" {

    It "Imports users from a CSV populated with telephony attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "mobile_number"      = "$($user1RandomString)"
                "home_number"        = "$($user1RandomString)"
                "work_number"        = "$($user1RandomString)"
                "work_mobile_number" = "$($user1RandomString)"
                "work_fax_number"    = "$($user1RandomString)"
            }
        )
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_telephonyAttributes.csv" -Force

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_telephonyAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_telephonyAttributes.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)
        }

    }

    It "Imports users from a CSV populated with information attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomString)"
                "preferredName"      = "$($user1RandomString)"
                "jobTitle"           = "$($user1RandomString)"
                "employeeIdentifier" = "eid$($user1RandomString)"
                "alternateEmail"     = "deleteme$($user1RandomString)ae@testimportcsvuser.com"
                "recoveryEmail"      = "deleteme$($user1RandomString)re@testimportcsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomString)maid@testimportcsvuser.com"
                "department"         = "$($user1RandomString)"
                "costCenter"         = "$($user1RandomString)"
                "company"            = "$($user1RandomString)"
                "employeeType"       = "$($user1RandomString)"
                "description"        = "$($user1RandomString)"
                "location"           = "$($user1RandomString)"
            }
        )
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_userInformationAttributes.csv" -Force
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_userInformationAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_userInformationAttributes.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -Be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -Be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -Be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -Be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -Be $NewUserInfo.department
            $ImportCheck.costCenter | Should -Be $NewUserInfo.costCenter
            $ImportCheck.company | Should -Be $NewUserInfo.company
            $ImportCheck.employeeType | Should -Be $NewUserInfo.employeeType
            $ImportCheck.description | Should -Be $NewUserInfo.description
            $ImportCheck.location | Should -Be $NewUserInfo.location
            $ImportCheck.alternateEmail | Should -Be $NewUserInfo.alternateEmail
            $ImportCheck.recoveryEmail | Should -Be $NewUserInfo.recoveryEmail.address

        }
    }

    It "Imports users from a CSV populated with user location attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "home_streetAddress" = "$($user1RandomString)"
                "home_poBox"         = "$($user1RandomString)"
                "home_city"          = "$($user1RandomString)"
                "home_state"         = "$($user1RandomString)"
                "home_postalCode"    = "$($user1RandomString)"
                "home_country"       = "$($user1RandomString)"
                "work_streetAddress" = "$($user1RandomString)"
                "work_poBox"         = "$($user1RandomString)"
                "work_city"          = "$($user1RandomString)"
                "work_state"         = "$($user1RandomString)"
                "work_postalCode"    = "$($user1RandomString)"
                "work_country"       = "$($user1RandomString)"
            }
        )
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_userLocationAttributes.csv" -Force
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_userLocationAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_userLocationAttributes.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.home_streetAddress | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

        }
    }
    It "Imports users from a CSV populated with uid/ gid attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @{
            "FirstName" = "delete$($user1RandomString)"
            "LastName"  = "me$($user1RandomString)"
            "Username"  = "delete.me$($user1RandomString)"
            "Email"     = "deleteme$($user1RandomString)@testimportcsvuser.com"
            "Password"  = "$(New-RandomString -NumberOfChars 8)@#7Ah"
            "unix_guid" = "9837"
            "unix_uid"  = "9837"
        }
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_uid_guid_import.csv" -Force

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_uid_guid_import.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_uid_guid_import.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.unix_uid | Should -Be $($NewUserInfo.unix_uid)
            $ImportCheck.unix_guid | Should -Be $($NewUserInfo.unix_guid)
        }
    }

    It "Imports users from a CSV populated with telephony, location, and user information attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $user2RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomString)"
                "preferredName"      = "$($user1RandomString)"
                "jobTitle"           = "$($user1RandomString)"
                "employeeIdentifier" = "eid$($user1RandomString)"
                "alternateEmail"     = "deleteme$($user1RandomString)ae@testimportcsvuser.com"
                "recoveryEmail"      = "deleteme$($user1RandomString)re@testimportcsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomString)maid@testimportcsvuser.com"
                "department"         = "$($user1RandomString)"
                "costCenter"         = "$($user1RandomString)"
                "company"            = "$($user1RandomString)"
                "employeeType"       = "$($user1RandomString)"
                "description"        = "$($user1RandomString)"
                "location"           = "$($user1RandomString)"
                "home_streetAddress" = "$($user1RandomString)"
                "home_poBox"         = "$($user1RandomString)"
                "home_city"          = "$($user1RandomString)"
                "home_state"         = "$($user1RandomString)"
                "home_postalCode"    = "$($user1RandomString)"
                "home_country"       = "$($user1RandomString)"
                "work_streetAddress" = "$($user1RandomString)"
                "work_poBox"         = "$($user1RandomString)"
                "work_city"          = "$($user1RandomString)"
                "work_state"         = "$($user1RandomString)"
                "work_postalCode"    = "$($user1RandomString)"
                "work_country"       = "$($user1RandomString)"
                "mobile_number"      = "$($user1RandomString)"
                "home_number"        = "$($user1RandomString)"
                "work_number"        = "$($user1RandomString)"
                "work_mobile_number" = "$($user1RandomString)"
                "work_fax_number"    = "$($user1RandomString)"
            },
            @{
                "FirstName"          = "delete$($user2RandomString)"
                "LastName"           = "me$($user2RandomString)"
                "Username"           = "delete.me$($user2RandomString)"
                "Email"              = "deleteme$($user2RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomString)"
                "preferredName"      = "$($user2RandomString)"
                "jobTitle"           = "$($user2RandomString)"
                "employeeIdentifier" = "eid$($user2RandomString)"
                "alternateEmail"     = "deleteme$($user2RandomString)ae@testimportcsvuser.com"
                "recoveryEmail"      = "deleteme$($user2RandomString)re@testimportcsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomString)maid@testimportcsvuser.com"
                "department"         = "$($user2RandomString)"
                "costCenter"         = "$($user2RandomString)"
                "company"            = "$($user2RandomString)"
                "employeeType"       = "$($user2RandomString)"
                "description"        = "$($user2RandomString)"
                "location"           = "$($user2RandomString)"
                "home_streetAddress" = "$($user2RandomString)"
                "home_poBox"         = "$($user2RandomString)"
                "home_city"          = "$($user2RandomString)"
                "home_state"         = "$($user2RandomString)"
                "home_postalCode"    = "$($user2RandomString)"
                "home_country"       = "$($user2RandomString)"
                "work_streetAddress" = "$($user2RandomString)"
                "work_poBox"         = "$($user2RandomString)"
                "work_city"          = "$($user2RandomString)"
                "work_state"         = "$($user2RandomString)"
                "work_postalCode"    = "$($user2RandomString)"
                "work_country"       = "$($user2RandomString)"
                "mobile_number"      = "$($user2RandomString)"
                "home_number"        = "$($user2RandomString)"
                "work_number"        = "$($user2RandomString)"
                "work_mobile_number" = "$($user2RandomString)"
                "work_fax_number"    = "$($user2RandomString)"
            }
        )
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributes.csv" -Force

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_allNewAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributes.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -Be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -Be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -Be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -Be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -Be $NewUserInfo.department
            $ImportCheck.costCenter | Should -Be $NewUserInfo.costCenter
            $ImportCheck.company | Should -Be $NewUserInfo.company
            $ImportCheck.employeeType | Should -Be $NewUserInfo.employeeType
            $ImportCheck.description | Should -Be $NewUserInfo.description
            $ImportCheck.location | Should -Be $NewUserInfo.location
            $ImportCheck.alternateEmail | Should -Be $NewUserInfo.alternateEmail
            $ImportCheck.recoveryEmail | Should -Be $NewUserInfo.recoveryEmail.address

            $ImportCheck.mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

        }
    }

    It "Imports users from a CSV populated with telephony, location, user information attributes, group additions, system binding, and custom attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $user2RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomString)"
                "preferredName"      = "$($user1RandomString)"
                "jobTitle"           = "$($user1RandomString)"
                "employeeIdentifier" = "eid$($user1RandomString)"
                "alternateEmail"     = "deleteme$($user1RandomString)ae@testimportcsvuser.com"
                "recoveryEmail"      = "deleteme$($user1RandomString)re@testimportcsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomString)maid@testimportcsvuser.com"
                "department"         = "$($user1RandomString)"
                "costCenter"         = "$($user1RandomString)"
                "company"            = "$($user1RandomString)"
                "employeeType"       = "$($user1RandomString)"
                "description"        = "$($user1RandomString)"
                "location"           = "$($user1RandomString)"
                "home_streetAddress" = "$($user1RandomString)"
                "home_poBox"         = "$($user1RandomString)"
                "home_city"          = "$($user1RandomString)"
                "home_state"         = "$($user1RandomString)"
                "home_postalCode"    = "$($user1RandomString)"
                "home_country"       = "$($user1RandomString)"
                "work_streetAddress" = "$($user1RandomString)"
                "work_poBox"         = "$($user1RandomString)"
                "work_city"          = "$($user1RandomString)"
                "work_state"         = "$($user1RandomString)"
                "work_postalCode"    = "$($user1RandomString)"
                "work_country"       = "$($user1RandomString)"
                "mobile_number"      = "$($user1RandomString)"
                "home_number"        = "$($user1RandomString)"
                "work_number"        = "$($user1RandomString)"
                "work_mobile_number" = "$($user1RandomString)"
                "work_fax_number"    = "$($user1RandomString)"
                "SystemID"           = ""
                "Administrator"      = ""
                "Group1"             = ""
                "Group2"             = ""
                "Group3"             = ""
                "Attribute1_name"    = "attr1"
                "Attribute1_value"   = "one"
                "Attribute2_name"    = "attr2"
                "Attribute2_value"   = "two"
            },
            @{
                "FirstName"          = "delete$($user2RandomString)"
                "LastName"           = "me$($user2RandomString)"
                "Username"           = "delete.me$($user2RandomString)"
                "Email"              = "deleteme$($user2RandomString)@testimportcsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomString)"
                "preferredName"      = "$($user2RandomString)"
                "jobTitle"           = "$($user2RandomString)"
                "employeeIdentifier" = "eid$($user2RandomString)"
                "alternateEmail"     = "deleteme$($user2RandomString)ae@testimportcsvuser.com"
                "recoveryEmail"      = "deleteme$($user2RandomString)re@testimportcsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomString)maid@testimportcsvuser.com"
                "department"         = "$($user2RandomString)"
                "costCenter"         = "$($user2RandomString)"
                "company"            = "$($user2RandomString)"
                "employeeType"       = "$($user2RandomString)"
                "description"        = "$($user2RandomString)"
                "location"           = "$($user2RandomString)"
                "home_streetAddress" = "$($user2RandomString)"
                "home_poBox"         = "$($user2RandomString)"
                "home_city"          = "$($user2RandomString)"
                "home_state"         = "$($user2RandomString)"
                "home_postalCode"    = "$($user2RandomString)"
                "home_country"       = "$($user2RandomString)"
                "work_streetAddress" = "$($user2RandomString)"
                "work_poBox"         = "$($user2RandomString)"
                "work_city"          = "$($user2RandomString)"
                "work_state"         = "$($user2RandomString)"
                "work_postalCode"    = "$($user2RandomString)"
                "work_country"       = "$($user2RandomString)"
                "mobile_number"      = "$($user2RandomString)"
                "home_number"        = "$($user2RandomString)"
                "work_number"        = "$($user2RandomString)"
                "work_mobile_number" = "$($user2RandomString)"
                "work_fax_number"    = "$($user2RandomString)"
                "SystemID"           = ""
                "Administrator"      = ""
                "Group1"             = ""
                "Group2"             = ""
                "Group3"             = ""
                "Attribute1_name"    = "attr1"
                "Attribute1_value"   = "one"
                "Attribute2_name"    = "attr2"
                "Attribute2_value"   = "two"
            }
        )
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom_import.csv" -Force

        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom_import.csv"
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom_import.csv" -force

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -Be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -Be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -Be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -Be $NewUserInfo.employeeIdentifier
            $ImportCheck.alternateEmail | Should -Be $NewUserInfo.alternateEmail
            $ImportCheck.recoveryEmail | Should -Be $NewUserInfo.recoveryEmail.address
            # TODO: Dynamically populate manager
            # $ImportCheck.manager | Should -Be $NewUserInfo.manager
            $ImportCheck.managedAppleId | Should -Be $NewUserInfo.managedAppleId
            $ImportCheck.department | Should -Be $NewUserInfo.department
            $ImportCheck.costCenter | Should -Be $NewUserInfo.costCenter
            $ImportCheck.company | Should -Be $NewUserInfo.company
            $ImportCheck.employeeType | Should -Be $NewUserInfo.employeeType
            $ImportCheck.description | Should -Be $NewUserInfo.description
            $ImportCheck.location | Should -Be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -Be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -Be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

            # TODO: Add these back when we've auto added groups/ systems
            # $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty systemAdd | Should -Be "Added"
            # $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty GroupsAdd | Select-Object Status -Unique | Select-Object -ExpandProperty Status | Should -Be "Added"
        }
    }
    It "Imports a new user from a CSV with a null custom attribute should throw" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @{
            "FirstName"        = "delete$($user1RandomString)"
            "LastName"         = "me$($user1RandomString)"
            "Username"         = "delete.me$($user1RandomString)"
            "Email"            = "deleteme$($user1RandomString)@testimportcsvuser.com"
            "Password"         = "$(New-RandomString -NumberOfChars 8)@#7Ah"
            "Attribute1_name"  = "9837"
            "Attribute1_value" = ""
        }
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_missingAttribute.csv" -Force

        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_missingAttribute.csv"
        { Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_missingAttribute.csv" -force } | Should -Throw

    }

}
Describe -Tag:('JCUsersFromCSV') 'MFA Import Tests' {
    It "New User Created with MFA Required" {
        # Setup Test
        $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
        $CSVDATA = @{
            Username                       = $user.username
            LastName                       = $user.LastName
            FirstName                      = $user.FirstName
            Email                          = $user.Email
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = ''
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/MFA_Import.csv" -Force
        Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/MFA_Import.csv" -force
        # Test Imported User
        $MFAUser = Get-JCUser $user.Username
        $MFAUser.mfa.exclusion | Should -Be $True
        $MFAUser.mfa.exclusionUntil | Should -BeOfType [datetime]
        $MFAUser.mfa.configured | Should -Be $false
    }
    It "New User Created with MFA Required and Enrollment Period Specified" {
        # Setup Test
        $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
        $today = Get-Date
        $EnrollmentDays = 14
        $CSVDATA = @{
            Username                       = $user.username
            LastName                       = $user.LastName
            FirstName                      = $user.FirstName
            Email                          = $user.Email
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = $EnrollmentDays
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/MFA_Import.csv" -Force
        # Sleep one second before importing span should be 14 days:
        Start-Sleep 1
        Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/MFA_Import.csv" -force
        # Test Imported User
        $MFAUser = Get-JCUser $user.Username
        $MFAUser.mfa.exclusion | Should -Be $True
        $MFAUser.mfa.exclusionUntil | Should -BeOfType [datetime]
        $span = New-TimeSpan -Start $today -End $MFAUser.mfa.exclusionUntil
        $span.Days | Should -Be $EnrollmentDays
        $MFAUser.mfa.configured | Should -Be $false
    }
    It "Throw error if user create with invalid enrollment days" {
        $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
        $CSVDATA = @{
            Username                       = $user.username
            LastName                       = $user.LastName
            FirstName                      = $user.FirstName
            Email                          = $user.Email
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = (Get-Date).addDays(14)
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/MFA_Import.csv" -Force
        $ImportStatus = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/MFA_Import.csv" -force
        # Test Imported User
        $ImportStatus.Status | Should -Match "Cannot bind parameter"
    }
    AfterAll {
        Get-JCUser | Where-Object Email -like *ImportCSVUser.* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUsersFromCSV') 'LDAP Import Tests' {
    It "New User Created and bound to LDAP server" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
        $CSVDATA = @{
            Username          = $user.username
            LastName          = $user.LastName
            FirstName         = $user.FirstName
            Email             = $user.Email
            ldapserver_id     = $ldapServer.id
            ldap_binding_user = ''
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/Ldap_Import.csv" -Force
        $ImportStatus = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/Ldap_Import.csv" -force
        $LDAPUser = Get-JCuser $user.username
        $LDAPUser | should -Not -BeNullOrEmpty
        $ldapAssociation = Get-JCAssociation -Type user -Name $LDAPUser.username -TargetType ldap_server
        $ldapAssociation | should -Not -BeNullOrEmpty
        $LDAPUser.ldap_binding_user | should -Be $False
    }
    It "New User created, bound to LDAP server and set as an Ldap Binding User" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
        $CSVDATA = @{
            Username          = $user.username
            LastName          = $user.LastName
            FirstName         = $user.FirstName
            Email             = $user.Email
            ldapserver_id     = $ldapServer.id
            ldap_binding_user = $true
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/Ldap_Import.csv" -Force
        $ImportStatus = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/Ldap_Import.csv" -force
        $LDAPUser = Get-JCuser $user.username
        $LDAPUser | should -Not -BeNullOrEmpty
        $ldapAssociation = Get-JCAssociation -Type user -Name $LDAPUser.username -TargetType ldap_server
        $ldapAssociation | should -Not -BeNullOrEmpty
        $LDAPUser.ldap_binding_user | should -Be $true
    }
    It "throw error with invalid params on ldap import" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
        $CSVDATA = @{
            Username          = $user.username
            LastName          = $user.LastName
            FirstName         = $user.FirstName
            Email             = $user.Email
            ldapserver_id     = "$($ldapServer.id)"
            ldap_binding_user = "yes"
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/Ldap_Import.csv" -Force
        $importStatus = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/Ldap_Import.csv" -force
        $LDAPUser = Get-JCuser $user.username
        $LDAPUser | should -Not -BeNullOrEmpty
        $ldapAssociation = Get-JCAssociation -Type user -Name $LDAPUser.username -TargetType ldap_server
        $ldapAssociation | should -Not -BeNullOrEmpty
        $LDAPUser.ldap_binding_user | should -Be $false
        $importStatus.LdapUserBind | Should -Match "not recognized as a valid Boolean"
    }

}
Describe -Tag:('JCUsersFromCSV') "Import-JCUsersFromCSV 2.5.1" {
    Context "Custom Attribute API error should be returned" {
        It "When a custom attribute name has a space in the field, the API should return an error message in the status field" {
            $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
            $today = Get-Date
            $EnrollmentDays = 14
            $CSVDATA = @{
                Username         = $user.username
                LastName         = $user.LastName
                FirstName        = $user.FirstName
                Email            = $user.Email
                Attribute1_name  = "bad value"
                Attribute1_value = "string"
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/custom_attribute.csv" -Force
            $importResults = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/custom_attribute.csv" -force
            $importResults[0].AdditionalInfo | Should -Match "Attribute names may not contain spaces"
        }
        It "When a custom attribute name has a non-alphanumeric in the field, the API should return an error message in the status field" {
            $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
            $today = Get-Date
            $EnrollmentDays = 14
            $CSVDATA = @{
                Username         = $user.username
                LastName         = $user.LastName
                FirstName        = $user.FirstName
                Email            = $user.Email
                Attribute1_name  = "bad.value"
                Attribute1_value = "string"
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/custom_attribute.csv" -Force
            $importResults = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/custom_attribute.csv" -force
            $importResults[0].AdditionalInfo | Should -Match "Attribute names may only contain letters and numbers"
        }
    }
}

Describe -Tag:('JCUsersFromCSV') "Import-JCUsersFromCSV 2.14.2" {
    Context "Import-JCUsersFromCSV with empty custom attribute" {
        It "When there are custom attributes with empty names and values, the API should not return an error message in the status field and continue to import the user" {
            $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
            $today = Get-Date
            $EnrollmentDays = 14
            $CSVDATA = @{
                Username         = $user.username
                LastName         = $user.LastName
                FirstName        = $user.FirstName
                Email            = $user.Email
                Attribute1_name  = "Name"
                Attribute1_value = "Value"
                Attribute2_name  = ""
                Attribute2_value = ""
                Attribute3_name  = "Name1"
                Attribute3_value = "Value1"
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/custom_attribute.csv" -Force
            $importResults = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/custom_attribute.csv" -force
            # ImportResults should not be error
            $importResults[0].Status | Should -Match "User Created"
        }
    }
}
Describe -Tag:('JCUsersFromCSV') "Import-JCUsersFromCSV 2.15.1" {
    Context "Import-JCUsersFromCSV with 10 or more custom attributes" {
        It "When there are 10 or more custom attributes, the API should not return an error message in the status field and continue to import the user" {
            $user = New-RandomUser -Domain "ImportCSVUser.$(New-RandomString -NumberOfChars 5)"
            $today = Get-Date
            $EnrollmentDays = 14
            $CSVDATA = @{
                Username          = $user.username
                LastName          = $user.LastName
                FirstName         = $user.FirstName
                Email             = $user.Email
                Attribute1_name   = "Name"
                Attribute1_value  = "Value"
                Attribute2_name   = "Name1"
                Attribute2_value  = "Value1"
                Attribute3_name   = "Name2"
                Attribute3_value  = "Value2"
                Attribute4_name   = "Name3"
                Attribute4_value  = "Value3"
                Attribute5_name   = "Name4"
                Attribute5_value  = "Value4"
                Attribute6_name   = "Name5"
                Attribute6_value  = "Value5"
                Attribute7_name   = "Name6"
                Attribute7_value  = "Value6"
                Attribute8_name   = "Name7"
                Attribute8_value  = "Value7"
                Attribute9_name   = "Name8"
                Attribute9_value  = "Value8"
                Attribute10_name  = "Name9"
                Attribute10_value = "Value9"
                Attribute11_name  = "Name10"
                Attribute11_value = "Value10"
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/custom_attribute.csv" -Force
            $importResults = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/custom_attribute.csv" -force
            # ImportResults should not be error
            $importResults[0].Status | Should -Match "User Created"
        }
    }
}

AfterAll {
    Get-JCUser | Where-Object Email -like *testimportcsvuser* | Remove-JCUser -force
}