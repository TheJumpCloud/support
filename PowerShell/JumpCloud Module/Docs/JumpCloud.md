---
Module Name: JumpCloud
Module Guid: 31c023d1-a901-48c4-90a3-082f91b31646
Download Help Link: https://github.com/TheJumpCloud/support/wiki
Help Version: 1.18.13
Locale: en-US
---

# JumpCloud Module
## Description
PowerShell functions to manage a JumpCloud Directory-as-a-Service

## JumpCloud Cmdlets
### [Add-JCAssociation](Add-JCAssociation.md)
Create an association between two object within the JumpCloud console.

### [Add-JCCommandTarget](Add-JCCommandTarget.md)
Associates a JumpCloud system or a JumpCloud system group with a JumpCloud command

### [Add-JCRadiusReplyAttribute](Add-JCRadiusReplyAttribute.md)
Adds Radius reply attributes to a JumpCloud user group.

### [Add-JCSystemGroupMember](Add-JCSystemGroupMember.md)
Adds a JumpCloud System to a JumpCloud System Group

### [Add-JCSystemUser](Add-JCSystemUser.md)
Associates a JumpCloud User account with a local account on a JumpCloud managed System.

### [Add-JCUserGroupMember](Add-JCUserGroupMember.md)
Adds a JumpCloud user to a JumpCloud User Group.

### [Backup-JCOrganization](Backup-JCOrganization.md)
Backup your JumpCloud organization to local json files

### [Connect-JCOnline](Connect-JCOnline.md)
The Connect-JCOnline function sets the global variable $JCAPIKEY

### [Copy-JCAssociation](Copy-JCAssociation.md)
Copy the associations from one object to another.

### [Get-JCAssociation](Get-JCAssociation.md)
The function Get-JCAssociation can be used to query an object's associations and then provide information about how objects are associated with one another.

### [Get-JCBackup](Get-JCBackup.md)
Backs up JumpCloud directory information to CSV

### [Get-JCCommand](Get-JCCommand.md)
Returns all JumpCloud Commands within a JumpCloud tenant or a single JumpCloud Command using the -ByID Parameter.

### [Get-JCCommandResult](Get-JCCommandResult.md)
Returns all JumpCloud Command Results within a JumpCloud tenant or a single JumpCloud Command Result using the -ByID Parameter.

### [Get-JCCommandTarget](Get-JCCommandTarget.md)
Returns the JumpCloud systems or system groups associated with a JumpCloud command.

### [Get-JCGroup](Get-JCGroup.md)
Returns all JumpCloud System and User Groups.

### [Get-JCOrganization](Get-JCOrganization.md)
Returns all JumpCloud organizations associated with the authenticated JumpCloud admins account.

### [Get-JCPolicy](Get-JCPolicy.md)
Returns all JumpCloud Policies within a JumpCloud tenant.

### [Get-JCPolicyResult](Get-JCPolicyResult.md)
Returns all JumpCloud results for a given policy within a JumpCloud tenant.

### [Get-JCPolicyTargetGroup](Get-JCPolicyTargetGroup.md)
Returns all bound groups associated with a JumpCloud Policy within a JumpCloud tenant.

### [Get-JCPolicyTargetSystem](Get-JCPolicyTargetSystem.md)
Returns all bound systems associated with a JumpCloud Policy within a JumpCloud tenant.

### [Get-JCRadiusReplyAttribute](Get-JCRadiusReplyAttribute.md)
Returns the Radius reply attributes associated with a JumpCloud user group.

### [Get-JCRadiusServer](Get-JCRadiusServer.md)
Return JumpCloud radius server information.

### [Get-JCSystem](Get-JCSystem.md)
Returns all JumpCloud Systems within a JumpCloud tenant or a single JumpCloud System using the -ByID Parameter.

### [Get-JCSystemGroupMember](Get-JCSystemGroupMember.md)
Returns the System Group members of a JumpCloud System Group.

### [Get-JCSystemInsights](Get-JCSystemInsights.md)
JumpCloud's System Insights feature provides admins with the ability to easily interrogate their fleet of systems to find important pieces of information.
Using this function you can easily gather heightened levels of information from your fleet of JumpCloud managed systems.

### [Get-JCSystemUser](Get-JCSystemUser.md)
Returns all JumpCloud Users associated with a JumpCloud System.

### [Get-JCUser](Get-JCUser.md)
Returns all JumpCloud Users within a JumpCloud tenant or searches for a JumpCloud User by 'username', 'firstname', 'lastname', or 'email'.

### [Get-JCUserGroupMember](Get-JCUserGroupMember.md)
Returns the User Group members of a JumpCloud User Group.

### [Import-JCCommand](Import-JCCommand.md)
Imports a Mac, Linux or Windows JumpCloud Command into the JumpCloud admin portal from a URL

### [Import-JCUsersFromCSV](Import-JCUsersFromCSV.md)
Imports a set of JumpCloud users from a CSV file created using the New-JCImportTemplate function.

### [Invoke-JCCommand](Invoke-JCCommand.md)
Triggers a JumpCloud Command to run by calling the trigger associated with the Command.

### [Invoke-JCDeployment](Invoke-JCDeployment.md)
Triggers a JumpCloud Command Deployment using the CommandID and a filled out deployment CSV file.

### [New-JCCommand](New-JCCommand.md)
Creates a new JumpCloud Mac, Linux, or Windows command

### [New-JCDeploymentTemplate](New-JCDeploymentTemplate.md)
A guided walk through that creates a command deployment CSV file on your local machine.

### [New-JCImportTemplate](New-JCImportTemplate.md)
A guided walk through that creates a JumpCloud User Import CSV file on your local machine.

### [New-JCRadiusServer](New-JCRadiusServer.md)
Creates a JumpCloud radius server.

### [New-JCSystemGroup](New-JCSystemGroup.md)
Creates a JumpCloud System Group

### [New-JCUser](New-JCUser.md)
Creates a JumpCloud User

### [New-JCUserGroup](New-JCUserGroup.md)
Creates a JumpCloud User Group

### [Remove-JCAssociation](Remove-JCAssociation.md)
Remove an association between two object within the JumpCloud console.

### [Remove-JCCommand](Remove-JCCommand.md)
Removes a JumpCloud command

### [Remove-JCCommandResult](Remove-JCCommandResult.md)
Removes a JumpCloud Command Result

### [Remove-JCCommandTarget](Remove-JCCommandTarget.md)
Removes the association between a JumpCloud system or a JumpCloud system group from a JumpCloud command

### [Remove-JCRadiusReplyAttribute](Remove-JCRadiusReplyAttribute.md)
Removes Radius reply attributes from a JumpCloud user group.

### [Remove-JCRadiusServer](Remove-JCRadiusServer.md)
Removes a JumpCloud radius server.

### [Remove-JCSystem](Remove-JCSystem.md)
Removes a JumpCloud system.

### [Remove-JCSystemGroup](Remove-JCSystemGroup.md)
Removes a JumpCloud System Group

### [Remove-JCSystemGroupMember](Remove-JCSystemGroupMember.md)
Removes a JumpCloud System from a JumpCloud System Group

### [Remove-JCSystemUser](Remove-JCSystemUser.md)
Disables a JumpCloud User account on a JumpCloud System.

### [Remove-JCUser](Remove-JCUser.md)
Removes a JumpCloud User

### [Remove-JCUserGroup](Remove-JCUserGroup.md)
Removes a JumpCloud User Group

### [Remove-JCUserGroupMember](Remove-JCUserGroupMember.md)
Removes a JumpCloud User from a JumpCloud User Group

### [Send-JCPasswordReset](Send-JCPasswordReset.md)
Sends a JumpCloud activation/password reset email.

### [Set-JCCommand](Set-JCCommand.md)
Updates an existing JumpCloud command

### [Set-JCOrganization](Set-JCOrganization.md)
Allows a multi tenant admin to update their connection to a specific JumpCloud organization.

### [Set-JCRadiusReplyAttribute](Set-JCRadiusReplyAttribute.md)
Updates or adds Radius reply attributes to a JumpCloud user group.

### [Set-JCRadiusServer](Set-JCRadiusServer.md)
Updates a JumpCloud radius server.

### [Set-JCSystem](Set-JCSystem.md)
Updates an existing JumpCloud System

### [Set-JCSystemUser](Set-JCSystemUser.md)
Updates the permissions of a JumpCloud user on a JumpCloud system

### [Set-JCUser](Set-JCUser.md)
Updates an existing JumpCloud User

### [Set-JCUserGroupLDAP](Set-JCUserGroupLDAP.md)
The Set-JCUserGroupLDAP command adds or removes a JumpCloud user group and the members to/from the JumpCloud LDAP directory.

### [Update-JCModule](Update-JCModule.md)
Running this function will trigger the update of the JumpCloud PowerShell module.

### [Update-JCUsersFromCSV](Update-JCUsersFromCSV.md)
Updates a set of JumpCloud users from a CSV file created using the New-JCImportTemplate function.


