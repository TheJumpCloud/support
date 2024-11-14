---
Module Name: JumpCloud
Module Guid: 31c023d1-a901-48c4-90a3-082f91b31646
Download Help Link: https://github.com/TheJumpCloud/support/wiki
Help Version: 2.15.0
Locale: en-Us
---

# JumpCloud Module
## Description
PowerShell functions to manage a JumpCloud Directory-as-a-Service

## JumpCloud Cmdlets
### [Add-JCAssociation](Add-JCAssociation.md)
Create an association between two object within the JumpCloud console.

### [Add-JCCommandTarget](Add-JCCommandTarget.md)
Associates a JumpCloud system or a JumpCloud system group with a JumpCloud command

### [Add-JCGsuiteMember](Add-JCGsuiteMember.md)
Adds a user or usergroup to a GSuite instance

### [Add-JCOffice365Member](Add-JCOffice365Member.md)
Adds a user or usergroup to an Office365 instance

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

### [Get-JCAdmin](Get-JCAdmin.md)
Gets JumpCloud administrators in your organization

### [Get-JCAssociation](Get-JCAssociation.md)
The function Get-JCAssociation can be used to query an object's associations and then provide information about how objects are associated with one another.

### [Get-JCBackup](Get-JCBackup.md)
Backs up JumpCloud directory information to CSV

### [Get-JCCloudDirectory](Get-JCCloudDirectory.md)
Returns all Cloud Directory instances within a JumpCloud tenant, a single Cloud Directory instance using the -ID or -Name Parameter, or directories matching a single type using the -Type Parameter.

### [Get-JCCommand](Get-JCCommand.md)
Returns all JumpCloud Commands within a JumpCloud tenant or a single JumpCloud Command using the -ByID Parameter.

### [Get-JCCommandResult](Get-JCCommandResult.md)
Returns all JumpCloud Command Results within a JumpCloud tenant or a single JumpCloud Command Result using the -ByID Parameter.

### [Get-JCCommandTarget](Get-JCCommandTarget.md)
Returns the JumpCloud systems or system groups associated with a JumpCloud command.

### [Get-JCConfiguredTemplatePolicy](Get-JCConfiguredTemplatePolicy.md)
{{ Fill in the Synopsis }}

### [Get-JCEvent](Get-JCEvent.md)
Query the API for Directory Insights events

### [Get-JCEventCount](Get-JCEventCount.md)
Query the API for a count of matching events

### [Get-JCGroup](Get-JCGroup.md)
Returns all JumpCloud System and User Groups.

### [Get-JCOrganization](Get-JCOrganization.md)
Returns all JumpCloud organizations associated with the authenticated JumpCloud admins account.

### [Get-JCPolicy](Get-JCPolicy.md)
Returns all JumpCloud Policies within a JumpCloud tenant.

### [Get-JCPolicyGroup](Get-JCPolicyGroup.md)
Returns all policy groups, policy groups by name or id.

### [Get-JCPolicyGroupMember](Get-JCPolicyGroupMember.md)
This function will return the policies that are members of the specified policy group.

### [Get-JCPolicyGroupTemplate](Get-JCPolicyGroupTemplate.md)
{{ Fill in the Synopsis }}

### [Get-JCPolicyGroupTemplateMember](Get-JCPolicyGroupTemplateMember.md)
{{ Fill in the Synopsis }}

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

### [Get-JCScheduledUserstate](Get-JCScheduledUserstate.md)
Returns scheduled userstate changes by state or returns a user's scheduled userstate changes

### [Get-JCSystem](Get-JCSystem.md)
Returns all JumpCloud Systems within a JumpCloud tenant or a single JumpCloud System using the -ByID Parameter.

### [Get-JCSystemApp](Get-JCSystemApp.md)
Returns the applications/programs/linux packages installed on JumpCloud managed system(s). This function queries separate system insights tables to get data for macOS/windows/linux devices.

### [Get-JCSystemGroupMember](Get-JCSystemGroupMember.md)
Returns the System Group members of a JumpCloud System Group.

### [Get-JCSystemInsights](Get-JCSystemInsights.md)
JumpCloud's System Insights feature provides admins with the ability to easily interrogate their fleet of systems to find important pieces of information.
Using this function you can easily gather heightened levels of information from your fleet of JumpCloud managed systems.

### [Get-JCSystemKB](Get-JCSystemKB.md)
Returns applied hotfixes/KBs on Windows devices

### [Get-JCSystemUser](Get-JCSystemUser.md)
Returns all JumpCloud Users associated with a JumpCloud System.

### [Get-JCUser](Get-JCUser.md)
Returns all JumpCloud Users within a JumpCloud tenant or searches for a JumpCloud User by 'username', 'firstname', 'lastname', or 'email'.

### [Get-JCUserGroupMember](Get-JCUserGroupMember.md)
Returns the User Group members of a JumpCloud User Group.

### [Import-JCCommand](Import-JCCommand.md)
Imports a Mac, Linux or Windows JumpCloud Command into the JumpCloud admin portal from a URL

### [Import-JCMSPFromCSV](Import-JCMSPFromCSV.md)
Imports a list of JumpCloud MSP organizations from a CSV file created using the New-JCMSPImportTemplate function.

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

### [New-JCMSPImportTemplate](New-JCMSPImportTemplate.md)
Creates a CSV file to either create new or update existing MSP organizations in a MSP tenant.

### [New-JCPolicy](New-JCPolicy.md)
New-JCPolicy creates new JumpCloud Policies in an organization by TemplateID or TemplateNames. JumpCloud policies can be created in three different ways. The New/Set-JCPolicy functions each have a dynamic set of parameters specific to each policy template, this dynamic set of parameters is generated after specifying a valid TemplateID or TemplateName. New/Set-JCPolicy functions can also be set through a valid `value` parameter which is specific to each template policy. Lastly, New/Set-JCPolicy functions can be set through a guided interface.

TemplateIDs or TemplateNames are required to identify which JumpCloud Policy to be built. TemplateIDs can be found by looking at the JumpCloud Console URL while creating new policies. TemplateNames can be dynamically pulled in while using the `New-JCPolicy` function by typing: `New-JCPolicy -TemplateName *tab*` where the tab key is pressed in place of `*tab*`, if prompted, press 'y' to list all policies. Policies by operating system can be 'searched' by typing `darwin` (macOS), `windows`, `linux`, `ios`. For example, `New-JCPolicy -TemplateName darwin*tab*` where the tab key is pressed in place of `*tab*`, the list of available macOS policies would then be displayed and can be autocompleted through further tab presses.

At a minimum to display the dynamic set of parameters per template, the `TemplateID` or `TemplateName` must be specified. Tab actions display the available dynamic parameters available per function. For example, `New-JCPolicy -TemplateName darwin_Login_Window_Text -*tab*` where the tab key is pressed in place of `*tab*`, would display available parameters specific to the `darwin_Login_Window_Text` policy. Dynamic parameters for templates are displayed after the `Name` and `Values` parameters, and are generally camelCase strings like `LoginwindowText`.

### [New-JCPolicyGroup](New-JCPolicyGroup.md)
{{ Fill in the Synopsis }}

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

### [Remove-JCGsuiteMember](Remove-JCGsuiteMember.md)
Removes a user or usergroup from a GSuite instance

### [Remove-JCOffice365Member](Remove-JCOffice365Member.md)
Removes a user or usergroup from an Office365 instance

### [Remove-JCPolicy](Remove-JCPolicy.md)
Removes a JumpCloud Policy

### [Remove-JCPolicyGroup](Remove-JCPolicyGroup.md)
{{ Fill in the Synopsis }}

### [Remove-JCPolicyGroupTemplate](Remove-JCPolicyGroupTemplate.md)
{{ Fill in the Synopsis }}

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

### [Set-JCCloudDirectory](Set-JCCloudDirectory.md)
Updates an existing Cloud Directory instance within a JumpCloud tenant

### [Set-JCCommand](Set-JCCommand.md)
Updates an existing JumpCloud command

### [Set-JCOrganization](Set-JCOrganization.md)
Allows a multi tenant admin to update their connection to a specific JumpCloud organization.

### [Set-JCPolicy](Set-JCPolicy.md)
Set-JCPolicy updates existing JumpCloud Policies in an organization by PolicyID or PolicyName. JumpCloud policies can be updated in three different ways. The New/Set-JCPolicy functions each have a dynamic set of parameters specific to each policy template, this dynamic set of parameters is generated after specifying a valid TemplateID or PolicyName. New/Set-JCPolicy functions can also be set through a valid `value` parameter which is specific to each template policy. Lastly, New/Set-JCPolicy functions can be set through a guided interface.

PolicyIDs or PolicyNames are required to identify which JumpCloud Policy to be built. TemplateIDs can be found by looking at the JumpCloud Console URL on existing policies or running `Get-JCpolicy -Name "Some Policy Name` to get the policy by ID. PolicyNames can be specified if you know the name of a policy you wish to update or by running `Get-JCpolicy -Name "Some Policy Name` to get the policy by Name

Set-JCPolicy can display the available parameters per policy if a `PolicyName` or `PolicyID` is specified. Tab actions display the available dynamic parameters available per function. For example, `Set-JCPolicy -PolicyName "macOS - Login Window Policy" -*tab*` where the tab key is pressed in place of `*tab*`, would display available parameters specific to the `macOS - Login Window Policy` policy. Dynamic parameters for policies are displayed after the `Name` and `Values` parameters, and are generally camelCase strings like `LoginwindowText`.

### [Set-JCPolicyGroup](Set-JCPolicyGroup.md)
{{ Fill in the Synopsis }}

### [Set-JCRadiusReplyAttribute](Set-JCRadiusReplyAttribute.md)
Updates or adds Radius reply attributes to a JumpCloud user group.

### [Set-JCRadiusServer](Set-JCRadiusServer.md)
Updates a JumpCloud radius server.

### [Set-JCSettingsFile](Set-JCSettingsFile.md)
Updates the JumpCloud Module Settings File

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

### [Update-JCMSPFromCSV](Update-JCMSPFromCSV.md)
Updates a list of JumpCloud MSP organizations from a CSV file created using the New-JCMSPImportTemplate function.

### [Update-JCUsersFromCSV](Update-JCUsersFromCSV.md)
Updates a set of JumpCloud users from a CSV file created using the New-JCImportTemplate function.


