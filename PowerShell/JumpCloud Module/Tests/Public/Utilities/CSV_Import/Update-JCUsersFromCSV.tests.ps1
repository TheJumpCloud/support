Connect-JCOnlineTest

Describe -Tag:('JCUsersFromCSV') "Update-JCUsersFromCSV 1.8.0" {

    It "Updates users from a CSV populated with telephony attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_telephonyAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_telephonyAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)
        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_telephonyAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_telephonyAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)
        }
    }


    It "Updates users from a CSV populated with information attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_userInformationAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_userInformationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_userInformationAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_userInformationAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.MiddleName | Should -be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -be $UpdateUserInfo.location

        }
    }


    It "Updates users from a CSV populated with user location attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_userLocationAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_userLocationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_userLocationAttributes.csv -force
        $UserUpdateInfo = Import-Csv $UpdatePath/UpdateExample_userLocationAttributes.csv

        foreach ($UpdateUser in $UserCSVUpdate)
        {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

    }

    It "Updates users from a CSV populated with user telephony, information, and location attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_AllNewAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_AllNewAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_AllNewAttributes.csv -force
        $UserUpdateInfo =  Import-Csv $UpdatePath/UpdateExample_AllNewAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {

            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

            $UpdateCheck.MiddleName | Should -be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -be $UpdateUserInfo.location

            $UpdateCheck.mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

        }


    }

    It "Updates users from a CSV populated with user telephony, information, and location attributes and custom attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_AllNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_AllNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv -force
        $UserUpdateInfo =  Import-Csv $UpdatePath/UpdateExample_AllNewAttributesAndAllCustom.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {

            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"
            $GroupSysCheck = $UserUpdateCSVImport | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

            $UpdateCheck.MiddleName | Should -be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -be $UpdateUserInfo.location

            $UpdateCheck.mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty systemAdd | Should -be '{"message":"Already Exists"}'


            $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty GroupsAdd | Select-object Status -Unique | Select-Object -ExpandProperty Status | Should -be "Added"

        }


    }

    Get-JCUser | ? Email -like *pleasedelete* | Remove-JCUser -force


    It "Updates users from a CSV populated with no information" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_AllNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_AllNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath $UpdatePath/UpdateExample_NoChanges.csv -force

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

    }

    Get-JCUser | ? Email -like *pleasedelete* | Remove-JCUser -force

}
