[![Build status](https://dev.azure.com/JumpCloudPowershell/JumpCloud%20ADMU/_apis/build/status/JumpCloud%20ADMU-CI)](https://dev.azure.com/JumpCloudPowershell/JumpCloud%20ADMU/_build/latest?definitionId=13)

# Providing Feedback

The ADMU is currently in an Early Access (EA) period. 
Have feedback to share? Email support@jumpcloud.com to connect with a member of the JumpCloud success team.

The current ADMU Change Log can be found [Here](https://github.com/TheJumpCloud/support/blob/master/ADMU/CHANGELOG.md).

![ADMU Workflow Diagram](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/ADMU_workflow.png)

**Table Of Contents**

- [Providing Feedback](#providing-feedback)
- [About the JumpCloud AD Migration Utility](#about-the-jumpcloud-ad-migration-utility)
  - [Supported Operating System Versions](#supported-operating-system-versions)
  - [Requirements](#requirements)
  - [EULA & Legal Explanation](#eula--legal-explanation)
  - [Expected Performance](#expected-performance)
- [Known Issues](#known-issues)
  - [Limitations of User Account Conversion](#limitations-of-user-account-conversion)
- [ADMU Deployment Options](#admu-deployment-options)
  - [Download Links](#download-links)
  - [ADMU GUI](#admu-gui)
    - [Using the ADMU GUI](#using-the-admu-gui)
  - [ADMU Powershell Script](#admu-powershell-script)
    - [Using the ADMU Powershell Script](#using-the-admu-powershell-script)
  - [ADMU exe](#admu-exe)
    - [Using the ADMU exe](#using-the-admu-exe)
  - [Advanced Deployment Scenarios](#advanced-deployment-scenarios)
- [Error Logging & Troubleshooting Errors](#error-logging--troubleshooting-errors)
  - [Log Levels](#log-levels)
  - [Troubleshooting errors](#troubleshooting-errors)
- [Usage Notes and Examples](#usage-notes-and-examples)
  - [ADMU Steps - What is the script doing?](#admu-steps---what-is-the-script-doing)
    - [ADK & USMT INSTALLER](#adk--usmt-installer)
- [Definitions](#definitions)
  - [Windows ADK - Windows Assessment and Deployment Kit](#windows-adk---windows-assessment-and-deployment-kit)
  - [USMT - User State Migration Tool](#usmt---user-state-migration-tool)
  - [ADMU - Active Directory Migration Utility](#admu---active-directory-migration-utility)
  - [What Is In A Windows Profile](#what-is-in-a-windows-profile)
  - [Windows Profile Types](#windows-profile-types)
    - [Local user profile](#local-user-profile)
    - [Roaming user profile](#roaming-user-profile)
    - [Microsoft Account based profile](#microsoft-account-based-profile)
    - [Azure AD Profile Scenarios](#azure-ad-profile-scenarios)
      - [Azure AD Join](#azure-ad-join)
      - [Azure AD Registration](#azure-ad-registration)
      - [Hybrid Azure AD Join](#hybrid-azure-ad-join)
- [Future Development](#future-development)

# About the JumpCloud AD Migration Utility

## Supported Operating System Versions

- Windows 7 ships with .net 3.5.1 by default
- Windows 8.1 ships with .net 4.5 and .net 3.5 not enabled by default
- Windows 10 ships with .net 4.7 and .net 3.5 not enabled by default

 Currently both the GUI and EXE implementations require a specific .net version to load or run with no user interaction.

To account for this we currently have 2 versions of `jcadmu.exe` & `gui_jcadmu.exe`. The Windows 7 folder builds are based on `.net 3.5` and Windows 8-10 on `.net 4`.

[ADMU EXE Directory Link](https://github.com/TheJumpCloud/support/tree/master/ADMU/exe)

If for example the .net4+ version is run on win7 system the user would see the following.

![image46](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_46.png)

## Requirements
 The ADMU tool requires the following to work:

 * gui_jcadmu requires the system to be currently Domain bound (The system does NOT have to be actively connected to the Domain Controller).
 * A domain based profile must exist on the system to be converted to a local profile (conversion of local profile or azure profile to local profile will not currently work).

## EULA & Legal Explanation

 The ADMU tool utilizes multiple Microsoft utilities and installers depending on the deployment scenario and system state. In order to provide a silent/zero touch option for conversion the $acceptEULA value can be used. If this is not provided the user will have to interactively accept the Microsoft EULA relating to the 'Microsoft Windows ADK'. All microsoft software/tooling is sourced and downloaded from microsoft and used in its complete form with no modification to they code. By using the acceptEULA = $true flag, the ADMU tool will also install .net framework if required & C++ runtimes ifrequired for the JC system agent install.

![image24](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_24.png)

[Microsoft EULA PDF Link](https://github.com/TheJumpCloud/support/tree/master/ADMU/Microsoft%20Windows%20ADK%20EULA.pdf)

[Microsoft EULA RTF Link](https://github.com/TheJumpCloud/support/tree/master/ADMU/Microsoft%20Windows%20ADK%20EULA.rtf)
## Expected Performance

 **Approximate timings:**

 Timings are relative to the both the size and number of files present in the windows profile and the speed of the system and hardware.

 Some aproximations from VM i5-7260 2.2GHz, 512GB RAM

 :5 start → scanstate (USMT on win10)
 :40 start → scanstate (NO USMT on system)

 2:40 start → loadstate (USMT installed on win10)

 1:00 loadstate → install agent (win10 & 7 missing prereq c++)
 
 **Total Time Estimate: Between 2:30 → 5:00**


# Known Issues

## Limitations of User Account Conversion

 There are limitations to consider when using the USMT utility for user account conversion. Because of this it is recommended to follow a one, some, many approach for migration to understand what and how the tool can and can not do in your specific environment. This is where further investigation needs to be done on streamlining and improving/documenting common scenarios and workarounds.
 
 [Follow this link to see what gets migrated using the default settings of the USMT.](https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-what-does-usmt-migrate#bkmk-3)


 It would be possible to utilize the tool on a testing machine, convert a local account, keep the system bound to the domain and run both accounts in parallel. Investigate and be sure the newly converted ‘local account’ runs all applications and has all files as expected. Then switch over to that account and unbind from the domain. Providing this phased approach could help reduce friction and uncertainty in the process.

 Windows start menu layout will be lost & not migrated.

 Windows default apps, on first profile load the `default application` associations will be lost. These will need to be reconfigured in the `settings` application.

![image42](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_42.png)

 Applications that are installed and ran from the appdata directory may not migrate fully. E.g. Onedrive & Microsoft Teams. This may result in the need to resync, reinstall or update shortcuts for the new profile.

 After converting the account, outlooks .ost offline cache file must be recreated and the account re-logged into. However the office activation and association should still be present but require a reauth.

[https://blogs.technet.microsoft.com/askds/2010/02/11/usmt-ost-and-pst/](https://blogs.technet.microsoft.com/askds/2010/02/11/usmt-ost-and-pst/)

![image43](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_43.png)

 Outlook .ost file

# ADMU Deployment Options

Regardless of how you deploy the ADMU the utility will leave the selected domain account that is being migrated **untouched and fully intact**.
The ADMU leverages the USMT and settings to migrate user data from a domain account to a net new local account.
[Follow this link to see what gets migrated using the default settings of the USMT.](https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-what-does-usmt-migrate#bkmk-3)

## Download Links
GUI - gui_jcadmu.exe
* [GUI - Windows 7 / .net 3 ](https://github.com/TheJumpCloud/support/raw/master/ADMU/exe/Windows%207/gui_jcadmu_win7.exe) 
* [GUI - Windows 8.1-10 / .net 4 ](https://github.com/TheJumpCloud/support/raw/master/ADMU/exe/Windows%208-10/gui_jcadmu_win10.exe) 

EXE - jcadmu.exe
* [JCADMU.exe - Windows 7 / .net 3 ](https://github.com/TheJumpCloud/support/raw/master/ADMU/exe/Windows%207/jcadmu_win7.exe)
* [JCADMU.exe - Windows 8.1-10 / .net 4 ](https://github.com/TheJumpCloud/support/raw/master/ADMU/exe/Windows%208-10/jcadmu_win10.exe)

Powershell - Migration.ps1 & Functions.ps1
* [Powershell](https://github.com/TheJumpCloud/support/tree/master/ADMU/powershell)

## ADMU GUI
 This is a Powershell based GUI executable that utilizes WPF to collect input parameters to pass to the ADMU powershell code.

 If the GUI is ran and the system is not domain joined the utility will not let the user continue with the process. The only option is to quit the application.

![image7](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_7.png)

### Using the ADMU GUI

To use the GUI run the relevant .exe file for your system as administrator from the Download Links above. It is also required to unblock the Security setting stating `This file came from another computer and might be blocked to help protect this computer`. It may also be flagged by antivirus software and need to be excluded. This will be addressed by code signing the file in a future release and this step no longer be required.

![image48](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_48.png)

To resolve this right click on the .exe that you wish to run and select "Properties".


![image47](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_47.png)

On the security tab check the box for "Unblock" click "Ok" and you will be able to open the .exe

## ADMU Powershell Script

 This script can be passed the required parameters and utilized in larger or silent deployment scenarios as it is all CLI/PS based.

### Using the ADMU Powershell Script

 The powershell script Migration.ps1 requires Functions.ps1 to be present in the same directory as it relies on importing functions from the Functions.ps1 file to work.

![image8](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_8.png)


![image9](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_9.png)


```powershell
.\Migration.ps1 -DomainUserName 'tcruise' -JumpCloudUserName 'tom.cruise' -TempPassword 'Temp123!' -JumpCloudConnectKey '4e7699c4c1c1e3126fb627240723cb3g292ebc75' -AcceptEULA $true -InstallJCAgent $true -LeaveDomain $true -ForceReboot $true
```


 If the paramaters -AcceptEULA -InstallJCAgent -LeaveDomain  or -ForceReboot is not added to the command it will default to $false.


 The Powershell script has validation on the main parameters and requires them to not to be empty as well as the -jumpcloudconnectkey must be 40chars or it will not move forward.

![image10](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_10.png)


 Currently if you pass in a domain username that doesn’t exist it will continue and error at the 'user group addition' step in the script. Earlier Validation of this user accounts existence both locally and on the domain will be added into a future version of the tool to better gate and only allow conversions of possible accounts. This is controlled by the GUI implementation and its use of the selection list.

![image11](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_11.png)

![image12](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_12.png)

## ADMU exe

The Powershell code has also been packaged as an exe for various deployment scenarios.

The .exe verison of the ADMU is really just a wrapper and runs the same powershell code discussed above.

### Using the ADMU exe

 The exe can be run interactively and the parameters entered or via the command line using the -arguments option as seen below. If entered interactivly it will default -accepteula -installjcagent -leavedomain -forcereboot to $false.

```powershell
c:\jcadmu.exe -arguments -domainusername 'bob.lazar' -jumpcloudusername 'blazar' -temppassword 'Temp123!' -jumpcloudconnectkey 'CONNECTKEY' -accepteula $true -installjcagent $true -leavedomain $false -forcereboot $false
```
![image44](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_44.png)

![image45](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_45.png)

## Advanced Deployment Scenarios

 The ADMU has been developed with large scale deployments in mind. As the tool stands today we are looking to gather customer input on the various environments and use cases, from this we can tweak and improve to the tool to solve a range of scenarios and stream line the account conversion process.

 Powershell Remoting Scenario:

 It is possible to utilize Powershell Remoting to query, report & execute the ADMU tool on multiple systems from a domain controller or member server.

 Report local accounts example
```powershell
$systems = @('10ent17091', '10ent18031', '10ent18091', '10pro17091', '10pro18031', '10pro18091', '81pro', '7pro1')

Invoke-Command -ComputerName $systems { 
Get-WmiObject -Class:('Win32_UserProfile') -Property * | Where-Object {$_.Special -eq $false, $_.RoamingConfigured -eq $false} | `
Select-Object Loaded, @{Name = "LastLogin"; EXPRESSION = {$_.ConvertToDateTime($_.lastusetime)}}, @{Name = "UserName"; EXPRESSION = {(New-Object System.Security.Principal.SecurityIdentifier($_.SID)).Translate([System.Security.Principal.NTAccount]).Value}; } |FT
}
```

 Run local file with params example
```powershell
$remotesystem = "10ent17091"
Invoke-Command -ComputerName $remotesystem {
c:\ADMU\powershell\Migration.ps1 -DomainUserName 'tom.hanks' -JumpCloudUserName 'thanks' -TempPassword 'Temp123!' -JumpCloudConnectKey 'CONNECTKEY' -AcceptEULA $true -InstallJCAgent $true -LeaveDomain $true -ForceReboot $true
}
```

 Possible future deployment scenarios:
 * ADMU file deployment script & commands
 * Logon script via GPO
 * Meraki deployment
 * PDQ deployment
 * Intune deployment
 * MTP & MSP deployment


# Error Logging & Troubleshooting Errors

 The ADMU tool creates a log file in:
c:\windows\temp\jcadmu.log

## Log Levels

 * Information - Tells what is going on
```
2019-07-23 09:01:38 INFO: Download of Windows ADK Setup file completed successfully
```
 * Warning - A non script terminating error
```
2019-07-23 09:03:52 WARNING: Removal Of Temp Files & Folders Failed
```

 * Error - A script terminating error
```
2019-07-23 08:56:38 ERROR: System is NOT joined to a domain.
```

## Troubleshooting errors

 The JCADMU.log file can help troubleshoot possible issues with the tool and why it didn't complete. Below are some examples

```
ERROR: System is NOT joined to a domain.
```
The system is not bound to a domain, currently the tool requires this to convert domain accounts--local accounts.

```
ERROR: Microsoft Windows ADK - User State Migration Tool not found in c:\adk. Make sure it is installed correctly and in the required location.
```
The Microsoft Windows ADK must be installed in c:\adk. If it is previously installed in another directory the script will fail. In the future this will be changed to account for the default installer path in 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit'. To resolve this you would have to uninstall the ADK and either reinstall or let the script install in c:\adk.

```
ERROR: Failed To Download Windows ADK Setup
```
 If the download step fails to download the file to the directory the script will fail. This could be due to internet connectivity or other connection issues.

```
ERROR: Failed to complete scanstate tool
```
 the log will show the 'scanstate' command that is being run on the system, if it fails to complete the script will error out. The preceeding INFO log entry can help with troubleshooting and verifying if the command is correct. It is also possible the disk does not have sufficient space to complete the scanstate command.
```
INFO: Starting scanstate tool on user jcadb2\bob.lazar
```
```
INFO: Scanstate Command: .\scanstate.exe c:\Windows\Temp\JCADMU\store /nocompress /i:miguser.xml /i:migapp.xml /l:c:\Windows\Temp\JCADMU\store\scan.log /progress:c:\Windows\Temp\JCADMU\store\scan_progress.log /o /ue:*\* /ui: $netbiosname /c
```
```
ERROR: Failed to complete loadstate tool
```
 This is similar to the scanstate error but for the loadstate tool, if it fails to complete the script will error out. This could be due to issues with the scanstate step and a corrupted store state in c:\Windows\Temp\JCADMU\store\

```
ERROR: Failed To add new user ' + $JumpCloudUserName + ' to Users group
```
 If the script fails to add the newly created user to the 'users' group on the system it will error out. This could be due to the fact the account doesn't exist or a duplicate or incorrect account name was used etc.

```
ERROR: Jumpcloud agent installation failed
```
 The Jumpcloud agent could error due to the agents prerequisites failing to install (C++ runtimes) or due to the installer being passed an incorrect connect key. If either of these steps fail it will error out.

```
ERROR: Unable to leave domain, Jumpcloud agent will not start until resolved'
```
 The final step is for the system to leave the domain and remove the active directory bind of the system. This utilizes a WMI call to leave the domain from the client side. If this fails it will error out. If the domain bind still exists the workstation will not be able to start the JumpCloud agent.

```
WARNING: Removal Of Temp Files & Folders Failed
``` 
 The script attempts at various stages to clear and recursivly delete files to leave the system in a clean state. If any of the files in use are locked, this step will output a warning. This would indicate the files may still be on the system and should be manually cleared if required.

# Usage Notes and Examples

 Domain joined system 10PRO18091 on domain JCADB2.local with Local Domain Account named JCADB2\bob.lazar and a local account named 10PRO18091\Administrator.


 Example Migration:
 * Convert JCADB2\bob.lazar to 10PRO18091\blazar
 * Unjoin System from JCADB2.local domain
 * Install JumpCloud agent onto system

![image15](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_15.png)

![image16](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_16.png)

 ADMU GUI utility is launched

![image17](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_17.png)

 Both local & Domain user accounts on the system are listed in the listbox at the top of the window, showing the username, the last time it was logged into, if the profile is currently loaded and if domain roaming is configured. System information is also listed on the top right listing the computer name, domain name & if USMT is currenlty present on the system.

  ‘USMT status’ this is true if microsoft ADMT & USMT are found on the system in the required location. If this is false, the required tools and prerequisites will be downloaded and installed in the next steps.

 The 'Jumpcloud Connect Key' is specific to your organization and can be found in the systems, new system, windows aside [here](https://console.jumpcloud.com/#/systems/new).

![image18](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_18.png)

 The ‘Accept EULA’ checkbox allows true or false to be selected. More Info will link to more specifics on the EULA in this document.
 The 'Install JCAgent' checkbox will install the JumpCloud system agent and its prerequisites using the 'JumpCloud Connect Key' to associate with the coresponding organization.
 The 'Leave Domain' checkbox will force the system to unbind the from the domain, this is required for the JCAgent service to start.
 The 'Force Reboot' checkbox will force the system to reboot with a countdown after the 'leave domain' step, a reboot is required for the domain bind to be removed and jcagent to start.

 The 'Local Account Username' is the desired local profile name that should match with the JumpCloud username. This will allow JC to takeover this account and sync the password when bound.
 The 'Local Account Password' is the password used for the newly created account. Once JC has take over the new account the password would stay in sync with the JC user that is bound and matches.

![image19](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_19.png)

 Once a profile is selected and text boxes correctly filled out, the ‘Migrate Profile’ button will become active and can be clicked and the JCADMU.ps1 script will be passed the parameters and ran.


## ADMU Steps - What is the script doing?

 * Checks if USMT is installed on the system and present in C:\adk\Assessment and Deployment Kit\User State Migration Tool\
 * If not present ‘windows ADK’ installer is downloaded. The ‘Accept EULA’ value is checked.
  * True, the USMT will be installed silently with no user interaction required
  * False, the USMT will be installed and require user interaction



### ADK & USMT INSTALLER



![image20](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_20.png)

 If the system already has ADK/USMT installed on the system but is not located in c:\adk the script will error and return:

```powershell
LOG: 'Microsoft Windows ADK  - User State Migration Tool not found in c:\adk. Make sure it is installed correctly and in the required location.'
```

This will need to be corrected before the tool can move forward, so ADK/USMT should be uninstalled and reinstalled in the required location.

 On win7 base systems .net framework is required for the ADK/USMT installer to work. This will be installed in the background if not present.

![image21](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_21.png)

If ‘Accept EULA’ parameter is equal to $false or not present the end user will see:

```powershell
LOG: 'Installing Windows ADK at c:\adk\ please complete GUI prompts & accept EULA within 5mins or it will exit.'
```

![image22](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_22.png)

![image23](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_23.png)

![image24](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_24.png)

![image25](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_25.png)

![image26](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_26.png)

![image27](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_27.png)

 Once this is completed the script will continue to the next steps and output to the log:

```powershell
LOG: 'Microsoft Windows ADK - User State Migration Tool ready to be used.'
```

 If the end user does not complete the above steps in 5mins the script will timeout and exit and have to be run again from the beginning.

 If ‘Accept EULA’ is equal to $true the ADK/USMT will be installed silently to a  default location and simply show in the log it was installed or error accordingly.

```powershell
Log: 'Installing Windows ADK at c:\adk\ silently. By using "$AcceptEULA = "true" you are accepting the "Microsoft Windows ADK EULA". This process could take up to 3mins if .net is required to be installed, it will timeout if it takes longer than 5mins.'
```

 If installed on the system it would show:

![image29](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_29.png)

 Control Panel  Add remove programs Entry

![image30](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_30.png)

 C:\adk installed folders

 Next the ADMU will run the ‘Scanstate’ command from the ‘User State Migration Tool using the passed in parameters.

```powershell
Log: 'Starting scanstate tool on user '$netbiosname + '\' + $DomainUserName'
```

```powershell
Log: 'Scanstate Command: .\scanstate.exe c:\Windows\Temp\JCADMU\store /nocompress /i:miguser.xml /i:migapp.xml /l:c:\Windows\Temp\JCADMU\store\scan.log /progress:c:\Windows\Temp\JCADMU\store\scan_progress.log /o /ue:*\* /ui:' $netbiosname /c'
```

 This step is capturing the current state of the profile and making a copy in c:\windows\temp\JCADMU\


 It is possible that if the profile is very large in size and the available disk space is not enough, the capture could fail. If the ADMU succeeds the captured profile is eventually deleted and space recovered.


Although this adds ‘duplication’ time and space it also provides the ability if there is an issue or error the ability to revert and return the system to the original state.

![image31](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_31.png)

![image32](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_32.png)

 UPDATE TO C:\WINDOWS\TEMP\JCADMU\

```powershell
LOG: 'Scanstate tool completed on user' $netbiosname + '\' + $DomainUserName
```

Next the ‘Loadstate’ command is run against the previously captured profile from above.

```powershell
LOG: 'Starting loadstate tool on user ' $netbiosname + '\' + $DomainUserName + ' converting to ' + $localcomputername + '\' + $JumpCloudUserName)
```

```POWERSHELL
**LOG:** **'Loadstate Command:.\loadstate.exe c:\Windows\Temp\JCADMT\store /i:miguser.xml /i:migapp.xml /nocompress /l:c:\Windows\Temp\JCADMT\store\load.log /progress:c:\Windows\Temp\JCADMT\store\load_progress.log /ue:*\* /ui:' + $netbiosname + '\' + $DomainUserName + '/lac:$TEMPPASSWORD /lae /c /mu:' + $netbiosname + '`\' + $DomainUserName + '`:' + $localcomputername + '\' + $JumpCloudUserName)
```

![image33](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_33.png)

 Once the conversion is completed the newly converted/created user is added to the computers ‘User group’. This allows the new account to show up on the logon screen and be used.

Depending on the passed options/paramaters the script will take the next required action.

If the JumpCloud agent is selected to install. The system is checked to make sure it is not previously installed. The system is also checked for the required ‘Microsoft Visual C++ Redistributables’. If they are not present they are downloaded and installed silently.

 They agent is then installed using the passed in Connect Key. If this key was incorrect the installer would fail and script stopped. They system must also have an internet connection to register the system on JumpCloud during this step.

![image34](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_34.png)

 Currently by design the JumpCloud agent service will not start if the system is bound to a domain and the ‘network category’ is 'DomainAuthenticated'.

![image35](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_35.png)

 If the admin chooses to leave the domain or force reboot the system will then do so. If the agent is able to checkin (Not bound to domain) the system will show up in the JC console.

![image36](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_36.png)

 Once the system checks in, the coresponding Jumpcloud user can be bound to the system. If the username matches the account will be ‘taken over’ and the password will update and sync with jumpcloud.

![image37](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_37.png)

![image38](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_38.png)

 Now the user can login with the same password as JumpCloud once in sync.

![image39](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_39.png)

![image40](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_40.png)

 If the above steps complete successfully, the system will now be bound to JumpCloud and no longer bound to the active directory domain. However the system still has a local copy of the original cached domain profile. This can be seen as ‘Account Unknown’ in the user profiles screen, and the corresponding folder in ```C:\Users\.``` This is useful incase the administrator wants to reverse or rejoin the system and access the previous domain account. For example maybe the conversion process broke a business critical application and they need a way for the user to quickly get back to the previous state.

 In that case the administrator can just rejoin the system to the domain (the Jumpcloud agent will no longer function due to the network configuration changing back to DomainAuthenticated), but the profile will return to how it was.

![image41](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_41.png)

# Definitions

## Windows ADK - Windows Assessment and Deployment Kit

 Windows Assessment and Deployment Kit (ADK) for Windows provides new and improved deployment tools for automating large-scale deployments of Windows.

## USMT - User State Migration Tool

 [Microsoft User State Migration Tool](https://docs.microsoft.com/en-us/windows/deployment/usmt/usmt-overview) is a bundled utility in the Windows ADK.


## ADMU - Active Directory Migration Utility

 Name for the JumpCloud tool that utilizes USMT to convert domain bound systems and accounts to JumpCloud.


## What Is In A Windows Profile

* A registry hive. The registry hive is the file NTuser.dat. The hive is loaded by the system at user logon, and it is mapped to the HKEY_CURRENT_USER registry key. The user's registry hive maintains the user's registry-based preferences and configuration.

 * A set of profile folders stored in the file system. User-profile files are stored in the Profiles directory, on a folder per-user basis. The user-profile folder is a container for applications and other system components to populate with sub-folders, and per-user data such as documents and configuration files. Windows Explorer uses the user-profile folders extensively for such items as the user's Desktop, Start menu and Documents folder.

 * App data folder contains data and settings related to applications. Each windows user/profile has its own broken down into roaming and local. If a system is domain joined certain settings can roam across the domain vs local will only be specific to that user on that system.

## Windows Profile Types

Refernce: [Microsoft Windows User Profiles](https://docs.microsoft.com/en-us/windows/win32/shell/about-user-profiles)

### Local user profile

 * Created upon first logon
 * Stored on local hard disk
 * Changes to profile are stored on computer and user specific

###  Roaming user profile

 * Downloaded upon first logon & requires connection to server
 * Stored and redirects to file share
 * Syncs changes to file share when accessible
 * Merged with local profile to allow offline ‘cached version’
 * Dissociated/unusable when system is unbound from domain


### Microsoft Account based profile

 * Tied to online ‘Live ID’ or ‘Microsoft Account’
 * Syncs account settings via cloud
 * Can utilize onedrive to sync desktop, network profiles, passwords, wifi etc.
 * Tightly coupled with online identity and services.


```diff
- Microsoft accounts are not supported with JumpCloud takeover.
```
### Azure AD Profile Scenarios

Reference: [https://docs.microsoft.com/en-us/azure/active-directory/devices/](https://docs.microsoft.com/en-us/azure/active-directory/devices/)

#### Azure AD Join

 Windows 10 systems can be ‘Azure AD Joined’ to an ‘Azure AD’ instance and shows up under ‘Devices’. Based on the ‘Azure AD’ settings, Users and Admins can associate a system to an ‘Azure AD’ identity allowing login to the system with ‘Azure AD’ credentials. This creates a cached local account that is associated to this account and named ‘AzureAD\Username’.

 This type of account is not supported by JumpCloud takeover when binding users to a system and would create a new ‘local profile’ in this example if JumpCloud username was ‘BradStevens’ it would create ‘10PRO1809-1\BradStevens’ and not sync/link with the ‘AzureAD\BradStevens’ profile.

 The ADMU v1.0.0 tool can not currently convert this account to a ‘local profile’. However this functionality will be added in the future to allow administrators a way to convert ‘Azure Ad Joined’ systems and accounts to migrate to JumpCloud.

```diff
- Azure AD Join is not currently supported with JumpCloud takeover.
```

![image0](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_0.png)


![image1](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_1.png)

#### Azure AD Registration

 A system can also be ‘registered’ to ‘Azure AD’, this is primarily for BYOD devices in which complete control of the system is not required or present. This can be done in windows 10 under Settings, Accounts, Access work or school, Connect. Once signed in the system would be registered, this registration is independent of the profile and simply associated to the underlying system profile. This means that as long as the parent profile is managed by JumpCloud it can co-exist vs the ‘Azure AD Join’ scenario above can not and requires account conversion.

![image2](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_2.png)

![image3](https://github.com/TheJumpCloud/support/blob/master/ADMU/images/img_3.png)

#### Hybrid Azure AD Join

 It is also possible to ‘Hybrid Azure AD Join’ a system. This is when a system is both domain bound and azure ad joined to get the best of both scenarios. It also allows non windows 10 systems to be managed within ‘Azure Ad’ however it is more limited than the other windows 10 options. It does not impact or create any local profiles and JumpCloud can run alongside this scenario. In this scenario be advised that end user education may be required to ensure users follow a password reset workflow that updates both Azure AD and JumpCloud.

```diff
- Hybrid Azure AD Join is not supported with JumpCloud takeover.
```

# Future Development

 * Sign .exe
 * Combine and improve .exe to single file
 * Domain validation
 * Ability to convert multiple accounts
 * Custom USMT xml templates
 * Show local, domain & azure accounts
 * Show if account is in local admin group
 * Ability to change & edit username
 * etc.
