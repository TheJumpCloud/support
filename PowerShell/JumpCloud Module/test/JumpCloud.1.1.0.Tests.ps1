#Tests for JumpCloud Module Version 1.1.0

# To run all the Pester Tests you will need to have a tenant that matches the below criteria.

# For Command Results Tests - Have at least 5 command results present in your Org
# For Commands Tests - Have at least 2 JumpCloud commands that are set to run via the 'Run on Trigger' event
# For Groups Tests - Have at least 2 JumpCloud User Groups and 2 JumpCloud System Groups
# For Systems Tests - Have at least 2 JumpCloud Systems present in your Org.
# For Users Tests - Have at least 2 JumpCloud Users present in your Org.

#Additionally you must populate the below variables to run successful tests using the -ByID parameter

$SystemID = '' # Enter the System ID for a system in your test tenant. **Note users will be added and removed from this system during the tests

$Username = 'pester.tester' # Create a user with username 'pester.tester'
$UserID = '' # Paste the UserID for the user with username pester.tester

$UserGroupName = 'PesterTest_UserGroup'  #Create a user group named PesterTest_UserGroup within your environment
$UserGroupID = ''  # Paste the corresponding GroupID for the user group named PesterTest_UserGroup

$SystemGroupName = 'PesterTest_SystemGroup' # Create a sytem group named PesterTest_SystemGroup within your environment
$SystemGroupID = ''  # Paste the corresponding GroupID for the sytem group named PesterTest_SystemGroup

$NewJCSystemGroup = 'NewSystemGroup' #Do not modify this
$NewJCUserGroup = 'NewUserGroup' #Do not modify this

$CSVPath = '' #Path to ImportExample_Pester_Tests_1.1.0.csv //REQUIRED update the system under 'SystemID' in the .CSV file.
           

#Test Functions

Function New-RandomUser  ()
{
    [CmdletBinding(DefaultParameterSetName = 'NoAttributes')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [String]
        $Domain,

        [Parameter(ParameterSetName = 'Attributes')] ##Test this to see if this can be modified.
        [switch]
        $Attributes

    )

    if (($PSCmdlet.ParameterSetName -eq 'NoAttributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
        $email = $username + "@$Domain.com"

        $RandomUser = [ordered]@{
            FirstName = 'Pester'
            LastName  = 'Test'
            Username  = $username
            Email     = $email
            Password  = 'Temp123!'
        }

        $NewRandomUser = New-Object psobject -Property $RandomUser
    }

    if (($PSCmdlet.ParameterSetName -eq 'Attributes'))
    {
        $username = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
        $email = $username + "@$Domain.com"

        $RandomUser = [ordered]@{
            FirstName                = 'Pester'
            LastName                 = 'Test'
            Username                 = $username
            Email                    = $email
            Password                 = 'Temp123!'
            NumberOfCustomAttributes = 3
            Attribute1_name          = 'Department'
            Attribute1_value         = 'Sales'
            Attribute2_name          = 'Office'
            Attribute2_value         = '456789'
            Attribute3_name          = 'Lang'
            Attribute3_value         = 'French'
        }
        $NewRandomUser = New-Object psobject -Property $RandomUser
    }


    return $NewRandomUser
}
Function New-RandomString ()
{
    [CmdletBinding()]

    param(

        [Parameter(Mandatory)] ##Test this to see if this can be modified.
        [ValidateRange(0, 52)]
        [Int]
        $NumberOfChars

    )
    begin {}
    process
    {
        $Random = -join ((65..90) + (97..122) | Get-Random -Count $NumberOfChars | % {[char]$_})
    }
    end {Return $Random}


}

$Random = New-RandomString '8'
$RandomEmail = "$Random@$Random.com"


Describe 'Set-JCSystemUser' {

    It "Sets a standard user to an admin user using username" {
        
        Add-JCSystemUser -SystemID $SystemID -Username $Username -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $SystemID -Username $Username -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $Username | Select Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using username" {
        
        Set-JCSystemUser -SystemID $SystemID -Username $Username -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $SystemID -Username $Username -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $Username | Select Administrator
        $GetSystem.Administrator | Should -Be $False

    }

    It "Sets a standard user to an admin user using UserID" {
        
        Set-JCSystemUser -SystemID $SystemID -UserID $UserID -Administrator $False #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $SystemID -UserID $UserID -Administrator $True
        $CommandResults.Administrator | Should -Be $True
        $GetSystem = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $Username | Select Administrator
        $GetSystem.Administrator | Should -Be $True

    }

    It "Sets an admin user to a standard user using UserID" {
        
        Set-JCSystemUser -SystemID $SystemID -UserID $UserID -Administrator $True #Sets to standard user
        $CommandResults = Set-JCSystemUser -SystemID $SystemID -UserID $UserID -Administrator $False
        $CommandResults.Administrator | Should -Be $False
        $GetSystem = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $Username | Select Administrator
        $GetSystem.Administrator | Should -Be $False

    }


}

Describe 'Add-JCSystemUser 1.1.0 and Get-JCSystemUser 1.1.0' {

    IT "Adds a JumpCloud User to a JumpCloud System with admin `$False using username" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser

        $FalseUser = Add-JCSystemUser -Username $User.username -SystemID $SystemID -Administrator $False

        $FalseUser.Administrator | Should Be $False

        $GetUser = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $FalseUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should Be $False

    }

    IT "Adds a JumpCloud User to a JumpCloud System with admin $False using username" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser

        $FalseUser = Add-JCSystemUser -Username $User.username -SystemID $SystemID -Administrator $False

        $FalseUser.Administrator | Should Be $False

        $GetUser = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $FalseUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should Be $False

    }

    IT "Adds a JumpCloud User to a JumpCloud System with admin `$False using UserID" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser
    
        $FalseUser = Add-JCSystemUser -UserID $User._id -SystemID $SystemID -Administrator $False
    
        $FalseUser.Administrator | Should Be $False
    
        $GetUser = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $User.Username | Select-Object Administrator
    
        $GetUser.Administrator | Should Be $False
    
    }

    IT "Adds a JumpCloud User to a JumpCloud System with admin `$True using UserID" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser
    
        $TrueUser = Add-JCSystemUser -UserID $User._id -SystemID $SystemID -Administrator $True
    
        $TrueUser.Administrator | Should Be $True
    
        $GetUser = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $User.Username | Select-Object Administrator
    
        $GetUser.Administrator | Should Be $True
    
    }

    IT "Adds a JumpCloud User to a JumpCloud System with admin $True using username" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser
    
        $TrueUser = Add-JCSystemUser -Username $User.username -SystemID $SystemID -Administrator $True
    
        $TrueUser.Administrator | Should Be $True
    
        $GetUser = Get-JCSystemUser -SystemID $SystemID | ? Username -EQ $TrueUser.Username | Select-Object Administrator
    
        $GetUser.Administrator | Should Be $True
    
    }


} 

Describe 'Get-JCGroup 1.1.0' {

    It "Gets a JumpCloud UserGroup by Name and Displays Attributes" {
        
        $Posix = Get-JCGroup -Type User -Name $UserGroupName

        $Posix.posixGroups.id | Should -Not -BeNullOrEmpty
        $Posix.posixGroups.name | Should -Not -BeNullOrEmpty
    }

}

Describe 'Import-JCUserFromCSV' {

    IT "Imports users from the ImportExample_Pester_Test using -Force" {

        $UserImport = Import-JCUsersFromCSV -CSVFilePath  $CSVpath -force

    }


    IT "Verifies a.user user" {

        $User = Get-JCUser -Username 'a.user' | ? Username -EQ 'a.user'

        $User.activated | Should be $True 

    }

    IT "Verifies ia.user user" {

        $User = Get-JCUser -Username 'ia.user' | ? Username -EQ 'ia.user'


        $User.activated | Should be $False
    }

    IT "Verifies a.bound.std user" {

        $User = Get-JCUser -Username 'a.bound.std' | ? Username -EQ 'a.bound.std'

        $User.activated | Should be $True

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'a.bound.std'

        $Bound.DirectBind | Should Be $True

        $Bound.Administrator | Should Be $False

    }

    IT "Verifies a.bound.true1 user" {

        $User = Get-JCUser -Username 'a.bound.true1' | ? username -EQ 'a.bound.true1'

        $User.activated | Should be $True

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'a.bound.true1'

        $Bound.DirectBind | Should Be $True

        $Bound.Administrator | Should Be $True

    }

    IT "Verifies a.bound.false1 user" {

        $User = Get-JCUser -Username 'a.bound.false1' | ? username -EQ 'a.bound.false1'

        $User.activated | Should be $True

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'a.bound.false1'

        $Bound.DirectBind | Should Be $True

        $Bound.Administrator | Should Be $False

    }

    IT "Verifies a.bound.true2 user" {

        $User = Get-JCUser -Username 'a.bound.true2' | ? username -EQ 'a.bound.true2'

        $User.activated | Should be $True

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'a.bound.true2'

        $Bound.DirectBind | Should Be $True

        $Bound.Administrator | Should Be $True

    }

    IT "Verifies a.bound.false2 user" {

        $User = Get-JCUser -Username 'a.bound.false2' | ? username -EQ 'a.bound.false2'

        $User.activated | Should be $True

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'a.bound.false2'

        $Bound.DirectBind | Should Be $True

        $Bound.Administrator | Should Be $False

    }

    IT "Verifies ia.bound.std user" {

        $User = Get-JCUser -Username 'ia.bound.std' | ? username -EQ 'ia.bound.std'
    
        $User.activated | Should be $False
    
        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'ia.bound.std'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $False
    
    }
    
    IT "Verifies ia.bound.true1 user" {
    
        $User = Get-JCUser -Username 'ia.bound.true1' | ? username -EQ 'ia.bound.true1'
    
        $User.activated | Should be $False
    
        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'ia.bound.true1'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $True
    
    }
    
    IT "Verifies ia.bound.false1 user" {
    
        $User = Get-JCUser -Username 'ia.bound.false1' | ? username -EQ 'ia.bound.false1'
    
        $User.activated | Should be $False
    
        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'ia.bound.false1'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $False
    
    }
    
    IT "Verifies ia.bound.true2 user" {
    
        $User = Get-JCUser -Username 'ia.bound.true2'
    
        $User.activated | Should be $False
    
        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'ia.bound.true2'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $True
    
    }
    
    IT "Verifies ia.bound.false2 user" {
    
        $User = Get-JCUser -Username 'ia.bound.false2' | ? username -EQ 'ia.bound.false2'
    
        $User.activated | Should be $False
    
        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'ia.bound.false2'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $False
    
    }

    IT "Verifies a.1group user" {
    
        $User = Get-JCUser -Username 'a.1group' | ? username -EQ 'a.1group'
    
        $User.activated | Should be $True
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'a.1group'
    
        $Groups.GroupName.count | Should Be 1
    
    }

    IT "Verifies ia.1group user" {
    
        $User = Get-JCUser -Username 'ia.1group' | ? username -EQ 'ia.1group'
    
        $User.activated | Should be $False
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'ia.1group'
    
        $Groups.GroupName.count | Should Be 1
    
    }

    IT "Verifies a.2group user" {
    
        $User = Get-JCUser -Username 'a.2group' | ? Username -EQ 'a.2group'
    
        $User.activated | Should be $True
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'a.2group'
    
        $Groups.count | Should Be 2
    
    }

    IT "Verifies ia.2group user" {
    
        $User = Get-JCUser -Username 'ia.2group' | ? username -EQ 'ia.2group'
    
        $User.activated | Should be $False
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'ia.2group'
    
        $Groups.count | Should Be 2
    
    }

    IT "Verifies a.2group user" {
    
        $User = Get-JCUser -Username 'a.2group' | ? username -EQ 'a.2group'
    
        $User.activated | Should be $True
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'a.2group'
    
        $Groups.count | Should Be 2
    
    }

    IT "Verifies ia.2group user" {
    
        $User = Get-JCUser -Username 'ia.2group' | ? username -EQ 'ia.2group'
    
        $User.activated | Should be $False
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'ia.2group'
    
        $Groups.count | Should Be 2
    
    }

    IT "Verifies a.5group user" {
    
        $User = Get-JCUser -Username 'a.5group' | ? username -EQ 'a.5group'
    
        $User.activated | Should be $True
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'a.5group'
    
        $Groups.count | Should Be 5
    
    }
    
    IT "Verifies ia.5group user" {
    
        $User = Get-JCUser -Username 'ia.5group' | ? Username -EQ 'ia.5group'
    
        $User.activated | Should be $False
    
        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'ia.5group'
    
        $Groups.count | Should Be 5
    
    }

    IT "Verifies a.1attr user" {
    
        $User = Get-JCUser -Username 'a.1attr' | ? username -EQ 'a.1attr'
    
        $User.activated | Should be $True
     
        $User.attributes._id.count | Should Be 1
    
    }
    
    IT "Verifies ia.1attr user" {
    
        $User = Get-JCUser -Username 'ia.1attr' | ? username -Eq 'ia.1attr'
    
        $User.activated | Should be $False
    
        $attrs = 
    
        $User.attributes._id.count | Should Be 1
    
    }

    IT "Verifies a.2attr user" {
    
        $User = Get-JCUser -Username 'a.2attr' | ? username -EQ 'a.2attr'
    
        $User.activated | Should be $True
     
        $User.attributes._id.count | Should Be 2
    
    }
    
    IT "Verifies ia.2attr user" {
    
        $User = Get-JCUser -Username 'ia.2attr' | ? username -EQ 'ia.2attr'
    
        $User.activated | Should be $False
    
        $attrs = 
    
        $User.attributes._id.count | Should Be 2
    
    }

    IT "Verifies a.5attr user" {
    
        $User = Get-JCUser -Username 'a.5attr' | ? username -EQ 'a.5attr'
    
        $User.activated | Should be $True
     
        $User.attributes._id.count | Should Be 5
    
    }
    
    IT "Verifies ia.5attr user" {
    
        $User = Get-JCUser -Username 'ia.5attr' | ? username -EQ 'ia.5attr'
    
        $User.activated | Should be $False
    
        $attrs = 
    
        $User.attributes._id.count | Should Be 5
    
    }

    IT "Verifies a.all" {

        $User = Get-JCUser -Username 'a.all' | ? username -EQ 'a.all'
    
        $User.activated | Should be $True
     
        $User.attributes._id.count | Should Be 5

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'a.all'
    
        $Groups.count | Should Be 5

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'a.all'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $True

    }

    IT "Verifies ia.all" {

        $User = Get-JCUser -Username 'ia.all' | ? username -EQ 'ia.all'
    
        $User.activated | Should be $False
     
        $User.attributes._id.count | Should Be 5

        $Groups = Get-JCGroup -Type User | Get-JCUserGroupMember | ? Username -EQ 'ia.all'
    
        $Groups.count | Should Be 5

        $Bound = Get-JCSystemUser -SystemID $SystemID | ? username -EQ 'ia.all'
    
        $Bound.DirectBind | Should Be $True
    
        $Bound.Administrator | Should Be $True


    }
    



}


# Cleans up newly created users from CSV import by deleteing them

Get-JCUser | ? Email -like *pleasedelete* | Remove-JCUser -force
