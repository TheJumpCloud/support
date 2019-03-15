**Configuring a Zero-Touch macOS Onboarding Experience Using the Apple Device Enrollment Program (DEP), jamf Pro, and JumpCloud**

![zeroTouchJamfJumpCloudDiagram](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/diagrams/Zero-TouchJamf.png)

**Table Of Contents**
- [Prerequisites](#prerequisites)
  - [An Apple Device Enrollment (DEP) Account](#an-apple-device-enrollment-dep-account)
  - [A Jamf Pro tenant configured as an MDM server within Apple Device Enrollment](#a-jamf-pro-tenant-configured-as-an-mdm-server-within-apple-device-enrollment)
  - [A JumpCloud tenant configured for LDAP integration with a Jamf Pro tenant](#a-jumpcloud-tenant-configured-for-ldap-integration-with-a-jamf-pro-tenant)
  - [Users who you wish to enroll using this zero-touch workflow added to the JumpCloud LDAP directory.](#users-who-you-wish-to-enroll-using-this-zero-touch-workflow-added-to-the-jumpcloud-ldap-directory)
- [Configuration Steps](#configuration-steps)
  - [Step 1 - Configuring JumpCloud and Jamf Zero-Touch Scripts](#step-1---configuring-jumpcloud-and-jamf-zero-touch-scripts)
  - [Step 2 - Configuring JumpCloud and Jamf Zero-Touch Policies](#step-2---configuring-jumpcloud-and-jamf-zero-touch-policies)
  - [Step 3 - Configuring a Jamf PreStage Enrollment Profile for a JumpCloud and Jamf Zero-Touch Workflow](#step-3---configuring-a-jamf-prestage-enrollment-profile-for-a-jumpcloud-and-jamf-zero-touch-workflow)
- [Testing the workflow](#testing-the-workflow)

## Prerequisites

### An Apple Device Enrollment (DEP) Account

- The Apple DEP portal was initially launched as a stand alone console but now exists as a nested feature within Apple Business Manager.     
-  Need a DEP account? [Click here to sign up.](https://business.apple.com/#enrollment)
### A Jamf Pro tenant configured as an MDM server within Apple Device Enrollment
  - Jamf KB article: [Integrating with Apple's Device Enrollment (formerly DEP)](https://www.jamf.com/jamf-nation/articles/359/integrating-with-apple-s-device-enrollment-formerly-dep)
### A JumpCloud tenant configured for LDAP integration with a Jamf Pro tenant
  - JumpCloud KB article: [Configuring JAMF Cloud to use JumpCloud's LDAP-as-a-Service](https://support.jumpcloud.com/customer/portal/articles/2589762)

### Users who you wish to enroll using this zero-touch workflow added to the JumpCloud LDAP directory.
  - JumpCloud KB article: [Add Users to the LDAP Directory](https://support.jumpcloud.com/customer/en/portal/articles/2439911-using-jumpcloud-s-ldap-as-a-service#addusers)

## Configuration Steps

The scripts configured in **Step 1** are used to configure the policies configured in **Step 2**.

**Step 3** creates a prestage enrollment profile which will trigger the execution of the JumpCloud and Jamf "Zero-Touch" workflow and the automatic execution of the policies configured in **Step 2**.

A master orchestration policy which runs after DEP enrollment calls six Jamf policies in sequence to:

1. Installs the JumpCloud agent
2. Waits for the JumpCloud agent to register with the associated JumpCloud tenant.
3. Associates the logged in user to their newly registered system in JumpCloud.
4. Informs the user using "User Interaction" messages that they need to log out and log to complete onboarding.
5. Inform the user to enter their current password for both the PREVIOUS PASSWORD and PASSWORD fields during login.
6. Log the user out so they can log back in. The JumpCloud agent completes the necessary steps for account takeover during this login.
   - If using JumpCloud for FileVault management the user will receive their Secure Token during their next system login after account takeover.

Steps are broken out into individual policies to leverage the "User Interaction" "Start" and "Complete" messages in Jamf and inform users as to what actions are occurring on their systems.

Using individual policies vs a single master policy allows for more granular logging. These logs can come in very handy during troubleshooting events.

The only policy that must be set to trigger on the event of "Enrollment" is the master  orchestration policy.

The six nested polices called by the orchestration script run by the orchestration policy are each set to a "Custom Event" where the event name is used by the orchestration script to ensure the nested polices run in a specific order.

The seven policies call five scripts. These scripts are the meat and potatoes needed for the "Zero-Touch" JumpCloud workflow.

### Step 1 - Configuring JumpCloud and Jamf Zero-Touch Scripts

Create the below five scripts in Jamf pro by navigating to "Settings" >  "Computer Management" > "Scripts"

1. Create the script that aligns with your usecase. 
    - [jc_install_jcagent_and_service_account](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent_and_service_account.md) for Mac versions 10.13.x and above, where JumpCloud will manage Filevault users.
       - Ensure that the credentials specified for the Jamf management account configured under "Settings" >  "Global Management" > "User-Initiated Enrollment" > "Platforms" > "macOS" align with the credentials specified for the `SECURETOKEN_ADMIN_USERNAME=''` and `SECURETOKEN_ADMIN_PASSWORD=''` in the configured Jamf script.
       - To update and secure the credentials for this user you can use the JumpCloud agent to takeover this account and update the credentials post DEP enrollment.
   - [jc_install_jcagent](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent.md) for Mac versions < 10.13.x or all versions where JumpCloud will not be managing Filevault users.
2. [jc_five_second_pause](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_five_second_pause.md)
3. [jc_account_association](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_account_association.md)
4. [jc_account_logout](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_account_logout.md)
5. [jc_zero-touch_orchestration](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_zero-touch_orchestration.md)

### Step 2 - Configuring JumpCloud and Jamf Zero-Touch Policies

Create the below six policies before creating the master orchestration policy by navigating to "Computers" > "Policies".

Note that the name of the policies and the "User Interaction" start and complete messages can be modified but the "Custom Event" names must be created accurately or the master orchestration script will fail.

1. [Zero-Touch Step 1 - JumpCloud Agent Install](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20Step%201%20-%20JumpCloud%20Agent%20Install.md)
2. [Zero-Touch Step 2 - JumpCloud Agent Registration](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20Step%202%20-%20JumpCloud%20Agent%20Registration.md)
3. [Zero-Touch Step 3 - User To System Auto Association](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20Step%203%20-%20User%20To%20System%20Auto%20Association.md)
4. [Zero-Touch Step 4 - Inform Users Of Logout](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20Step%204%20-%20Inform%20Users%20Of%20Logout.md)
5. [Zero-Touch Step 5 - Inform User Of Login Process](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20Step%205%20-%20Inform%20User%20Of%20Login%20Process.md)
6. [Zero-Touch Step 6 - Logout User](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20Step%206%20-%20Logout%20User.md)

After creating the above six policies create the mater zero-touch JumpCloud orchestration policy: [Zero-Touch JumpCloud Orchestration Policy](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20JumpCloud%20Orchestration%20Policy.md)


### Step 3 - Configuring a Jamf PreStage Enrollment Profile for a JumpCloud and Jamf Zero-Touch Workflow

Within Jamf Pro navigate to "Computers" > "PreStage Enrollments".

Under "Options" > "General" ensure that the profile is mapped to the correct "DEVICE ENROLLMENT PROGRAM INSTANCE" and that the checkbox for "Automatically assign new devices " is selected.

Select the checkbox fo "Require Authentication" which will require users to log in with their JumpCloud user name and password during enrollment.

Note that for this to work the below prerequisites must be met!
  - [A JumpCloud tenant configured for LDAP integration with a Jamf Pro tenant](#a-jumpcloud-tenant-configured-for-ldap-integration-with-a-jamf-pro-tenant)
  - [Users who you wish to enroll using this zero-touch workflow added to the JumpCloud LDAP directory.](#users-who-you-wish-to-enroll-using-this-zero-touch-workflow-added-to-the-jumpcloud-ldap-directory)

Specify an authentication message that will be useful for end users.

Example message:

```
Log in with your JumpCloud username and password. DO NOT change the  "Account name" in the next screen.
```

Under "Options" > "Account Settings" >  select the type of account that you would like users to be created with. The [jc_account_association](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_account_association.md)script will respect this setting when binding users to their system in JumpCloud.

If you are using the [jc_install_jcagent_and_service_account](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent_and_service_account.md) JumpCloud agent install script ensure the "Management Account" under "Account Settings" aligns with the credentials entered for the values provided for the `SECURETOKEN_ADMIN_USERNAME=''` and
`SECURETOKEN_ADMIN_PASSWORD=''` variables in this script.

## Testing the workflow

This article from SimpleMDM gives a great tuturial for how to setup a DEP sandbox environment to test out the macOS zero-touch deployment workflow using virtual machines VMWare Fusion, Parallels, or VirtualBox.

[Test Apple DEP with VMware, Parallels, and VirtualBox](https://simplemdm.com/2018/04/03/apple-dep-vmware-parallels-virtualbox/)
