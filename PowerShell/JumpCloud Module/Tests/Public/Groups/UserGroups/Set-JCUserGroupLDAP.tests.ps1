Connect-JCOnlineTest

Describe 'Set-JCUserGroupLDAP' {

    It "Enables LDAP for a JumpCloud User Group using GroupName" {

        $PesterParams.UserGroupID = New-JCUserGroup -GroupName $(New-RandomString 8) | Select-Object -ExpandProperty Name

        $DisableLDAP = Set-JCUserGroupLDAP -GroupName $PesterParams.UserGroupID -LDAPEnabled $false

        $EnableLDAP = Set-JCUserGroupLDAP -GroupName $PesterParams.UserGroupID -LDAPEnabled $true

        $EnableLDAP.LDAPEnabled | Should be $true

        $UserGroupRemove = Remove-JCUserGroup -GroupName $PesterParams.UserGroupID -force

    }

    It "Disables LDAP for a JumpCloud User Group using GroupName" {

        $PesterParams.UserGroupID = New-JCUserGroup -GroupName $(New-RandomString 8) | Select-Object -ExpandProperty Name

        $EnableLDAP = Set-JCUserGroupLDAP -GroupName $PesterParams.UserGroupID -LDAPEnabled $true

        $DisableLDAP = Set-JCUserGroupLDAP -GroupName $PesterParams.UserGroupID -LDAPEnabled $false

        $DisableLDAP.LDAPEnabled | Should be $false

        $UserGroupRemove = Remove-JCUserGroup -GroupName $PesterParams.UserGroupID -force

    }

    It "Enables LDAP for a JumpCloud User Group using GroupID" {

        $UserGroup = New-JCUserGroup -GroupName $(New-RandomString 8)

        $EnableLDAP = Set-JCUserGroupLDAP -GroupID $UserGroup.id -LDAPEnabled $true

        $EnableLDAP.LDAPEnabled | Should be $true

        $UserGroupRemove = Remove-JCUserGroup -GroupName $UserGroup.name -force

    }

    It "Disables LDAP for a JumpCloud User Group using GroupID" {

        $UserGroup = New-JCUserGroup -GroupName $(New-RandomString 8)

        $EnableLDAP = Set-JCUserGroupLDAP -GroupID $UserGroup.id -LDAPEnabled $true

        $DisableLDAP = Set-JCUserGroupLDAP -GroupID $UserGroup.id -LDAPEnabled $false

        $DisableLDAP.LDAPEnabled | Should be $false

        $UserGroupRemove = Remove-JCUserGroup -GroupName $UserGroup.name -force


    }


}