## 1.8.1

Release Date: September 21, 2018

#### RELEASE NOTES

```
Bug fix for Multi-Tenant orgs
Check our full release notes to see new attribute additions released in 1.8.0
```

#### BUG FIXES:

- Resolved bug on Connect-JCOnline where OrgID would not set correctly

## 1.8.0

Release Date: September 20, 2018

#### RELEASE NOTES

```
New LDAP user attribute support has been added!
New LDAP user location, information, and telephony attributes.
New function Update-JCUsersFromCSV to add or update all attributes including new LDAP attributes on your existing users.
New function Update-JCUsersFromCSV to add users to groups or bind them to systems in bulk from a CSV file.
Use the updated New-JCImportTemplate function to create a custom user update import CSV file pre-populated with your JumpCloud users to plug into Update-JCUsersFromCSV.
Search for users by LDAP information attributes using Get-JCUser.
Import-JCUsersFromCSV workflow has been updated to handle new attributes.
```

#### FEATURES:

New LDAP extended user attributes: middlename, preferredName, jobTitle, employeeIdentifier (must be unique), department, costCenter, company, employeeType, description, location
New LDAP telephony attributes: mobile_number, home_number, work_number, work_mobile_number, work_fax_number
New LDAP location attributes: home_streetAddress, home_poBox home_city, home_state, home_postalCode, home_country, work_streetAddress, work_poBox, work_locality, work_region, work_postalCode, work_country

- New Function: Update-JCUsersFromCSV to add or update all attributes including new LDAP attributes on your existing user , add users to groups, or bind them to systems in bulk from a CSV file.
- Updated Function: New-JCImportTemplate can now create custom **user update CSV import files** pre-populated with your JumpCloud users to plug into the new Update-JCUsersFromCSV
- Updated Function: New-JCUser has parameters for creating users with the new LDAP extended, telephony, and location attributes.
- Updated Function: Set-JCUser has parameters for updating a modifying users LDAP extended, telephony, and location attributes.
- Updated Function: Get-JCUser has the ability to search for a filter users based on extended LDAP users.
- Updated Function: New-JCImportTemplate workflow has been updated to prompt users with options to add the new LDAP extended, telephony, and location attributes to their CSV import templates.
- Updated Function: Import-JCUsersFromCSV will verify and error check the unique field employeeIdentifier. The output for Import-JCUsersfromCSV has also been cleaned up.

#### IMPROVEMENTS:

- Updated parameters on Set-JCSystem to allow for modification of parameters via PowerShell pipeline.
- Removed 20 character limit on JumpCloud username field.
- Removed method which forced JumpCloud usernames to be lowercase.
- Updated New-JCImportTemplate to make CSV import file in current working directory.
- Updated Import-JCCommand to call Connect-JCOnline and set TLS to 1.2.
- Updated Function: Import-JCUsersFromCSV to use splatting which allows for CSV to contain columns with non JumpCloud user information
- Progress bars on Import-JCUsersFromCSV and Update-JCUsersFromCSV


## 1.7.0
Release Date: August 14, 2018

#### RELEASE NOTES

```
Take JumpCloud commands to the next level with Command Deployments!
New functions New-JCDeploymentTemplate and Invoke-JCDeployment.
Deployments are designed for automation scenarios where a 1:1 association between the command payload and JumpCloud system is required.
Use system specific payloads in your JumpCloud commands with variables populated from a CSV file.
```

#### FEATURES:

- New Function: New-JCDeploymentTemplate used to create a deployment CSV template file that maps to the corresponding JumpCloud command variables to CSV columns.
- New Function: Invoke-JCDeployment for calling the command deployment and feeding the command the '-CommandID' of the target JumpCloud deploy command and the populated deployment CSV file.
- New Function: Set-JCCommand to update JumpCloud commands programmatically. This command is used by the Invoke-JCDeployment command to update the '-launchType' to trigger and trigger the command.  

#### IMPROVEMENTS:

- Warning action "Inquire" removed from Import-JCUsersFromCSV command. Resolves repetitive "Press Y to continue"  message during user validation.
- Streamlined JumpCloud banners. Because less is more.

#### BUG FIXES:

- Resolved bug on 'Import-JCUserFromCSV' where output for users that were not created due to duplicate username or email would show previously created user information.  
- Resolved bug on 'Import-JCUserFromCSV' where output for users that were not created would show 'User created'.  


## 1.6.0
Release Date: August 3, 2018

#### RELEASE NOTES

```
Send activation/password reset emails with the new function Send-JCPasswordReset
Multi tenant support has been added!
Multi tenant admins will be asked to select the org they want to connect to during API authentication.
Multi tenant admins can switch the org they are connected to using the Set-JCOrganization command.
```

#### FEATURES:

- New Function: Send-JCPasswordReset allows admins to use the 'Resend email' button functionality programmatically to send reset/activation emails to targeted users.
- New Function: Set-JCOrganization allows multi tenant admins to change the JumpCloud tenant they are conneted to. 
- New Function: Get-JCOrganization allows multi tenant admins to see the JumpCloud tenants they have access to. 
- Updated Function: Connect-JCOnline to prompt multi tenant admins to select their connected tenant. Admins can also skip this prompt by entering a 'JumpCloud OrgID' into the new '-JumpCloudOrgID' parameter to setup connection in automation scenarios.

#### IMPROVEMENTS:

- All Public functions have been updated to include the [x-org-id](https://docs.jumpcloud.com/2.0/authentication-and-authorization/multi-tenant-organization-api-header) header when a multi tenant API connection is established.

## 1.5.0
Release Date: July 16, 2018

#### RELEASE NOTES

```
New Function: Get-JCBackup to backup user, system user, system, group information to CSV. 
Updated Function: Get-JCCommandResult to show SystemID
```
#### FEATURES:

- New Function: Get-JCBackup to backup user, system user, system, user group, and system group information to CSV
- Updated Function: Get-JCCommandResult to show SystemID when querying command results in bulk and '-ByID'

#### IMPROVEMENTS:

- Module structure updated. .PSM1 function monolithic broken out into single function .PS1 files in [Public](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Public) and [Private](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Private) folders. This allows for easier debugging and updating of the functions within the module. 

## 1.4.2
Release Date: May 31, 2018

#### RELEASE NOTES

```
Updated Function: Get-JCCommandResult with new parameter '-MaxResult'
Using the paramter '-Skip' and '-MaxResult' admins can return a specific subset of command results.
Performance fix for 'Get-JCCommandResult' with increase default limit to 1000
```
#### FEATURES:

- Updated Function: Get-JCCommandResult with new parameters '-MaxResult'. '-MaxResult' can be combinded with '-Skip' to return a specific subset of command results.

#### IMPROVEMENTS:

- Updated Function: Get-JCCommandResult speed and performance by removing sort.
- Updated Function: Get-JCCommandResult increased default limit to 1000 results.

## 1.4.1
Release Date: May 25, 2018

#### RELEASE NOTES

```
Updated Function: Get-JCCommandResult with new parameters '-TotalCount' and '-Skip'
'-TotalCount' returns the number of command results
'-Skip' returns only the results after a specified number
Bug fix for 'Get-JCSystem' to allow for pagination of over 1000 results. 
```
#### FEATURES:

- Updated Function: Get-JCCommandResult with new parameters '-TotalCount' to return the total number of command results and '-Skip' to return only command results after a specificed number. Using '-TotalCount' to first find the total number of results before running a command you can then use '-Skip' to query the new command results after running the command.  

#### BUG FIXES:

- Updated Functions: Get-JCSystem to allow for pagination of over 1000 results.


## 1.4.0
Release Date: May 18, 2018

#### RELEASE NOTES

```
Optimized Functions: Get-JCUser and Get-JCSystem have been overhauled!! 
Optimized functions allow for searching using wildcards on all string properties, 
boolean filters, and a new -filterDateProperty parameter. 
The awesome news is these actions happen server side which speeds things up immensely. 
Updated Functions: Invoke-JCCommand has added parameter '-NumberOfVariables' 
This allows admins to pass variables into existing JumpCloud commands.
Bug fixes: Connect-JCOnline, Add-JCUserGroupMember, and Get-JCSystemGroupMember
Improvements: Optimized Helper Hash Functions to speed up hash table creation and overall performance. 
```

#### FEATURES:

- Updated Function:  Invoke-JCCommand has added parameter '-NumberOfVariables' for passing in variables to JumpCloud commands. This paramter will create additional paramters dynamically based on the number of variables being passed. Learn more about passing objects to JumpCloud commands under the heading 'Sending data with triggers' [here](https://support.jumpcloud.com/customer/en/portal/articles/2443894-how-to-use-command-triggers).
- Updated Function: Get-JCSystem to use the [/search/systems API endpoint](https://docs.jumpcloud.com/1.0/search/search-systems). 
  - Get-JCSystem can now do front and end wild card searches on all string properties
    - Example 'Get-JCsystem -hostname '\*admin\*'
  - Get-JCSystem can now do date searches on 'Created' date field using new paramter -filterDateProperty
  - Get-JCSystem can now return only specific properties using new paramter -returnProperties
- Updated Function: Get-JCUser to use the [/search/systemusers API endpoint](https://docs.jumpcloud.com/1.0/search/list-system-users). 
  - Get-JCUser can now do front and end wild card searches on all string properties
    - Example 'Get-JCUser -username '\*bob\*'
  - Get-JCUser can now do date searches on 'Created' and 'password_expiration_date' date fields using new paramter -filterDateProperty
  - Get-JCUser can now return only specific properties using new paramter -returnProperties
  

#### BUG FIXES:

- Updated Functions: Get-JCSystemGroupMember to properly paginate results greater than 100 system group members. 
- Updated Function:  Add-JCUserGroupMember to handle user error additions more gracefully. 
- Updated Function: Connect-JCOnline to Write-Error instead of Write-Output if API key validation fails

#### IMPROVEMENTS:

- Updated Helper Hash Functions to leverage the -returnProperties which speeds up hash table creation and overall performance. 
  

## 1.3.0
Release Date: April 27, 2018

#### RELEASE NOTES

```
New Function: Set-JCUserGroupLDAP to toggle the LDAP presentation on/off for JumpCloud user groups.
New Function: Get-JCCommandTarget to query the JumpCloud systems or system groups associated with a JumpCloud command.
New Function: Add-JCCommandTarget to add JumpCloud system or system group associations to JumpCloud commands.
New Function: Remove-JCCommandTarget to remove JumpCloud system or system group associations from JumpCloud commands. 
Updated Functions: Add-JCUser and Set-JCUser with boolean parameter '-password_never_expires' 
```

#### FEATURES:

- New Function: Set-JCUserGroupLDAP to toggle the LDAP presentation on/off for JumpCloud user groups.
- New Function: Get-JCCommandTarget to query the JumpCloud systems or system groups associated with a JumpCloud command.
- New Function: Add-JCCommandTarget to add JumpCloud system or system group associations to JumpCloud commands.
- New Function: Remove-JCCommandTarget to remove JumpCloud system or system group associations from JumpCloud commands. 
- Updated Functions: Add-JCUser and Set-JCUser with boolean parameter 'password_never_expires'. 


#### BUG FIXES:

- Updated Functions: Add-JCUser and Set-JCUser to allow UNIX_UID and UNIX_GUID to a value in the range 0-4294967295.
- Updated Function: Get-JCSystemGroupMember to properly display output when using the 'ByID' paramter set.


## 1.2.0
Release Date: February 28, 2018

#### RELEASE NOTES

```
New Function New-JCCommand and Remove-JCCommand to create and remove JumpCloud commands from the shell.
New Function Import-JCCommand to import JumpCloud commands from a URL
Updated Function Get-JCUser to search users via username, firstname, lastname, or email
Updated Function Connect-JCOnline to check for and install module updates and added '-force' parameter for use in scripts and automation 
```

#### FEATURES:

- New Function: New-JCCommand to create JumpCloud commands from the shell
- New Function: Remove-JCCommand to delete JumpCloud commands
- New Function: Import-JCCommand to import JumpCloud commands from a URL
- Updated Function: Get-JCUser to use the same search endpoint as the UI. Get-JCUser can now search via 'username','firstname','lastname', or 'email'. By default Get-JCUser still returns all users.
- Updated Function: Connect-JCOnline added banner to display current JumpCloud module version information. Added paramter sets for 'Interactive' and 'Force' modes. 'Interactive' displays banner and automatic module update options when new version becomes avaliable. 'Force' can be used in automation scenarios to connect to JumpCloud and set $JCAPIKEY variable. 


#### IMPROVEMENTS:

- Updated Function: Add-JCUserGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command
- Updated Function: Add-JCSystemGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command
- Updated Function: Remove-JCUserGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command
- Updated Function: Remove-JCSystemGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command

## 1.1.0 
Release Date: January 8, 2018

#### RELEASE NOTES

```
New function Set-JCSystemUser to set user / system permissions to standard or administrator. 
Updated import functions and Add/Get-JCSystemUser to accommodate for user / system permissions. 
```

#### FEATURES:

- New Function: [Set-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Set-JCSystemUser) can modify user/system permissions and change the user from a standard user to an administrator or vice versa
- New Helper Function: Get-Hash_ID_Sudo hash table of UserID and ($true/$false) for Sudo parameter
- New Helper Function: Get-Hash_SystemID_HostName hash table of SystemID and system DisplayName


#### IMPROVEMENTS:

- Updated Function: [Add-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Add-JCSystemUser) has boolean parameter '-Administrator' for setting system permissions during add
- Updated Function: [Get-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser) to show system permissions 'Administrator: $true/$false' and system DisplayName
- Updated Function: [New-JCImportTemplate](https://github.com/TheJumpCloud/support/wiki/New-JCImportTemplate) to add in 'Administrator' header to .csv file when 'Y' is selected for 'Do you want to bind your new users to existing JumpCloud systems during import?'
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) to accept 'True/$True' and 'False/$False' or blank for the 'Administrator' header in the .csv import file
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) has switch '-Force' parameter to skip the Import GUI and data validation when importing users
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) to look for duplicate email addresses and usernames in import .csv as part of data validation
- Updated Function: [Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup) has -Name parameter which can be used to find attributes like the POSIX group number of a given group 



#### BUG FIXES:

- Updated Function: [Get-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser) to properly clear '$resultsArray' to display accurate results when recursivly listing system users
- Updated Function: [Connect-JCOnline](https://github.com/TheJumpCloud/support/wiki/Connect-JCOnline) and removed conflicting script variable scoping
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) will no longer inaccurately show 'Added' for users who were not bound to a system during import in the import results

```PowerShell

PS> Get-Command -Module JumpCloud

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Add-JCSystemGroupMember                            1.1.0      JumpCloud
Function        Add-JCSystemUser                                   1.1.0      JumpCloud
Function        Add-JCUserGroupMember                              1.1.0      JumpCloud
Function        Connect-JCOnline                                   1.1.0      JumpCloud
Function        Get-JCCommand                                      1.1.0      JumpCloud
Function        Get-JCCommandResult                                1.1.0      JumpCloud
Function        Get-JCGroup                                        1.1.0      JumpCloud
Function        Get-JCSystem                                       1.1.0      JumpCloud
Function        Get-JCSystemGroupMember                            1.1.0      JumpCloud
Function        Get-JCSystemUser                                   1.1.0      JumpCloud
Function        Get-JCUser                                         1.1.0      JumpCloud
Function        Get-JCUserGroupMember                              1.1.0      JumpCloud
Function        Import-JCUsersFromCSV                              1.1.0      JumpCloud
Function        Invoke-JCCommand                                   1.1.0      JumpCloud
Function        New-JCImportTemplate                               1.1.0      JumpCloud
Function        New-JCSystemGroup                                  1.1.0      JumpCloud
Function        New-JCUser                                         1.1.0      JumpCloud
Function        New-JCUserGroup                                    1.1.0      JumpCloud
Function        Remove-JCCommandResult                             1.1.0      JumpCloud
Function        Remove-JCSystem                                    1.1.0      JumpCloud
Function        Remove-JCSystemGroup                               1.1.0      JumpCloud
Function        Remove-JCSystemGroupMember                         1.1.0      JumpCloud
Function        Remove-JCSystemUser                                1.1.0      JumpCloud
Function        Remove-JCUser                                      1.1.0      JumpCloud
Function        Remove-JCUserGroup                                 1.1.0      JumpCloud
Function        Remove-JCUserGroupMember                           1.1.0      JumpCloud
Function        Set-JCSystem                                       1.1.0      JumpCloud
Function        Set-JCSystemUser                                   1.1.0      JumpCloud
Function        Set-JCUser                                         1.1.0      JumpCloud

```

###
[How to update to the latest version of the JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Updating-the-JumpCloud-PowerShell-Module)

## 1.0.0 
Release Date November 29, 2017
```PowerShell

PS > Get-Command -Module JumpCloud

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Add-JCSystemGroupMember                            1.0.0      JumpCloud
Function        Add-JCSystemUser                                   1.0.0      JumpCloud
Function        Add-JCUserGroupMember                              1.0.0      JumpCloud
Function        Connect-JCOnline                                   1.0.0      JumpCloud
Function        Get-JCCommand                                      1.0.0      JumpCloud
Function        Get-JCCommandResult                                1.0.0      JumpCloud
Function        Get-JCGroup                                        1.0.0      JumpCloud
Function        Get-JCSystem                                       1.0.0      JumpCloud
Function        Get-JCSystemGroupMember                            1.0.0      JumpCloud
Function        Get-JCSystemUser                                   1.0.0      JumpCloud
Function        Get-JCUser                                         1.0.0      JumpCloud
Function        Get-JCUserGroupMember                              1.0.0      JumpCloud
Function        Import-JCUsersFromCSV                              1.0.0      JumpCloud
Function        Invoke-JCCommand                                   1.0.0      JumpCloud
Function        New-JCImportTemplate                               1.0.0      JumpCloud
Function        New-JCSystemGroup                                  1.0.0      JumpCloud
Function        New-JCUser                                         1.0.0      JumpCloud
Function        New-JCUserGroup                                    1.0.0      JumpCloud
Function        Remove-JCCommandResult                             1.0.0      JumpCloud
Function        Remove-JCSystem                                    1.0.0      JumpCloud
Function        Remove-JCSystemGroup                               1.0.0      JumpCloud
Function        Remove-JCSystemGroupMember                         1.0.0      JumpCloud
Function        Remove-JCSystemUser                                1.0.0      JumpCloud
Function        Remove-JCUser                                      1.0.0      JumpCloud
Function        Remove-JCUserGroup                                 1.0.0      JumpCloud
Function        Remove-JCUserGroupMember                           1.0.0      JumpCloud
Function        Set-JCSystem                                       1.0.0      JumpCloud
Function        Set-JCUser                                         1.0.0      JumpCloud


```

