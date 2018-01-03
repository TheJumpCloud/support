## Next version (Unreleased)

FEATURES:

- New Function: Set-JCSystemUser can modify user/system standard vs administrator permissions
- New Helper Function: Get-Hash_ID_Sudo hash table of UserID and ($true/$false) for Sudo parameter
- New Helper Function: Get-Hash_SystemID_HostName hash table of SystemID and system DisplayName


IMPROVEMENTS:

- Updated Function: Add-JCSystemUser has boolean parameter '-Administrator' for setting system permissions during add
- Updated Function: Get-JCSystemUser to show system permissions 'Administrator: $true/$false' and system DisplayName
- Updated Function: New-JCImportTemplate to add in 'Administrator' header to .csv file when 'Y' is selected for 'Do you want to bind your new users to existing JumpCloud systems during import?'
- Updated Function: Import-JCUserFromCSV to accept 'True/$True' and 'False/$False' or blank for the 'Administrator' header in the .csv import file
- Updated Function: Import-JCUserFromCSV has switch '-Force' parameter to skip the Import GUI and data validation when importing users
- Updated Function: Import-JCUserFromCSV to look for duplicate email addresses and usernames in import .csv as part of data validation



BUG FIXES:

- Updated Function: Get-JCSystemUser to properly clear '$resultsArray' to display accurate results when recursivly listing system users


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

