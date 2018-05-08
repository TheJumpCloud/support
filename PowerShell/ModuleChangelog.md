## Next version (Unreleased)

#### FEATURES:

- Updated Function:  Invoke-JCCommand has added parameter '-NumberOfVariables' for passing in arguments for JumpCloud commands. This paramter will create additional paramters dynamically based on the number of variables being passed. Learn more about passing objects to JumpCloud commands under the heading 'Sending data with triggers' [here](https://support.jumpcloud.com/customer/en/portal/articles/2443894-how-to-use-command-triggers).

#### BUG FIXES:

- Updated Functions: Get-JCSystemGroupMember to properly paginate results greater than 100 system group members. 
- Updated Function:  Add-JCUserGroupMember to handle user error additions more gracefully. 

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

