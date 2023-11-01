Describe -Tag:('JCUsersFromCSV') "Update-JCUsersFromCSV 1.8.0" {
    BeforeAll {  }

    It "Updates users from a CSV populated with all information" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $user2RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomString)"
                "preferredName"      = "$($user1RandomString)"
                "jobTitle"           = "$($user1RandomString)"
                "employeeIdentifier" = "eid$($user1RandomString)"
                "alternateEmail"     = "deleteme$($user1RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomString)maid@testupdatecsvuser.com"
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
                "Email"              = "deleteme$($user2RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomString)"
                "preferredName"      = "$($user2RandomString)"
                "jobTitle"           = "$($user2RandomString)"
                "employeeIdentifier" = "eid$($user2RandomString)"
                "alternateEmail"     = "deleteme$($user2RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomString)maid@testupdatecsvuser.com"
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
        $user1RandomUpdateString = $(New-RandomString -NumberOfChars 5)
        $user2RandomUpdateString = $(New-RandomString -NumberOfChars 5)
        $CSVUpdateData = @(
            @{
                "FirstName"          = "delete$($user1RandomUpdateString)"
                "LastName"           = "me$($user1RandomUpdateString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomUpdateString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomUpdateString)"
                "preferredName"      = "$($user1RandomUpdateString)"
                "jobTitle"           = "$($user1RandomUpdateString)"
                "employeeIdentifier" = "eid$($user1RandomUpdateString)"
                "alternateEmail"     = "deleteme$($user1RandomUpdateString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomUpdateString)maid@testupdatecsvuser.com"
                "department"         = "$($user1RandomUpdateString)"
                "costCenter"         = "$($user1RandomUpdateString)"
                "company"            = "$($user1RandomUpdateString)"
                "employeeType"       = "$($user1RandomUpdateString)"
                "description"        = "$($user1RandomUpdateString)"
                "location"           = "$($user1RandomUpdateString)"
                "home_streetAddress" = "$($user1RandomUpdateString)"
                "home_poBox"         = "$($user1RandomUpdateString)"
                "home_city"          = "$($user1RandomUpdateString)"
                "home_state"         = "$($user1RandomUpdateString)"
                "home_postalCode"    = "$($user1RandomUpdateString)"
                "home_country"       = "$($user1RandomUpdateString)"
                "work_streetAddress" = "$($user1RandomUpdateString)"
                "work_poBox"         = "$($user1RandomUpdateString)"
                "work_city"          = "$($user1RandomUpdateString)"
                "work_state"         = "$($user1RandomUpdateString)"
                "work_postalCode"    = "$($user1RandomUpdateString)"
                "work_country"       = "$($user1RandomUpdateString)"
                "mobile_number"      = "$($user1RandomUpdateString)"
                "home_number"        = "$($user1RandomUpdateString)"
                "work_number"        = "$($user1RandomUpdateString)"
                "work_mobile_number" = "$($user1RandomUpdateString)"
                "work_fax_number"    = "$($user1RandomUpdateString)"
            },
            @{
                "FirstName"          = "delete$($user2RandomUpdateString)"
                "LastName"           = "me$($user2RandomUpdateString)"
                "Username"           = "delete.me$($user2RandomString)"
                "Email"              = "deleteme$($user2RandomUpdateString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomUpdateString)"
                "preferredName"      = "$($user2RandomUpdateString)"
                "jobTitle"           = "$($user2RandomUpdateString)"
                "employeeIdentifier" = "eid$($user2RandomUpdateString)"
                "alternateEmail"     = "deleteme$($user2RandomUpdateString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomUpdateString)maid@testupdatecsvuser.com"
                "department"         = "$($user2RandomUpdateString)"
                "costCenter"         = "$($user2RandomUpdateString)"
                "company"            = "$($user2RandomUpdateString)"
                "employeeType"       = "$($user2RandomUpdateString)"
                "description"        = "$($user2RandomUpdateString)"
                "location"           = "$($user2RandomUpdateString)"
                "home_streetAddress" = "$($user2RandomUpdateString)"
                "home_poBox"         = "$($user2RandomUpdateString)"
                "home_city"          = "$($user2RandomUpdateString)"
                "home_state"         = "$($user2RandomUpdateString)"
                "home_postalCode"    = "$($user2RandomUpdateString)"
                "home_country"       = "$($user2RandomUpdateString)"
                "work_streetAddress" = "$($user2RandomUpdateString)"
                "work_poBox"         = "$($user2RandomUpdateString)"
                "work_city"          = "$($user2RandomUpdateString)"
                "work_state"         = "$($user2RandomUpdateString)"
                "work_postalCode"    = "$($user2RandomUpdateString)"
                "work_country"       = "$($user2RandomUpdateString)"
                "mobile_number"      = "$($user2RandomUpdateString)"
                "home_number"        = "$($user2RandomUpdateString)"
                "work_number"        = "$($user2RandomUpdateString)"
                "work_mobile_number" = "$($user2RandomUpdateString)"
                "work_fax_number"    = "$($user2RandomUpdateString)"
            }
        )
        # export the files
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/UpdateWithInfoNoAttributeTest.csv" -Force
        $CSVUpdateData | Export-Csv "$PesterParams_UpdatePath/UpdateWithInfoNoAttributeNewTest.csv" -Force
        # import the users
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/UpdateWithInfoNoAttributeTest.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/UpdateWithInfoNoAttributeTest.csv"
        # test import
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
            $ImportCheck.decription | Should -Be $NewUserInfo.decription
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

        }
        # update the users
        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateWithInfoNoAttributeNewTest.csv" -force
        $UserUpdateInfo = Import-Csv "$PesterParams_UpdatePath/UpdateWithInfoNoAttributeNewTest.csv"
        # test the upadate
        foreach ($UpdateUser in $UserUpdateCSVImport) {

            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

            $UpdateCheck.MiddleName | Should -Be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -Be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -Be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -Be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -Be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -Be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -Be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -Be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -Be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -Be $UpdateUserInfo.location

            $UpdateCheck.mobile_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)
        }
    }

    It "Updates users from a CSV populated with user telephony, information, and location attributes and custom attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $user2RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomString)"
                "preferredName"      = "$($user1RandomString)"
                "jobTitle"           = "$($user1RandomString)"
                "employeeIdentifier" = "eid$($user1RandomString)"
                "alternateEmail"     = "deleteme$($user1RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomString)maid@testupdatecsvuser.com"
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
                "Email"              = "deleteme$($user2RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomString)"
                "preferredName"      = "$($user2RandomString)"
                "jobTitle"           = "$($user2RandomString)"
                "employeeIdentifier" = "eid$($user2RandomString)"
                "alternateEmail"     = "deleteme$($user2RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomString)maid@testupdatecsvuser.com"
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
        $user1RandomUpdateString = $(New-RandomString -NumberOfChars 5)
        $user2RandomUpdateString = $(New-RandomString -NumberOfChars 5)
        $CSVDataNoInfo = @(
            @{
                "FirstName"          = "delete$($user1RandomUpdateString)"
                "LastName"           = "me$($user1RandomUpdateString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomUpdateString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomUpdateString)"
                "preferredName"      = "$($user1RandomUpdateString)"
                "jobTitle"           = "$($user1RandomUpdateString)"
                "employeeIdentifier" = "eid$($user1RandomUpdateString)"
                "alternateEmail"     = "deleteme$($user1RandomUpdateString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomUpdateString)maid@testupdatecsvuser.com"
                "department"         = "$($user1RandomUpdateString)"
                "costCenter"         = "$($user1RandomUpdateString)"
                "company"            = "$($user1RandomUpdateString)"
                "employeeType"       = "$($user1RandomUpdateString)"
                "description"        = "$($user1RandomUpdateString)"
                "location"           = "$($user1RandomUpdateString)"
                "home_streetAddress" = "$($user1RandomUpdateString)"
                "home_poBox"         = "$($user1RandomUpdateString)"
                "home_city"          = "$($user1RandomUpdateString)"
                "home_state"         = "$($user1RandomUpdateString)"
                "home_postalCode"    = "$($user1RandomUpdateString)"
                "home_country"       = "$($user1RandomUpdateString)"
                "work_streetAddress" = "$($user1RandomUpdateString)"
                "work_poBox"         = "$($user1RandomUpdateString)"
                "work_city"          = "$($user1RandomUpdateString)"
                "work_state"         = "$($user1RandomUpdateString)"
                "work_postalCode"    = "$($user1RandomUpdateString)"
                "work_country"       = "$($user1RandomUpdateString)"
                "mobile_number"      = "$($user1RandomUpdateString)"
                "home_number"        = "$($user1RandomUpdateString)"
                "work_number"        = "$($user1RandomUpdateString)"
                "work_mobile_number" = "$($user1RandomUpdateString)"
                "work_fax_number"    = "$($user1RandomUpdateString)"
                "SystemID"           = ""
                "Administrator"      = ""
                "Group1"             = ""
                "Group2"             = ""
                "Group3"             = ""
                "Attribute1_name"    = "attr1"
                "Attribute1_value"   = "newAttr1"
                "Attribute2_name"    = "attr2"
                "Attribute2_value"   = "newAttr2"
            },
            @{
                "FirstName"          = "delete$($user2RandomString)"
                "LastName"           = "me$($user2RandomString)"
                "Username"           = "delete.me$($user2RandomString)"
                "Email"              = "deleteme$($user2RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomString)"
                "preferredName"      = "$($user2RandomString)"
                "jobTitle"           = "$($user2RandomString)"
                "employeeIdentifier" = "eid$($user2RandomString)"
                "alternateEmail"     = "deleteme$($user2RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomString)maid@testupdatecsvuser.com"
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
                "Attribute1_value"   = "brandNew1"
                "Attribute2_name"    = "attr2"
                "Attribute2_value"   = "brandNew2"
            }
        )
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom.csv" -Force
        $CSVDataNoInfo | Export-Csv "$PesterParams_UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv" -Force
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -Be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -Be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -Be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -Be $NewUserInfo.employeeIdentifier
            $ImportCheck.alternateEmail | Should -Be $NewUserInfo.alternateEmail
            # TODO: Dynamically populate manager
            # $ImportCheck.manager | Should -Be $NewUserInfo.manager            $ImportCheck.managedAppleId | Should -Be $NewUserInfo.managedAppleId
            $ImportCheck.department | Should -Be $NewUserInfo.department
            $ImportCheck.costCenter | Should -Be $NewUserInfo.costCenter
            $ImportCheck.company | Should -Be $NewUserInfo.company
            $ImportCheck.employeeType | Should -Be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -Be $NewUserInfo.decription
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

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv" -force
        $UserUpdateInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv"

        foreach ($UpdateUser in $UserUpdateCSVImport) {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"
            # TODO: Add back in when we auto create groups for this test
            # $GroupSysCheck = $UserUpdateCSVImport | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -Be $($UpdateUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

            $UpdateCheck.MiddleName | Should -Be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -Be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -Be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -Be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.alternateEmail | Should -Be $UpdateUserInfo.alternateEmail
            # TODO: Dynamically populate manager
            # $ImportCheck.manager | Should -Be $NewUserInfo.manager            $UpdateCheck.managedAppleId | Should -Be $UpdateUserInfo.managedAppleId
            $UpdateCheck.department | Should -Be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -Be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -Be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -Be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -Be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -Be $UpdateUserInfo.location

            $UpdateCheck.mobile_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)

            # TODO: Add back in when we auto gen systems/ groups before tests
            # $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty systemAdd | Should -Be '{"message":"Already Exists"}'
            # $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty GroupsAdd | Select-Object Status -Unique | Select-Object -ExpandProperty Status | Should -Be "Added"
        }
    }

    It "Updates users from a CSV populated with uid/ gid attributes" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $user2RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @{
            "FirstName" = "delete$($user1RandomString)"
            "LastName"  = "me$($user1RandomString)"
            "Username"  = "delete.me$($user1RandomString)"
            "Email"     = "deleteme$($user1RandomString)@testupdatecsvuser.com"
            "Password"  = "$(New-RandomString -NumberOfChars 8)@#7Ah"
            "unix_guid" = "9837"
            "unix_uid"  = "9837"
        }
        $CSVUpdateData = @{
            "FirstName" = "delete$($user1RandomString)"
            "LastName"  = "me$($user1RandomString)"
            "Username"  = "delete.me$($user1RandomString)"
            "Email"     = "deleteme$($user1RandomString)@testupdatecsvuser.com"
            "Password"  = "$(New-RandomString -NumberOfChars 8)@#7Ah"
            "unix_guid" = "9911"
            "unix_uid"  = "9911"
        }
        $CSVDATA | Export-Csv "$PesterParams_ImportPath/ImportExample_uid_guid.csv" -Force
        $CSVUpdateData | Export-Csv "$PesterParams_UpdatePath/UpdateExample_uid_guid.csv" -Force

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_uid_guid.csv" -force
        $UserCSVUpdate = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_uid_guid.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_uid_guid.csv"

        foreach ($User in $UserCSVUpdate) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.unix_uid | Should -Be $($NewUserInfo.unix_uid)
            $ImportCheck.unix_guid | Should -Be $($NewUserInfo.unix_guid)
        }
        Get-JCUser | Where-Object Email -like *UpdateCSVUser* | Remove-JCUser -force
    }

    It "Updates users from a CSV populated with no information" {
        $user1RandomString = $(New-RandomString -NumberOfChars 5)
        $user2RandomString = $(New-RandomString -NumberOfChars 5)
        $CSVData = @(
            @{
                "FirstName"          = "delete$($user1RandomString)"
                "LastName"           = "me$($user1RandomString)"
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = "deleteme$($user1RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user1RandomString)"
                "preferredName"      = "$($user1RandomString)"
                "jobTitle"           = "$($user1RandomString)"
                "employeeIdentifier" = "eid$($user1RandomString)"
                "alternateEmail"     = "deleteme$($user1RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user1RandomString)maid@testupdatecsvuser.com"
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
                "Email"              = "deleteme$($user2RandomString)@testupdatecsvuser.com"
                "Password"           = "$(New-RandomString -NumberOfChars 8)@#7Ah"
                "MiddleName"         = "$($user2RandomString)"
                "preferredName"      = "$($user2RandomString)"
                "jobTitle"           = "$($user2RandomString)"
                "employeeIdentifier" = "eid$($user2RandomString)"
                "alternateEmail"     = "deleteme$($user2RandomString)ae@testupdatecsvuser.com"
                "manager"            = ""
                "managedAppleID"     = "deleteme$($user2RandomString)maid@testupdatecsvuser.com"
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
        $CSVDataNoInfo = @(
            @{
                "FirstName"          = ""
                "LastName"           = ""
                "Username"           = "delete.me$($user1RandomString)"
                "Email"              = ""
                "Password"           = ""
                "MiddleName"         = ""
                "preferredName"      = ""
                "jobTitle"           = ""
                "employeeIdentifier" = ""
                "alternateEmail"     = ""
                "manager"            = ""
                "managedAppleID"     = ""
                "department"         = ""
                "costCenter"         = ""
                "company"            = ""
                "employeeType"       = ""
                "description"        = ""
                "location"           = ""
                "home_streetAddress" = ""
                "home_poBox"         = ""
                "home_city"          = ""
                "home_state"         = ""
                "home_postalCode"    = ""
                "home_country"       = ""
                "work_streetAddress" = ""
                "work_poBox"         = ""
                "work_city"          = ""
                "work_state"         = ""
                "work_postalCode"    = ""
                "work_country"       = ""
                "mobile_number"      = ""
                "home_number"        = ""
                "work_number"        = ""
                "work_mobile_number" = ""
                "work_fax_number"    = ""
                "SystemID"           = ""
                "Administrator"      = ""
                "Group1"             = ""
                "Group2"             = ""
                "Group3"             = ""
                "Attribute1_name"    = ""
                "Attribute1_value"   = ""
                "Attribute2_name"    = ""
                "Attribute2_value"   = ""
            },
            @{
                "FirstName"          = ""
                "LastName"           = ""
                "Username"           = "delete.me$($user2RandomString)"
                "Email"              = ""
                "Password"           = ""
                "MiddleName"         = ""
                "preferredName"      = ""
                "jobTitle"           = ""
                "employeeIdentifier" = ""
                "alternateEmail"     = ""
                "manager"            = ""
                "managedAppleID"     = ""
                "department"         = ""
                "costCenter"         = ""
                "company"            = ""
                "employeeType"       = ""
                "description"        = ""
                "location"           = ""
                "home_streetAddress" = ""
                "home_poBox"         = ""
                "home_city"          = ""
                "home_state"         = ""
                "home_postalCode"    = ""
                "home_country"       = ""
                "work_streetAddress" = ""
                "work_poBox"         = ""
                "work_city"          = ""
                "work_state"         = ""
                "work_postalCode"    = ""
                "work_country"       = ""
                "mobile_number"      = ""
                "home_number"        = ""
                "work_number"        = ""
                "work_mobile_number" = ""
                "work_fax_number"    = ""
                "SystemID"           = ""
                "Administrator"      = ""
                "Group1"             = ""
                "Group2"             = ""
                "Group3"             = ""
                "Attribute1_name"    = ""
                "Attribute1_value"   = ""
                "Attribute2_name"    = ""
                "Attribute2_value"   = ""
            }
        )
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/UpdateWithInfoTest.csv" -Force
        $CSVDataNoInfo | Export-Csv "$PesterParams_UpdatePath/UpdateWithNoInfoTest.csv" -Force
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateWithInfoTest.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_UpdatePath/UpdateWithInfoTest.csv"

        foreach ($User in $UserCSVImport) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -Be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -Be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -Be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -Be $NewUserInfo.employeeIdentifier
            $ImportCheck.alternateEmail | Should -Be $NewUserInfo.alternateEmail
            # TODO: Dynamically populate manager
            # $ImportCheck.manager | Should -Be $NewUserInfo.manager            $ImportCheck.managedAppleId | Should -Be $NewUserInfo.managedAppleId
            $ImportCheck.department | Should -Be $NewUserInfo.department
            $ImportCheck.costCenter | Should -Be $NewUserInfo.costCenter
            $ImportCheck.company | Should -Be $NewUserInfo.company
            $ImportCheck.employeeType | Should -Be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -Be $NewUserInfo.decription
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
        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateWithNoInfoTest.csv" -force

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
            $ImportCheck.decription | Should -Be $NewUserInfo.decription
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
        }
    }

    It "Updates a new user from a CSV with a null custom attribute should throw" {
        # Get an existing user:
        $user = Get-JCUser -username $PesterParams_NewUser1.Username
        $CSVDATA = @{
            Username         = $user.username
            Attribute1_name  = '9898'
            Attribute1_value = ''
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/UpdateExample_missingAttribute.csv"
        { Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_missingAttribute.csv" -force } | Should -Throw
    }
}
Describe -Tag:('JCUsersFromCSV') 'MFA Update Tests' {
    It "User Created/ Updated with Update-JCUserFromCSV with MFA Required" {
        # Setup Test
        $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $CSVDATA = @{
            Username                       = $user.username
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = ''
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/MFA_Update.csv" -Force
        $MFAUser = Get-JCUser $user.Username
        $MFAUser.mfa.exclusion | Should -Be $false
        $MFAUser.mfa.configured | Should -Be $false
        # Test Imported User
        Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/MFA_Update.csv" -force
        $MFAUser = Get-JCUser $user.Username
        $MFAUser.mfa.exclusion | Should -Be $True
        $MFAUser.mfa.exclusionUntil | Should -BeOfType [datetime]
        $MFAUser.mfa.configured | Should -Be $false
    }
    It "New User Created with MFA Required and Enrollment Period Specified" {
        # Setup Test
        $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $today = Get-Date
        $EnrollmentDays = 14
        $CSVDATA = @{
            Username                       = $user.username
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = $EnrollmentDays
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/MFA_Update.csv" -Force
        # Sleep one second before importing span should be 14 days:
        Start-Sleep 1
        $MFAUser = Get-JCUser $user.Username
        $MFAUser.mfa.exclusion | Should -Be $false
        $MFAUser.mfa.configured | Should -Be $false
        # Test Imported User
        Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/MFA_Update.csv" -force
        $MFAUser = Get-JCUser $user.Username
        $MFAUser.mfa.exclusion | Should -Be $True
        $MFAUser.mfa.exclusionUntil | Should -BeOfType [datetime]
        $span = New-TimeSpan -Start $today -End $MFAUser.mfa.exclusionUntil
        $span.Days | Should -Be $EnrollmentDays
        $MFAUser.mfa.configured | Should -Be $false
    }
    It "Throw error if user updated with invalid enrollment days" {
        $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $CSVDATA = @{
            Username                       = $user.username
            enable_user_portal_multifactor = $true
            EnrollmentDays                 = (Get-Date).addDays(14)
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/MFA_Update.csv" -Force
        $ImportStatus = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/MFA_Update.csv" -force
        # Test Imported User
        $ImportStatus.Status | Should -Match "Cannot bind parameter"
    }
    AfterAll {
        Get-JCUser | Where-Object Email -like *UpdateCSVUser* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUsersFromCSV') 'LDAP Update Tests' {
    It "New User updated and bound to LDAP server" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $CSVDATA = @{
            Username          = $user.username
            ldapserver_id     = $ldapServer.id
            ldap_binding_user = ''
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/Ldap_Update.csv" -Force
        $UpdateStatus = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/Ldap_Update.csv" -force
        $LDAPUser = Get-JCuser $user.username
        $LDAPUser | should -Not -BeNullOrEmpty
        $ldapAssociation = Get-JCAssociation -Type user -Name $LDAPUser.username -TargetType ldap_server
        $ldapAssociation | should -Not -BeNullOrEmpty
        $LDAPUser.ldap_binding_user | should -Be $False
    }
    It "New User Updated, bound to LDAP server and set as an Ldap Binding User" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $CSVDATA = @{
            Username          = $user.username
            ldapserver_id     = $ldapServer.id
            ldap_binding_user = $true
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/Ldap_Update.csv" -Force
        $UpdateStatus = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/Ldap_Update.csv" -force
        $LDAPUser = Get-JCuser $user.username
        $LDAPUser | should -Not -BeNullOrEmpty
        $ldapAssociation = Get-JCAssociation -Type user -Name $LDAPUser.username -TargetType ldap_server
        $ldapAssociation | should -Not -BeNullOrEmpty
        $LDAPUser.ldap_binding_user | should -Be $true
    }
    It "throw error with invalid params on ldap import" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
        $CSVDATA = @{
            Username          = $user.username
            ldapserver_id     = "$($ldapServer.id)"
            ldap_binding_user = "yes"
        }
        $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/Ldap_Update.csv" -Force
        $UpdateStatus = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/Ldap_Update.csv" -force
        $LDAPUser = Get-JCuser $user.username
        $LDAPUser | should -Not -BeNullOrEmpty
        $ldapAssociation = Get-JCAssociation -Type user -Name $LDAPUser.username -TargetType ldap_server
        $ldapAssociation | should -Not -BeNullOrEmpty
        $LDAPUser.ldap_binding_user | should -Be $false
        $UpdateStatus.LdapUserBind | Should -Match "not recognized as a valid Boolean"
    }
}

Describe -Tag:('JCUsersFromCSV') "Update-JCUsersFromCSV 2.5.1" {
    Context "Custom Attribute API error should be returned" {
        It "When a custom attribute name has a space in the field, the API should return an error message in the status field" {
            $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
            $CSVDATA = @{
                Username         = $user.username
                Attribute1_name  = "bad value"
                Attribute1_value = 'string'
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/custom_attribute.csv" -Force
            $UpdateStatus = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/custom_attribute.csv" -force
            # the error message should show that custom attribute names cannot contain spaces
            $UpdateStatus[0].status | Should -Match "Attribute names may not contain spaces"
            $UpdateStatus[0].status | Should -Not -Match "User does not exist"
        }
        It "When a custom attribute name has a non-alphanumeric in the field, the API should return an error message in the status field" {
            $user = New-RandomUser -Domain "TestCSVUser.$(New-RandomString -NumberOfChars 5)" | New-JCUser
            $CSVDATA = @{
                Username         = $user.username
                Attribute1_name  = "bad.value"
                Attribute1_value = 'string'
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_UpdatePath/custom_attribute.csv" -Force
            $UpdateStatus = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/custom_attribute.csv" -force
            # the error message should show that custom attribute names cannot contain spaces
            $UpdateStatus[0].status | Should -Match "Attribute names may only contain letters and numbers"
            $UpdateStatus[0].status | Should -Not -Match "User does not exist"
        }
        It "should fail" {
            "Test" | Should -be "fail"
        }
    }
}
AfterAll {
    Get-JCUser | Where-Object Email -like *testupdatecsvuser.com* | Remove-JCUser -force
}
