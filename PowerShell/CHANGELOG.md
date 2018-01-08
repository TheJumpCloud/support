## 1.1.0 (January 8, 2018)

FEATURES:

- New Function: [Set-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Set-JCSystemUser) can modify user/system permissions and change the user from a standard user to an administrator or vice versa
- New Helper Function: Get-Hash_ID_Sudo hash table of UserID and ($true/$false) for Sudo parameter
- New Helper Function: Get-Hash_SystemID_HostName hash table of SystemID and system DisplayName


IMPROVEMENTS:

- Updated Function: [Add-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Add-JCSystemUser) has boolean parameter '-Administrator' for setting system permissions during add
- Updated Function: [Get-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser) to show system permissions 'Administrator: $true/$false' and system DisplayName
- Updated Function: [New-JCImportTemplate](https://github.com/TheJumpCloud/support/wiki/New-JCImportTemplate) to add in 'Administrator' header to .csv file when 'Y' is selected for 'Do you want to bind your new users to existing JumpCloud systems during import?'
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) to accept 'True/$True' and 'False/$False' or blank for the 'Administrator' header in the .csv import file
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) has switch '-Force' parameter to skip the Import GUI and data validation when importing users
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) to look for duplicate email addresses and usernames in import .csv as part of data validation
- Updated Function: [Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup) has -Name parameter which can be used to find attributes like the POSIX group number of a given group 



BUG FIXES:

- Updated Function: [Get-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser) to properly clear '$resultsArray' to display accurate results when recursivly listing system users
- Updated Function: [Connect-JCOnline](https://github.com/TheJumpCloud/support/wiki/Connect-JCOnline) and removed conflicting script variable scoping
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) will no longer inaccurately show 'Added' for users were not bound to a system during import in the import results

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


## 1.0.0 (November 29, 2017)

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

