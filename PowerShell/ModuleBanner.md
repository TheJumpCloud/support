#### Latest Version

```
2.1.0
```

#### Banner Current

```
- This release adds description field parameter to Set-JCSystem and search by description to Get-JCSystem
- Added -Force switch parameter that populates New-JCImportTemplate with all headers when user update or new user CSV is created
- Additional reporting added to Backup-JCOrganization. If failed tasks are detected, the status of the function should report which tasks failed
- Get-JCSystem -filterDateProperty lastContact will now return active systems
```

#### Banner Old

```
* This release introduces Parallel processing functionality to several functions (Get-JCUser, Get-JCSystem, Get-JCSystemUser, Get-JCGroup, Get-JCSystemGroupMember, Get-JCUserGroupMember, Get-JCCommand, Get-JCCommandResult, Get-JCCommandTarget). This release modifies New-JCImportTemplate, Update and Import-JCUsersFromCSV to allow imports or updates with LDAP bind and MFA + EnrollmentDays to users
```
