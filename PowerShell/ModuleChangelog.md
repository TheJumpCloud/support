## 1.18.7

Release Date: September 30, 2021

#### RELEASE NOTES

```
{{Fill in the Release Notes}}
```

#### FEATURES:

{{Fill in the Features}}

#### IMPROVEMENTS:

{{Fill in the Improvements}}

#### BUG FIXES:

{{Fill in the Bug Fixes}}

## 1.18.6

Release Date: September 03, 2021

#### RELEASE NOTES

```
* Updated the help docs for Get-JCSystemInsights
```

## 1.18.5

Release Date: June 23, 2021

#### RELEASE NOTES

* switch to circleci pipeline
* Update tsts with valid radius reply attributes

## 1.18.4

Release Date: May 03, 2021

#### RELEASE NOTES

* Invoke-JCDeployment updated to use SDK versions of the PowerShell Module

#### FEATURES

#### IMPROVEMENTS

#### BUG FIXES

* Invoke-JCDeployment will no longer reset a command type to linux when run

## 1.18.3

Release Date: January 04, 2021

#### RELEASE NOTES

* New Function, Backup-JCOrganization
  * https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Docs/Backup-JCOrganization.md
* Get-JCBackup will no longer be supported and will soon be deprecated; Please use Backup-JCOrganization.

#### FEATURES

* Backup-JCOrganization can be used to backup your JumpCloud organization to local json files

#### IMPROVEMENTS

* Misc internal improvements.
* User agent has been updated to accommodate for JcSlackBot tracking.

#### BUG FIXES

## 1.18.2

Release Date: September 3, 2020

#### RELEASE NOTES

The  `*-Association` functions now call functions from the  `JumpCloud.SDK.V2` instead of custom `Invoke-WebRequest` calls.

#### FEATURES:

#### IMPROVEMENTS:

The  `*-Association` functions now call functions from the  `JumpCloud.SDK.V2` instead of custom `Invoke-WebRequest` calls. The functions no longer return objects with `IsSuccessStatusCode` and `Error` properties.

#### BUG FIXES:

## 1.18.1

Release Date: August 14, 2020

#### RELEASE NOTES

* `Get-JCUser` and `Get-JCSystem` updated to accept dates as a `datetime` type.
  * Prevents "String not recognized as valid datetime" error in other non en-US regions

#### FEATURES:

#### IMPROVEMENTS:

Testing the JumpCloud PowerShell module and dependent JumpCloud.SDK.* modules with private repositories is supported.

#### BUG FIXES:

Dates in Get-JCuser and Get-JCSystem are now passed in as datetime types which prevents localization conversion errors

## 1.18.0

Release Date: August 13, 2020

#### RELEASE NOTES

* `Get-JCSystemInsights` has been updated to use the `JumpCloud.SDK.V2` powershell module.
  * Feature Enhancements
    * New SystemInsights tables will be automatically added they become available.
    * By using tab complete on the `-Filter` parameter an example of how to build the filter will be populated.
  * Breaking Changes
    * Table names no longer contain special characters. ex: `_`, `-`
    * Returned object properties no longer contain special characters. ex: `_`, `-`
    * Table names are singular instead of plural.
    * Dropping the `-Name` parameter to increase performance.

#### FEATURES

Get-JCEvent and Get-JCEventCount functions now work with MTP API Keys.
Get-JCSystemInsights tables are pulled automatically from JumpCloud.SDK.V2 module.
Remove depreciated SystemInsights WindowsCrashes table.

#### IMPROVEMENTS

#### BUG FIXES

## 1.17.5

Release Date: July 20, 2020

#### RELEASE NOTES

Use Get-JCSystemInsight to query additional System Insights tables.

#### FEATURES

Updated Get-JCEvent.
New function Get-JCEventCount.
Remove Depreciated SystemInsights Registry Table.

#### IMPROVEMENTS

#### BUG FIXES

Fix for windows PowerShell Update-JCModule function.
Fix for pipeline to specify manual version of module

## 1.17.3

Release Date: June 25, 2020

#### RELEASE NOTES

Use Get-JCSystemInsight to query additional System Insights tables.

#### FEATURES

Query new SystemInsights tables: alf_exceptions, alf_explicit_auths, appcompat_shims, authorized_keys, connectivity, dns_resolvers, wifi_networks, wifi_status, and windows_security_products

#### IMPROVEMENTS

Allow for Get-JCPolicy parameters $PolicyID and $Name to take multiple strings

Clean up of tls settings

#### BUG FIXES

Add retry values to resolving 500 errors

## 1.17.2

Release Date: May 18, 2020

#### RELEASE NOTES

```
Bug fix PowerShell 5.1 users launching Connect-JCOnline
```

#### FEATURES

#### IMPROVEMENTS

#### BUG FIXES

String Concatenation syntax fix for Update-JCModule

## 1.17.1

Release Date: May 04, 2020

#### RELEASE NOTES

```
Bug fix for when user calls: Get-Help -online Get-JCEvent
```

#### FEATURES

#### IMPROVEMENTS

#### BUG FIXES

Help link fix for Get-JCEvent

## 1.17.0

#### RELEASE DATE

April 30, 2020

#### RELEASE NOTES

Minor changes to make the auto-update functionality more robust.

Use Get-JCEvent to query JumpCloud event logs.

#### FEATURES

#### IMPROVEMENTS

New functions: Get-JCEvent

Auto-update now utilizes metadata from the PowerShell Gallery to determine when an update is available

#### BUG FIXES

## 1.16.0

#### RELEASE DATE

March 30, 2020

#### RELEASE NOTES

Use Get-JCSystemInsight to query additional System Insights tables including interface_details

#### FEATURES

Query new SystemInsights tables: certificates, cups_destinations, interface_details, python_packages, registry, scheduled_tasks, services and startup_items

#### IMPROVEMENTS

#### BUG FIXES

Resolved issue with Invoke-JCCommand when calling commands without variables

## 1.15.5

#### RELEASE DATE

March 25, 2020

#### RELEASE NOTES

Need to update users email addresses in bulk? You can now do that using New-JCImportTemplate and Update-JCUsersFromCSV

#### Features

#### IMPROVEMENTS

#### BUG FIXES

Resolved issue that caused module to attempt to update when running the latest version


## 1.15.4

#### RELEASE DATE

February 19, 2020

#### RELEASE NOTES

Need to update users email addresses in bulk? You can now do that using New-JCImportTemplate and Update-JCUsersFromCSV

#### FEATURES

Ability to add email column to output of New-JCImportTemplate when updating users

#### IMPROVEMENTS

#### BUG FIXES

Resolved issue that could cause issues with regional DateTime formats

## 1.15.3

#### RELEASE DATE

January 9, 2020

#### RELEASE NOTES

You can now update all attributes of a RADIUS server using Set-JCRadiusServer.
New parameters added to Get-JCSystem and Get-JCUser.

#### FEATURES

Set-JCRadiusServer can now update userPasswordExpirationAction, userLockoutAction, and mfa
Get-JCUser now can return the mfa property using -returnProperties
Get-JCSystem can now search for macOS machines with the JumpCloud Service Account using the -hasServiceAccount parameter
Get-JCSystem can now return the hasServiceAccount, fileSystem properties using -returnProperties

#### IMPROVEMENTS

#### BUG FIXES

## 1.15.2

#### RELEASE DATE

December 19, 2019

#### RELEASE NOTES

Support for UTF-8 encoding and new SystemInsights tables available and ability to filter systems on lastContact date.

#### FEATURES

Get-JCSystem -filterDateProperty parameter now accepts lastContact in addition to created.

New SystemInsights tables available:

* alf
* battery
* crashes
* ie_extensions
* launchd
* logged_in_users
* managed_policies
* shadow
* shared_folders
* shared_resources
* sharing_preferences
* sip_config
* usb_devices
* user_groups
* user_ssh_keys

#### IMPROVEMENTS

Support for UTF-8 encoding.

#### BUG FIXES

## 1.15.1

#### RELEASE DATE

October 22, 2019

#### RELEASE NOTES

Bug fixes to underlying functions preventing default values for skip, limit, and paginate to be populated.

#### FEATURES

#### IMPROVEMENTS

Improved performance of Get-JCBackup command.

#### BUG FIXES

The function which sets the default values for dynamic parameters was incorrectly filtering parameter sets for dynamic parameters that were passed in causing some parameters default values not to be established.

## 1.15.0

#### RELEASE DATE

October 08, 2019

#### RELEASE NOTES

Addressing bugs impacting associations functions.

#### FEATURES

#### IMPROVEMENTS

New functions: Copy-JCAssociation
Removing script block used debugging and simplifying with function.
Allow Get-JCBackup to take pipeline input.
Update Get-JCBackup to use newer functions.

#### BUG FIXES

When piping to a *-JCAssociations function there was a variable scoping issue that incorrectly set the `skip` and `limit` values.
When running a *-JCAssociations function JC types with only one target type were not correctly being populated due to an unnecessary validation step.

## 1.14.0

#### RELEASE DATE

September 12, 2019

#### RELEASE NOTES

```
Functions to interact with JumpCloud Radius Servers are now available
!!!*****************************************
!!!IF YOU RECEIVE AN ERROR WHILE UPDATING THE MODULE PLEASE RUN:
Install-Module JumpCloud -force
!!!*****************************************
```

#### FEATURES

New functions:

- Get-JCRadiusServer
- Remove-JCRadiusServer
- New-JCRadiusServer
- Set-JCRadiusServer

#### IMPROVEMENTS

Updated logic for Connect-JCOnline.
Improved module welcome page.
Changes for SystemInsights moving out of EA.

#### BUG FIXES

## 1.13.3

#### RELEASE DATE

September 04, 2019

#### RELEASE NOTES

```
Systeminsights improvements.
*****************************************
IF YOU RECEIVE AN ERROR WHILE UPDATING THE MODULE PLEASE RUN:
Install-Module JumpCloud -force
*****************************************
```

#### FEATURES

#### IMPROVEMENTS

- Additional systeminsights tables have been added: etc_hosts, logical_drives, disk_info, bitlocker_info, patches, programs
- Systeminsights id property has been renamed from `jc_system_id` to `system_id`.

#### BUG FIXES

## 1.13.2

#### RELEASE DATE

August 19, 2019

#### RELEASE NOTES

```
Bug fixes for connecting to a JumpCloud organization with no name specified.
Bug fix for functions that call Connect-JCOnline to set an API key if key is not set.
Formatting update for Connect-JCOnline output.
```

#### FEATURES

#### IMPROVEMENTS

- Updated Function: Connect-JCOnline with output information formatting updates.
- Moved parameter help messages from help files to functions to assist with dynamic building of documentation.

#### BUG FIXES

- Updated Function: Connect-JCOnline to return function output if called within the begin block of a function.
- Updated functions to call Connect-JCOnline to set API key if key is not set.

## 1.13.1

#### RELEASE DATE

August 8, 2019

#### RELEASE NOTES

```
Bug fixes for MTP admins that manage a large amount of orgs.
New parameter "-SystemFDEKey" on Get-JCSystem to backup SystemFDEKeys.
Enable SystemInsights for systems using new boolean parameter "-systemInsights" and Set-JCSystem.
```

#### FEATURES

- Updated Function: Get-JCSystem with "-SystemFDEKey" parameter to return the SystemFDEKey for JumpCloud enabled encrypted systems when a system is searched for by JumpCloud SystemID.

- Updated Function: Set-JCSystem with boolean parameter "-systemInsights" to enable or disable SystemInsights reporting for systems for EA enabled orgs.

- New Function: Update-JCModule allows the user to check and see if a module update is available and will return release notes.

#### IMPROVEMENTS

- Updated Function: Connect-JCOnline with new logic an UI for display release notes and improved module auto update logic.

#### BUG FIXES

- Updated Function: Set-JCOrganization to allow admins to successfully connect to for MTP admins that manage 10+ organizations have been resolved.

## 1.13.0

#### RELEASE DATE

July 16, 2019

#### RELEASE NOTES

```
Changes for automating build and testing of module.
New function Get-JCSystemInsights.
Updated Function: Get-JCSystem with new parameter "-SystemFDEKey"
to return the SystemFDEKey.
```

#### FEATURES

- New Function: Use Get-JCSystemInsights to leverage the new EA system insights API endpoints. These endpoints allow admins to query additional system details for systems that are enabled for System Insights. [Find more information about System Insights here](https://jumpcloud-success.s3.amazonaws.com/resources/System+Insights+Early+Access.pdf)
- Updated Function: Get-JCSystem to allow for revealing the FileVault or BitLocker key. Use the "Switch" parameter "-SystemFDEKey" to display this key from the PowerShell terminal.
- Updated Function: Get-JCSystem "-returnProperties" parameter set to include "fde" and "systemInsights".

#### IMPROVEMENTS

Remove dynamic validate set functionality for -Id and -Name parameters due to performance issues.
Updated test files to contain code within the describe blocks.
Renamed private function files to match the same name of the function within.
New Get-JCCommonParameters function.

#### BUG FIXES

N/A

## 1.12.1

#### RELEASE DATE

June 17, 2019

```
Bug fixes for association functions.
```

#### FEATURES

#### IMPROVEMENTS

#### BUG FIXES

Resolved issue where association types would return incorrect order.
Removed Windows dependency for IE by adding `-UseBasicParsing` to Invoke-Webrequest.

## 1.12.0

#### RELEASE DATE

June 6, 2019

```
Use Add-JCAssociation and Remove-JCAssociation to modify associations between objects in JumpCloud.
Get-JCAssociation can be piped into Add-JCAssociation or Remove-JCAssociation to make modifications at scale.
User/systems, systems/commands, user_group/applications...etc
```

#### FEATURES

- New-Function: Add-JCAssociation leverages the V2 associations endpoint to add direct associations between an input object and any of it's possible JumpCloud objects associations.
- New-Function: Remove-JCAssociation leverages the V2 associations endpoint to remove direct associations between an input object and any of it's possible JumpCloud objects associations.

#### IMPROVEMENTS

Added increased functionality to PowerShell user_agent.
Added new attributes "external_dn" and "external_source_type" for managing ADB users to the Set-JCUser and Get-JCUser functions.

#### BUG FIXES

Fixed bug on Get-JCGroup to return an error if a group is searched for by name and it does not exist.

## 1.11.0

#### RELEASE DATE

May 8, 2019

```
Use Get-JCAssociation to query associations between objects in JumpCloud.
Report on the associations between any two objects.
User/systems, systems/commands, user_group/applications...etc
All available now directly from the Pwsh terminal!
```

- New Function: Get-JCAssociation leverages the V2 associations endpoint to return the associations between an input object and any of it's possible JumpCloud objects associations. See [How To Use The Associations Functions](https://github.com/TheJumpCloud/support/wiki/How-To-Use-The-Associations-Functions) for more information.

#### IMPROVEMENTS

Added private functions to standardize API calls to policy endpoints.
Updated test file structure and methodology.

## 1.10.2

#### RELEASE DATE

April 29, 2019

#### RELEASE NOTES

```
Update Set-JCUser to not allow null values for nested properties
```

#### BUG FIXES

- Resolves an issue that would set null values when using Set-JCUser to update the nested "addresses" property.

## 1.10.1

#### RELEASE DATE

February 19, 2019

#### RELEASE NOTES

```
Update New-JCUser and Set-JCUser to interact with the property mfa instead of the mfaData property when using the parameter enable_user_portal_multifactor to enable mfa for a user.
```

#### IMPROVEMENTS

- This change aligns with recent work done to improve the mfa workflow for JumpCloud end users.

## 1.10.0

#### RELEASE DATE

January 21, 2019

#### RELEASE NOTES

```
Use Get-JCPolicy, Get-JCPolicyResults, Get-JCPolicyTargetSystem and Get-JCPolicyTargetGroup to gather information on JumpCloud policies. New-JCUser and Set-JCUser functions have been updated to support MFA enrollment periods. Bug fix on Radius Reply Attributes functions for LDAP and Unix groups.
```

#### FEATURES

- New Function: Get-JCPolicy will return policies configured within the JumpCloud admin console.
- New Function: Get-JCPolicyResults will return policy results for a given PolicyName or PolicyID.
- New Function: Get-JCPolicyTargetSystem will return associated systems with a given PolicyName or PolicyID.
- New Function: Get-JCPolicyTargetGroup will return associated groups with a given PolicyName or PolicyID.
- Updated Function: New-JCUser to set a default enrollment peroid of 7 days for users that are created with '-enable_user_portal_multifactor' set to $true. If this value is set to $true the dynamic parameter -enrollmentDays can also be specified from 1 to 365.
- Updated Function: Set-JCUser to set a default enrollment peroid of 7 days for users that are updated with '-enable_user_portal_multifactor' set to $true. If this value is set to $true the dynamic parameter -enrollmentDays can also be specified from 1 to 365.

#### IMPROVEMENTS

Increased -limit value when querying users and system users from 100 to 1000
Increased performance of private Get-Hash_ID_Sudo function.

#### BUG FIXES

Fixed bug on Remove-JCUser command when trying to remove users by -UserID
Fixed bug on RADIUS functions that prevented the addition or removal of Attributes on JumpCloud user groups configured for LDAP or set up as Linux groups
Fixed bug in Import-JCUsersFromCSV and Update-JCUsersFromCSV where a null value for employeeIdentifier would report as duplicate

## 1.9.0

#### RELEASE DATE

November 29, 2018

#### RELEASE NOTES

```
Drastically increase the security of your networks using VLANs and RADIUS VLAN tagging!
Use the new RADIUS reply attribute functions to authenticate and authorize users to VLANs using JumpCloud RADIUS.
Add RADIUS reply attributes to JumpCloud user groups associated with RADIUS servers and implement dynamic per-user VLAN tagging on your network today.
New functions:
Add-JCRadiusReplyAttribute
Get-JCRadiusReplyAttribute
Set-JCRadiusReplyAttribute
Remove-JCRadiusReplyAttribute
```

#### FEATURES

RADIUS reply attributes can now be configured on JumpCloud user groups using functions in the JumpCloud PowerShell module. When applied, these attributes will be returned in the Access-Accept message of a RADIUS request. Reply attributes are specified on JumpCloud user groups. Attributes can be applied across multiple users and RADIUS servers through the association of JumpCloud users to JumpCloud user groups and then the association of these JumpCloud user groups to RADIUS servers.

Any RADIUS reply attributes configured on a JumpCloud user group which associates a user to a RADIUS server will be returned in the Access-Accept message sent to the endpoint configured to authenticate with JumpCloud Radius. If a user is a member of more then one JumpCloud user group associated with a given RADIUS server all Reply attributes for the groups that associate the user to the RADIUS server will be returned in the Access-Accept message.

If a user is a member of more then one JumpCloud user group associated with a given RADIUS server and these groups are configured with conflicting RADIUS reply attributes then the values of the attributes for the group that was created most recently will be returned in the Access-Accept message.

RADIUS reply attribute conflicts are resolved based on the creation date of the user group where groups that are created more recently take precedent over older groups. Conflicts occur when groups are configured with the same RADIUS reply attributes and have conflicting attribute values. RADIUS reply attributes with the same attribute names but different tag values do not create conflicts.

- New Function: Add-JCRadiusReplyAttribute Adds Radius reply attributes to a JumpCloud user group.
- New Function: Get-JCRadiusReplyAttribute Returns the Radius reply attributes associated with a JumpCloud user group.
- New Function: Set-JCRadiusReplyAttribute Updates or adds Radius reply attributes to a JumpCloud user group.
- New Function: Remove-JCRadiusReplyAttribute Removes Radius reply attributes from a JumpCloud user group.

## 1.8.3

#### RELEASE DATE

November 6, 2018

#### RELEASE NOTES

```
Bug fix for Get-JCGroup to display all group attributes.
Added functionality for JumpCloud internal developers to connect to staging and test environments using the module.
```

#### IMPROVEMENTS

- Updated Function: Connect-JCOnline has new parameter '-JCEnvironment' which JumpCloud developers can use to connect to staging and local test environments.
- Updated Function: Connect-JCOnline has new parameter '-UserAgent' which JumpCloud developers can use to set their UserAgent when using the module.

#### BUG FIXES

- Resolved bug on Get-JCGroup where all group attributes would not display.


## 1.8.2

#### RELEASE DATE

October 12, 2018

#### RELEASE NOTES

```
Bug fix for Get-JCCommandResult -limit parameter
Increased stability for multi-tenant admins
Check our full release notes to see new attribute additions released in 1.8.0
```

#### IMPROVEMENTS

- Increased stability for multi-tenant admins

#### BUG FIXES

- Resolved bug on Get-JCCommandResult where the limit of value of 1000 would cause an error. Default limit value updated to 100.

## 1.8.1

#### RELEASE DATE

September 21, 2018

#### RELEASE NOTES

```
Bug fix for Multi-Tenant orgs
Check our full release notes to see new attribute additions released in 1.8.0
```

#### BUG FIXES

- Resolved bug on Connect-JCOnline where JumpCloudOrgID would not set correctly

## 1.8.0

#### RELEASE DATE

September 20, 2018

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

#### FEATURES

New LDAP extended user attributes: middlename, preferredName, jobTitle, employeeIdentifier (must be unique), department, costCenter, company, employeeType, description, location
New LDAP telephony attributes: mobile_number, home_number, work_number, work_mobile_number, work_fax_number
New LDAP location attributes: home_streetAddress, home_poBox home_city, home_state, home_postalCode, home_country, work_streetAddress, work_poBox, work_locality, work_region, work_postalCode, work_country

[See how to update users in bulk using these new functions in this KB article](https://support.jumpcloud.com/customer/portal/articles/2956315)

- New Function: Update-JCUsersFromCSV to add or update all attributes including new LDAP attributes on your existing user , add users to groups, or bind them to systems in bulk from a CSV file.
- Updated Function: New-JCImportTemplate can now create custom **user update CSV import files** pre-populated with your JumpCloud users to plug into the new Update-JCUsersFromCSV
- Updated Function: New-JCUser has parameters for creating users with the new LDAP extended, telephony, and location attributes.
- Updated Function: Set-JCUser has parameters for updating a modifying users LDAP extended, telephony, and location attributes.
- Updated Function: Get-JCUser has the ability to search for a filter users based on extended LDAP users.
- Updated Function: New-JCImportTemplate workflow has been updated to prompt users with options to add the new LDAP extended, telephony, and location attributes to their CSV import templates.
- Updated Function: Import-JCUsersFromCSV will verify and error check the unique field employeeIdentifier. The output for Import-JCUsersfromCSV has also been cleaned up.

#### IMPROVEMENTS

- Updated parameters on Set-JCSystem to allow for modification of parameters via PowerShell pipeline.
- Removed 20 character limit on JumpCloud username field.
- Removed method which forced JumpCloud usernames to be lowercase.
- Updated New-JCImportTemplate to make CSV import file in current working directory.
- Updated Import-JCCommand to call Connect-JCOnline and set TLS to 1.2.
- Updated Function: Import-JCUsersFromCSV to use splatting which allows for CSV to contain columns with non JumpCloud user information
- Progress bars on Import-JCUsersFromCSV and Update-JCUsersFromCSV


## 1.7.0
#### RELEASE DATE

August 14, 2018

#### RELEASE NOTES

```
Take JumpCloud commands to the next level with Command Deployments!
New functions New-JCDeploymentTemplate and Invoke-JCDeployment.
Deployments are designed for automation scenarios where a 1:1 association between the command payload and JumpCloud system is required.
Use system specific payloads in your JumpCloud commands with variables populated from a CSV file.
```

#### FEATURES

- New Function: New-JCDeploymentTemplate used to create a deployment CSV template file that maps to the corresponding JumpCloud command variables to CSV columns.
- New Function: Invoke-JCDeployment for calling the command deployment and feeding the command the '-CommandID' of the target JumpCloud deploy command and the populated deployment CSV file.
- New Function: Set-JCCommand to update JumpCloud commands programmatically. This command is used by the Invoke-JCDeployment command to update the '-launchType' to trigger and trigger the command.

#### IMPROVEMENTS

- Warning action "Inquire" removed from Import-JCUsersFromCSV command. Resolves repetitive "Press Y to continue"  message during user validation.
- Streamlined JumpCloud banners. Because less is more.

#### BUG FIXES

- Resolved bug on 'Import-JCUserFromCSV' where output for users that were not created due to duplicate username or email would show previously created user information.
- Resolved bug on 'Import-JCUserFromCSV' where output for users that were not created would show 'User created'.


## 1.6.0
#### RELEASE DATE

August 3, 2018

#### RELEASE NOTES

```
Send activation/password reset emails with the new function Send-JCPasswordReset
Multi tenant support has been added!
Multi tenant admins will be asked to select the org they want to connect to during API authentication.
Multi tenant admins can switch the org they are connected to using the Set-JCOrganization command.
```

#### FEATURES

- New Function: Send-JCPasswordReset allows admins to use the 'Resend email' button functionality programmatically to send reset/activation emails to targeted users.
- New Function: Set-JCOrganization allows multi tenant admins to change the JumpCloud tenant they are conneted to.
- New Function: Get-JCOrganization allows multi tenant admins to see the JumpCloud tenants they have access to.
- Updated Function: Connect-JCOnline to prompt multi tenant admins to select their connected tenant. Admins can also skip this prompt by entering a 'JumpCloudOrgID' into the new '-JumpCloudOrgID' parameter to setup connection in automation scenarios.

#### IMPROVEMENTS

- All Public functions have been updated to include the [x-org-id](https://docs.jumpcloud.com/2.0/authentication-and-authorization/multi-tenant-organization-api-header) header when a multi tenant API connection is established.

## 1.5.0
#### RELEASE DATE

July 16, 2018

#### RELEASE NOTES

```
New Function: Get-JCBackup to backup user, system user, system, group information to CSV.
Updated Function: Get-JCCommandResult to show SystemID
```
#### FEATURES

- New Function: Get-JCBackup to backup user, system user, system, user group, and system group information to CSV
- Updated Function: Get-JCCommandResult to show SystemID when querying command results in bulk and '-ByID'

#### IMPROVEMENTS

- Module structure updated. .PSM1 function monolithic broken out into single function .PS1 files in [Public](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Public) and [Private](https://github.com/TheJumpCloud/support/tree/master/PowerShell/JumpCloud%20Module/Private) folders. This allows for easier debugging and updating of the functions within the module.

## 1.4.2
#### RELEASE DATE

May 31, 2018

#### RELEASE NOTES

```
Updated Function: Get-JCCommandResult with new parameter '-MaxResult'
Using the parameter '-Skip' and '-MaxResult' admins can return a specific subset of command results.
Performance fix for 'Get-JCCommandResult' with increase default limit to 1000
```
#### FEATURES

- Updated Function: Get-JCCommandResult with new parameters '-MaxResult'. '-MaxResult' can be combinded with '-Skip' to return a specific subset of command results.

#### IMPROVEMENTS

- Updated Function: Get-JCCommandResult speed and performance by removing sort.
- Updated Function: Get-JCCommandResult increased default limit to 1000 results.

## 1.4.1
#### RELEASE DATE

May 25, 2018

#### RELEASE NOTES

```
Updated Function: Get-JCCommandResult with new parameters '-TotalCount' and '-Skip'
'-TotalCount' returns the number of command results
'-Skip' returns only the results after a specified number
Bug fix for 'Get-JCSystem' to allow for pagination of over 1000 results.
```
#### FEATURES

- Updated Function: Get-JCCommandResult with new parameters '-TotalCount' to return the total number of command results and '-Skip' to return only command results after a specificed number. Using '-TotalCount' to first find the total number of results before running a command you can then use '-Skip' to query the new command results after running the command.

#### BUG FIXES

- Updated Functions: Get-JCSystem to allow for pagination of over 1000 results.


## 1.4.0
#### RELEASE DATE

May 18, 2018

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

#### FEATURES

- Updated Function:  Invoke-JCCommand has added parameter '-NumberOfVariables' for passing in variables to JumpCloud commands. This parameter will create additional parameters dynamically based on the number of variables being passed. Learn more about passing objects to JumpCloud commands under the heading 'Sending data with triggers' [here](https://support.jumpcloud.com/customer/en/portal/articles/2443894-how-to-use-command-triggers).
- Updated Function: Get-JCSystem to use the [/search/systems API endpoint](https://docs.jumpcloud.com/1.0/search/search-systems).
  - Get-JCSystem can now do front and end wild card searches on all string properties
    - Example 'Get-JCsystem -hostname '\*admin\*'
  - Get-JCSystem can now do date searches on 'Created' date field using new parameter -filterDateProperty
  - Get-JCSystem can now return only specific properties using new parameter -returnProperties
- Updated Function: Get-JCUser to use the [/search/systemusers API endpoint](https://docs.jumpcloud.com/1.0/search/list-system-users).
  - Get-JCUser can now do front and end wild card searches on all string properties
    - Example 'Get-JCUser -username '\*bob\*'
  - Get-JCUser can now do date searches on 'Created' and 'password_expiration_date' date fields using new parameter -filterDateProperty
  - Get-JCUser can now return only specific properties using new parameter -returnProperties


#### BUG FIXES

- Updated Functions: Get-JCSystemGroupMember to properly paginate results greater than 100 system group members.
- Updated Function:  Add-JCUserGroupMember to handle user error additions more gracefully.
- Updated Function: Connect-JCOnline to Write-Error instead of Write-Output if API key validation fails

#### IMPROVEMENTS

- Updated Helper Hash Functions to leverage the -returnProperties which speeds up hash table creation and overall performance.


## 1.3.0
#### RELEASE DATE

April 27, 2018

#### RELEASE NOTES

```
New Function: Set-JCUserGroupLDAP to toggle the LDAP presentation on/off for JumpCloud user groups.
New Function: Get-JCCommandTarget to query the JumpCloud systems or system groups associated with a JumpCloud command.
New Function: Add-JCCommandTarget to add JumpCloud system or system group associations to JumpCloud commands.
New Function: Remove-JCCommandTarget to remove JumpCloud system or system group associations from JumpCloud commands.
Updated Functions: Add-JCUser and Set-JCUser with boolean parameter '-password_never_expires'
```

#### FEATURES

- New Function: Set-JCUserGroupLDAP to toggle the LDAP presentation on/off for JumpCloud user groups.
- New Function: Get-JCCommandTarget to query the JumpCloud systems or system groups associated with a JumpCloud command.
- New Function: Add-JCCommandTarget to add JumpCloud system or system group associations to JumpCloud commands.
- New Function: Remove-JCCommandTarget to remove JumpCloud system or system group associations from JumpCloud commands.
- Updated Functions: Add-JCUser and Set-JCUser with boolean parameter 'password_never_expires'.


#### BUG FIXES

- Updated Functions: Add-JCUser and Set-JCUser to allow UNIX_UID and UNIX_GUID to a value in the range 0-4294967295.
- Updated Function: Get-JCSystemGroupMember to properly display output when using the 'ByID' parameter set.


## 1.2.0
#### RELEASE DATE

February 28, 2018

#### RELEASE NOTES

```
New Function New-JCCommand and Remove-JCCommand to create and remove JumpCloud commands from the shell.
New Function Import-JCCommand to import JumpCloud commands from a URL
Updated Function Get-JCUser to search users via username, firstname, lastname, or email
Updated Function Connect-JCOnline to check for and install module updates and added '-force' parameter for use in scripts and automation
```

#### FEATURES

- New Function: New-JCCommand to create JumpCloud commands from the shell
- New Function: Remove-JCCommand to delete JumpCloud commands
- New Function: Import-JCCommand to import JumpCloud commands from a URL
- Updated Function: Get-JCUser to use the same search endpoint as the UI. Get-JCUser can now search via 'username','firstname','lastname', or 'email'. By default Get-JCUser still returns all users.
- Updated Function: Connect-JCOnline added banner to display current JumpCloud module version information. Added parameter sets for 'Interactive' and 'Force' modes. 'Interactive' displays banner and automatic module update options when new version becomes available. 'Force' can be used in automation scenarios to connect to JumpCloud and set $JCAPIKEY variable.


#### IMPROVEMENTS

- Updated Function: Add-JCUserGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command
- Updated Function: Add-JCSystemGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command
- Updated Function: Remove-JCUserGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command
- Updated Function: Remove-JCSystemGroupMember with 'name' alias for 'GroupName' parameter to allow the command to accept pipeline input from the 'Get-JCGroup' command

## 1.1.0
#### RELEASE DATE

January 8, 2018

#### RELEASE NOTES

```
New function Set-JCSystemUser to set user / system permissions to standard or administrator.
Updated import functions and Add/Get-JCSystemUser to accommodate for user / system permissions.
```

#### FEATURES

- New Function: [Set-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Set-JCSystemUser) can modify user/system permissions and change the user from a standard user to an administrator or vice versa
- New Helper Function: Get-Hash_ID_Sudo hash table of UserID and ($true/$false) for Sudo parameter
- New Helper Function: Get-Hash_SystemID_HostName hash table of SystemID and system DisplayName


#### IMPROVEMENTS

- Updated Function: [Add-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Add-JCSystemUser) has boolean parameter '-Administrator' for setting system permissions during add
- Updated Function: [Get-JCSystemUser](https://github.com/TheJumpCloud/support/wiki/Get-JCSystemUser) to show system permissions 'Administrator: $true/$false' and system DisplayName
- Updated Function: [New-JCImportTemplate](https://github.com/TheJumpCloud/support/wiki/New-JCImportTemplate) to add in 'Administrator' header to .csv file when 'Y' is selected for 'Do you want to bind your new users to existing JumpCloud systems during import?'
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) to accept 'True/$True' and 'False/$False' or blank for the 'Administrator' header in the .csv import file
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) has switch '-Force' parameter to skip the Import GUI and data validation when importing users
- Updated Function: [Import-JCUserFromCSV](https://github.com/TheJumpCloud/support/wiki/Import-JCUsersFromCSV) to look for duplicate email addresses and usernames in import .csv as part of data validation
- Updated Function: [Get-JCGroup](https://github.com/TheJumpCloud/support/wiki/Get-JCGroup) has -Name parameter which can be used to find attributes like the POSIX group number of a given group



#### BUG FIXES

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

### [How to update to the latest version of the JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Updating-the-JumpCloud-PowerShell-Module)

## 1.0.0
#### RELEASE DATE

November 29, 2017
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
