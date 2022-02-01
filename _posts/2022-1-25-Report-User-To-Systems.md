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

|username   |ldapBind                 |googleWorkspaceBind      |associatedDeviceId                              |deviceName                      |
|-----------|-------------------------|-------------------------|------------------------------------------------|--------------------------------|
|test1      |61e9dcbadb41f2475534476cc65;|61eecb5c232e1109e368b1af;|61eef6a2878cce6a6c29e8c161eef78d2f0d091a90e9e425|Tests-Mac.local;KRM64B;         |
|jltp3      |61e9dcbadb41f2475534476cc65;|                         |61eef6a2878cce6a6c29e8c1                        |Tests-Mac.local;                |
|salliston1e|61e9dcbadb41f2475534476cc65;|                         |61eef6a2878cce6a6c29e8c1                        |Tests-Mac.local;                |
|babrey3d   |61e9dcbadb41f2475534476cc65;|61eecb5c232e1109e368b1af;|61eef78d2f0d091a90e9e425                        |KRM64B;                         |

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
    $foundSystemId = ""
    $foundGoogleWorkspace = ""
    $foundLdap = ""
    $sysName = ""

    # For each system association
    foreach ($systemAssociation in $systemAssociations)
    {
        $foundSystemId += $systemAssociation.Id + ';'
        $systems = Get-JcSdkSystem -Id $systemAssociation.Id
        $sysName += $systems.Hostname + ';'
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
        associatedDevice           = $foundSystemId
        deviceName                 = $sysName

    }
}
# Write out the report
$list | ConvertTo-Csv | Out-File Report-UserToSystemsAssociations.csv
```
