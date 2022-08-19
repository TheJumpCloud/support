Describe -Tag:('JCUsersFromCSV') "Update-JCUsersFromCSV 1.8.0" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Updates users from a CSV populated with telephony attributes" {

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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_telephonyAttributes.csv" -force
        $UserUpdateInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_telephonyAttributes.csv"

        foreach ($UpdateUser in $UserUpdateCSVImport) {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.mobile_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -Be $($UpdateUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)
        }
    }


    It "Updates users from a CSV populated with information attributes" {

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
            $ImportCheck.decription | Should -Be $NewUserInfo.decription
            $ImportCheck.location | Should -Be $NewUserInfo.location

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_userInformationAttributes.csv" -force
        $UserUpdateInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_userInformationAttributes.csv"

        foreach ($UpdateUser in $UserUpdateCSVImport) {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

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

        }
    }


    It "Updates users from a CSV populated with user location attributes" {
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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_userLocationAttributes.csv" -force
        $UserUpdateInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_userLocationAttributes.csv"

        foreach ($UpdateUser in $UserCSVUpdate) {
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

        }

    }

    It "Updates users from a CSV populated with user telephony, information, and location attributes" {

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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_AllNewAttributes.csv" -force
        $UserUpdateInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_AllNewAttributes.csv"

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

    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
    It "Updates users from a CSV populated with uid/ gid attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_uid_guid.csv" -force
        $UserCSVUpdate = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_uid_guid.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_UpdatePath/UpdateExample_uid_guid.csv"

        foreach ($User in $UserCSVUpdate) {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.unix_uid | Should -Be $($NewUserInfo.unix_uid)
            $ImportCheck.unix_guid | Should -Be $($NewUserInfo.unix_guid)
        }
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }

    It "Updates users from a CSV populated with no information" {

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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateExample_NoChanges.csv" -force

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
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUsersFromCSV') 'MFA Update Tests' {
    It "User Created/ Updated with Update-JCUserFromCSV with MFA Required" {
        # Setup Test
        $user = New-RandomUser -Domain pleasedelete | New-JCUser
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
        $user = New-RandomUser -Domain pleasedelete | New-JCUser
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
        $user = New-RandomUser -Domain pleasedelete | New-JCUser
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
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUsersFromCSV') 'LDAP Update Tests' {
    It "New User updated and bound to LDAP server" {
        $ldapServer = Get-JcSdkLdapServer
        $user = New-RandomUser -Domain pleasedelete | New-JCUser
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
        $user = New-RandomUser -Domain pleasedelete | New-JCUser
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
        $user = New-RandomUser -Domain pleasedelete | New-JCUser
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
    AfterAll {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}