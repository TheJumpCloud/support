Describe -Tag:('JCUsersFromCSV') 'Import-JCUserFromCSV 1.1' -skip {
    #TODO: rework tests, dynamically populate groups/ system, else these tests fail
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
    It "Imports users from the ImportExample_Pester_Test using -Force" {
        $UserImport = Import-JCUsersFromCSV -CSVFilePath $PesterParams_Import_JCUsersFromCSV_1_1_Tests -force
    }

    It "Verifies a.user user" {

        $User = Get-JCUser -Username 'a.user' | Where-Object Username -EQ 'a.user'

        $User.activated | Should -Be true

    }

    It "Verifies ia.user user" {

        $User = Get-JCUser -Username 'ia.user' | Where-Object Username -EQ 'ia.user'


        $User.activated | Should -Be false
    }

    It "Verifies " {

        $User = Get-JCUser -Username 'a.bound.std' | Where-Object Username -EQ 'a.bound.std'

        $User.activated | Should -Be true

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'a.bound.std'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be false

    }

    It "Verifies a.bound.true1 user" {

        $User = Get-JCUser -Username 'a.bound.true1' | Where-Object username -EQ 'a.bound.true1'

        $User.activated | Should -Be true

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'a.bound.true1'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be true

    }

    It "Verifies a.bound.false1 user" {

        $User = Get-JCUser -Username 'a.bound.false1' | Where-Object username -EQ 'a.bound.false1'

        $User.activated | Should -Be true

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'a.bound.false1'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be false

    }

    It "Verifies a.bound.true2 user" {

        $User = Get-JCUser -Username 'a.bound.true2' | Where-Object username -EQ 'a.bound.true2'

        $User.activated | Should -Be true

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'a.bound.true2'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be true

    }

    It "Verifies a.bound.false2 user" {

        $User = Get-JCUser -Username 'a.bound.false2' | Where-Object username -EQ 'a.bound.false2'

        $User.activated | Should -Be true

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'a.bound.false2'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be false

    }

    It "Verifies ia.bound.std user" {

        $User = Get-JCUser -Username 'ia.bound.std' | Where-Object username -EQ 'ia.bound.std'

        $User.activated | Should -Be false

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'ia.bound.std'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be false

    }

    It "Verifies ia.bound.true1 user" {

        $User = Get-JCUser -Username 'ia.bound.true1' | Where-Object username -EQ 'ia.bound.true1'

        $User.activated | Should -Be false

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'ia.bound.true1'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be true

    }

    It "Verifies ia.bound.false1 user" {

        $User = Get-JCUser -Username 'ia.bound.false1' | Where-Object username -EQ 'ia.bound.false1'

        $User.activated | Should -Be false

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'ia.bound.false1'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be false

    }

    It "Verifies ia.bound.true2 user" {

        $User = Get-JCUser -Username 'ia.bound.true2'

        $User.activated | Should -Be false

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'ia.bound.true2'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be true

    }

    It "Verifies ia.bound.false2 user" {

        $User = Get-JCUser -Username 'ia.bound.false2' | Where-Object username -EQ 'ia.bound.false2'

        $User.activated | Should -Be false

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'ia.bound.false2'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be false

    }

    It "Verifies a.1group user" {

        $User = Get-JCUser -Username 'a.1group' | Where-Object username -EQ 'a.1group'

        $User.activated | Should -Be true

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

    }

    It "Verifies ia.1group user" {

        $User = Get-JCUser -Username 'ia.1group' | Where-Object username -EQ 'ia.1group'

        $User.activated | Should -Be false

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

    }

    It "Verifies a.2group user" {

        $User = Get-JCUser -Username 'a.2group' | Where-Object Username -EQ 'a.2group'

        $User.activated | Should -Be true

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

    }

    It "Verifies ia.2group user" {

        $User = Get-JCUser -Username 'ia.2group' | Where-Object username -EQ 'ia.2group'

        $User.activated | Should -Be false

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

    }

    It "Verifies a.5group user" {

        $User = Get-JCUser -Username 'a.5group' | Where-Object username -EQ 'a.5group'

        $User.activated | Should -Be true

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

    }

    It "Verifies ia.5group user" {

        $User = Get-JCUser -Username 'ia.5group' | Where-Object Username -EQ 'ia.5group'

        $User.activated | Should -Be false

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

    }

    It "Verifies a.1attr user" {

        $User = Get-JCUser -Username 'a.1attr'

        $User.activated | Should -Be true

        $User.attributes.count | Should -Be

    }

    It "Verifies ia.1attr user" {

        $User = Get-JCUser -Username 'ia.1attr'

        $User.activated | Should -Be false

        $User.attributes.count | Should -Be

    }

    It "Verifies a.2attr user" {

        $User = Get-JCUser -Username 'a.2attr' | Where-Object username -EQ 'a.2attr'

        $User.activated | Should -Be true

        $User.attributes.count | Should -Be

    }

    It "Verifies ia.2attr user" {

        $User = Get-JCUser -Username 'ia.2attr' | Where-Object username -EQ 'ia.2attr'

        $User.activated | Should -Be false


        $User.attributes.count | Should -Be

    }

    It "Verifies a.5attr user" {

        $User = Get-JCUser -Username 'a.5attr' | Where-Object username -EQ 'a.5attr'

        $User.activated | Should -Be true

        $User.attributes.count | Should -Be

    }

    It "Verifies ia.5attr user" {

        $User = Get-JCUser -Username 'ia.5attr' | Where-Object username -EQ 'ia.5attr'

        $User.activated | Should -Be false


        $User.attributes.count | Should -Be

    }

    It "Verifies a.all" {

        $User = Get-JCUser -Username 'a.all' | Where-Object username -EQ 'a.all'

        $User.activated | Should -Be true

        $User.attributes.count | Should -Be

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'a.all'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be true

    }

    It "Verifies ia.all" {

        $User = Get-JCUser -Username 'ia.all' | Where-Object username -EQ 'ia.all'

        $User.activated | Should -Be false

        $User.attributes.count | Should -Be

        $Groups = Get-JCAssociation -Type:('user') -Id:($User.id) -TargetType:('user_group')

        $Groups.count | Should -Be

        # $Bound = Get-JCSystemUser -SystemID $PesterParams_SystemLinux._id | Where-Object username -EQ 'ia.all'

        $Bound.DirectBind | Should -Be true

        $Bound.Administrator | Should -Be true


    }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
}
Describe -Tag:('JCUsersFromCSV') "Import-JCUsersFromCSV 1.8.0" {

    It "Imports users from a CSV populated with telephony attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_telephonyAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_telephonyAttributes.csv"

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

    }
    It "Removes users Where-Object Email -like *pleasedelete* " {
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }


    It "Imports users from a CSV populated with information attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_userInformationAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_userInformationAttributes.csv"

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


        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

    }

    It "Imports users from a CSV populated with user location attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_userLocationAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_userLocationAttributes.csv"

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
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }
    It "Imports users from a CSV populated with uid/ gid attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_uid_guid.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_uid_guid.csv"

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.unix_uid | Should -Be $($NewUserInfo.unix_uid)
            $ImportCheck.unix_guid | Should -Be $($NewUserInfo.unix_guid)
        }
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }

    It "Imports users from a CSV populated with telephony, location, and user information attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_allNewAttributes.csv" -force
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributes.csv"

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

        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }

    It "Imports users from a CSV populated with telephony, location, user information attributes, group additions, system binding, and custom attributes" {

        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom.csv"
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_allNewAttributesAndAllCustom.csv" -force

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -Be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -Be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -Be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -Be $NewUserInfo.employeeIdentifier
            $ImportCheck.alternateEmail | Should -Be $NewUserInfo.alternateEmail
            # TODO: Dynamically populate manager
            # $ImportCheck.manager | Should -Be $NewUserInfo.manager
            $ImportCheck.managedAppleId | Should -Be $NewUserInfo.managedAppleId
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

            # TODO: Add these back when we've auto added groups/ systems
            # $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty systemAdd | Should -Be "Added"
            # $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty GroupsAdd | Select-Object Status -Unique | Select-Object -ExpandProperty Status | Should -Be "Added"
        }

        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

    }
    It "Imports a new user from a CSV with a null custom attribute should throw" {
        $UserImportInfo = Import-Csv "$PesterParams_ImportPath/ImportExample_missingAttribute.csv"
        { Import-JCUsersFromCSV -CSVFilePath "$PesterParams_ImportPath/ImportExample_missingAttribute.csv" -force } | Should -Throw

        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

    }

}
