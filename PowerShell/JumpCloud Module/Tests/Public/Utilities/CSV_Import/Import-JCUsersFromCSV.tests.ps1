Describe -Tag:('JCUsersFromCSV') 'Import-JCUserFromCSV 1.1' {
    Connect-JCOnlineTest
    It "Imports users from the ImportExample_Pester_Test using -Force" {
        Write-Host ("[HELLOOOO!!!!] Import-JCUsersFromCSV -CSVFilePath $Import_JCUsersFromCSV_1_1_Tests -force")
        $UserImport = Import-JCUsersFromCSV -CSVFilePath $Import_JCUsersFromCSV_1_1_Tests -force

    }


    It "Verifies a.user user" {

        $User = Get-JCUser -Username 'a.user' | Where-Object Username -EQ 'a.user'

        $User.activated | Should be $true

    }

    It "Verifies ia.user user" {

        $User = Get-JCUser -Username 'ia.user' | Where-Object Username -EQ 'ia.user'


        $User.activated | Should be $false
    }

    It "Verifies a.bound.std user" {

        $User = Get-JCUser -Username 'a.bound.std' | Where-Object Username -EQ 'a.bound.std'

        $User.activated | Should be $true

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'a.bound.std'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $false

    }

    It "Verifies a.bound.true1 user" {

        $User = Get-JCUser -Username 'a.bound.true1' | Where-Object username -EQ 'a.bound.true1'

        $User.activated | Should be $true

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'a.bound.true1'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $true

    }

    It "Verifies a.bound.false1 user" {

        $User = Get-JCUser -Username 'a.bound.false1' | Where-Object username -EQ 'a.bound.false1'

        $User.activated | Should be $true

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'a.bound.false1'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $false

    }

    It "Verifies a.bound.true2 user" {

        $User = Get-JCUser -Username 'a.bound.true2' | Where-Object username -EQ 'a.bound.true2'

        $User.activated | Should be $true

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'a.bound.true2'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $true

    }

    It "Verifies a.bound.false2 user" {

        $User = Get-JCUser -Username 'a.bound.false2' | Where-Object username -EQ 'a.bound.false2'

        $User.activated | Should be $true

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'a.bound.false2'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $false

    }

    It "Verifies ia.bound.std user" {

        $User = Get-JCUser -Username 'ia.bound.std' | Where-Object username -EQ 'ia.bound.std'

        $User.activated | Should be $false

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'ia.bound.std'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $false

    }

    It "Verifies ia.bound.true1 user" {

        $User = Get-JCUser -Username 'ia.bound.true1' | Where-Object username -EQ 'ia.bound.true1'

        $User.activated | Should be $false

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'ia.bound.true1'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $true

    }

    It "Verifies ia.bound.false1 user" {

        $User = Get-JCUser -Username 'ia.bound.false1' | Where-Object username -EQ 'ia.bound.false1'

        $User.activated | Should be $false

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'ia.bound.false1'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $false

    }

    It "Verifies ia.bound.true2 user" {

        $User = Get-JCUser -Username 'ia.bound.true2'

        $User.activated | Should be $false

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'ia.bound.true2'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $true

    }

    It "Verifies ia.bound.false2 user" {

        $User = Get-JCUser -Username 'ia.bound.false2' | Where-Object username -EQ 'ia.bound.false2'

        $User.activated | Should be $false

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'ia.bound.false2'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $false

    }

    It "Verifies a.1group user" {

        $User = Get-JCUser -Username 'a.1group' | Where-Object username -EQ 'a.1group'

        $User.activated | Should be $true

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'a.1group'

        $Groups.GroupName.count | Should Be 1

    }

    It "Verifies ia.1group user" {

        $User = Get-JCUser -Username 'ia.1group' | Where-Object username -EQ 'ia.1group'

        $User.activated | Should be $false

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'ia.1group'

        $Groups.GroupName.count | Should Be 1

    }

    It "Verifies a.2group user" {

        $User = Get-JCUser -Username 'a.2group' | Where-Object Username -EQ 'a.2group'

        $User.activated | Should be $true

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'a.2group'

        $Groups.count | Should Be 2

    }

    It "Verifies ia.2group user" {

        $User = Get-JCUser -Username 'ia.2group' | Where-Object username -EQ 'ia.2group'

        $User.activated | Should be $false

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'ia.2group'

        $Groups.count | Should Be 2

    }

    It "Verifies a.2group user" {

        $User = Get-JCUser -Username 'a.2group' | Where-Object username -EQ 'a.2group'

        $User.activated | Should be $true

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'a.2group'

        $Groups.count | Should Be 2

    }

    It "Verifies ia.2group user" {

        $User = Get-JCUser -Username 'ia.2group' | Where-Object username -EQ 'ia.2group'

        $User.activated | Should be $false

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'ia.2group'

        $Groups.count | Should Be 2

    }

    It "Verifies a.5group user" {

        $User = Get-JCUser -Username 'a.5group' | Where-Object username -EQ 'a.5group'

        $User.activated | Should be $true

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'a.5group'

        $Groups.count | Should Be 5

    }

    It "Verifies ia.5group user" {

        $User = Get-JCUser -Username 'ia.5group' | Where-Object Username -EQ 'ia.5group'

        $User.activated | Should be $false

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'ia.5group'

        $Groups.count | Should Be 5

    }

    It "Verifies a.1attr user" {

        $User = Get-JCUser -Username 'a.1attr'

        $User.activated | Should be $true

        $User.attributes.count | Should Be 1

    }

    It "Verifies ia.1attr user" {

        $User = Get-JCUser -Username 'ia.1attr'

        $User.activated | Should be $false

        $User.attributes.count | Should Be 1

    }

    It "Verifies a.2attr user" {

        $User = Get-JCUser -Username 'a.2attr' | Where-Object username -EQ 'a.2attr'

        $User.activated | Should be $true

        $User.attributes.count | Should Be 2

    }

    It "Verifies ia.2attr user" {

        $User = Get-JCUser -Username 'ia.2attr' | Where-Object username -EQ 'ia.2attr'

        $User.activated | Should be $false


        $User.attributes.count | Should Be 2

    }

    It "Verifies a.5attr user" {

        $User = Get-JCUser -Username 'a.5attr' | Where-Object username -EQ 'a.5attr'

        $User.activated | Should be $true

        $User.attributes.count | Should Be 5

    }

    It "Verifies ia.5attr user" {

        $User = Get-JCUser -Username 'ia.5attr' | Where-Object username -EQ 'ia.5attr'

        $User.activated | Should be $false


        $User.attributes.count | Should Be 5

    }

    It "Verifies a.all" {

        $User = Get-JCUser -Username 'a.all' | Where-Object username -EQ 'a.all'

        $User.activated | Should be $true

        $User.attributes.count | Should Be 5

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'a.all'

        $Groups.count | Should Be 5

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'a.all'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $true

    }

    It "Verifies ia.all" {

        $User = Get-JCUser -Username 'ia.all' | Where-Object username -EQ 'ia.all'

        $User.activated | Should be $false

        $User.attributes.count | Should Be 5

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | Where-Object Username -EQ 'ia.all'

        $Groups.count | Should Be 5

        $Bound = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object username -EQ 'ia.all'

        $Bound.DirectBind | Should Be $true

        $Bound.Administrator | Should Be $true


    }
    Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
}
Describe -Tag:('JCUsersFromCSV') "Import-JCUsersFromCSV 1.8.0" {

    It "Imports users from a CSV populated with telephony attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_telephonyAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_telephonyAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)
        }

        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }



    It "Imports users from a CSV populated with information attributes" {

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


        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

    }

    It "Imports users from a CSV populated with user location attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath $ImportPath/ImportExample_userLocationAttributes.csv -force
        $UserImportInfo = Import-Csv $ImportPath/ImportExample_userLocationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

        }
        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }

    It "Imports users from a CSV populated with telephony, location, and user information attributes" {

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

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

        }

        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force
    }

    It "Imports users from a CSV populated with telephony, location, user information attributes, group additions, system binding, and custom attributes" {

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

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | Where-Object type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | Where-Object type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | Where-Object type -eq work | Select-Object -ExpandProperty country)

            $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty systemAdd | Should -be "Added"


            $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty GroupsAdd | Select-Object Status -Unique | Select-Object -ExpandProperty Status | Should -be "Added"
        }

        Get-JCUser | Where-Object Email -like *pleasedelete* | Remove-JCUser -force

    }

}
