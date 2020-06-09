Describe -Tag:('JCUsersFromCSV') "Update-JCUsersFromCSV 1.8.0" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Updates users from a CSV populated with telephony attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_telephonyAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_telephonyAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -Be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)
        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_telephonyAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_telephonyAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {
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

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_userInformationAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_userInformationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_userInformationAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_userInformationAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {
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
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_userLocationAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_userLocationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_userLocationAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_userLocationAttributes.csv

        foreach ($UpdateUser in $UserCSVUpdate)
        {
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

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_allNewAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_allNewAttributes.csv

        foreach ($User in $UserCSVImport)
        {
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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_AllNewAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_AllNewAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {

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

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_allNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_allNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {

            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"
            $GroupSysCheck = $UserUpdateCSVImport | Where-Object Username -EQ "$($UpdateUser.username)"

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

            $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty systemAdd | Should -Be '{"message":"Already Exists"}'


            $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty GroupsAdd | Select-Object Status -Unique | Select-Object -ExpandProperty Status | Should -Be "Added"

        }


    }

    Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force


    It "Updates users from a CSV populated with no information" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_allNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_allNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
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

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_NoChanges.csv -force

        foreach ($User in $UserCSVImport)
        {
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

    Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

}
