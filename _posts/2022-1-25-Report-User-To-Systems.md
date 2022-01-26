---
layout: post
title: Report on User Systems, LDAP, and Google Workspace Associations
description: Generate CSV report of user bound to devices, Google Workspace, and LDAP Servers
tags:
  - powershell
  - reports
  - automation
---

This script generates a CSV report of all users and their associations to systems, LDAP Servers, and Google Workspace


### Basic Usage:

* Install the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Using-the-JumpCloud-PowerShell-Module)
* Save the contents of the script example to a file on a system.
  * EX: ~/Report-User_To_Systems_Associations.ps1
* In a PowerShell terminal window run:
  * `~/Report-User_To_Systems_Associations.ps1`
  * Follow prompts to enter your API Key & OrgID


### Expected Output

|username|ldapBind                 |googleWorkspaceBind     |associatedDevices       |
|--------|-------------------------|------------------------|------------------------|
|test1   |6135dcb41f2123534476cc65;|61eecb5c232e1109e3211af;|61eef6a2878dsa1da9e8c1; |
|wuser2  |61e9dcb41f2475as2476cc65;|                        |61eef78das2391a90e9e425;|

### Script Example:

```powershell
# Get everyone from a group
$users = Get-JcSdkUser
# Initialize an empty list
$list = @()
# For each user
foreach ($user in $users)
{
    $userDetails = Get-jcsdkUser -Id $user.id

    #Get GSuite Association
    $googleWorkspaceAssociations = Get-JcSdkUserTraverseGSuite -UserId  $user.Id
    # Get System Associations
    $systemAssociations = Get-JcSdkUserTraverseSystem -UserId $user.Id
    #Get User LDAP Associations
    $ldapAssociations = Get-JcSdkUserTraverseLdapServer -UserId $user.Id
    # Clear variables
    $foundSystem = ""
    $foundGoogleWorkspace = ""
    $foundLdap = ""
    # For each system association
    foreach ($systemAssociation in $systemAssociations)
    {
        $foundSystem += $systemAssociation.Id + ';'
    }
    #For Each Google Workspace association
    foreach($googleWorkspaceAssociation in $googleWorkspaceAssociations)
    {
        $foundGoogleWorkspace += $googleWorkspaceAssociation.Id + ';'
    }
    #For each LDAP association
    foreach ($ldapAssociation in $ldapAssociations)
    {
        $foundLdap += $ldapAssociation.Id + ';'
    }

    # populate the rows
    $list += [PSCustomObject]@{
        username                   = $userDetails.Username;
        ldapBind                   = $foundLdap
        googleWorkspaceBind        = $foundGoogleWorkspace
        associatedDevices          = $foundSystem
    }
}
# Write out the report
$list | ConvertTo-Csv | Out-File Report-UserToSystemsAssociations.csv
```
