**Configuring a Zero-Touch macOS Onboarding Experience Using the Apple Device Enrollment Program (DEP), jamf Pro, and JumpCloud**

![zeroTouchJamfJumpCloudDiagram](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/diagrams/Zero-TouchJamf.png)

**Table Of Contents**
- [Prerequisites](#Prerequisites)
  - [An Apple Device Enrollment (DEP) Account](#An-Apple-Device-Enrollment-DEP-Account)
  - [A Jamf Pro tenant configured as an MDM server within Apple Device Enrollment](#A-Jamf-Pro-tenant-configured-as-an-MDM-server-within-Apple-Device-Enrollment)
  - [A JumpCloud tenant configured for LDAP integration with a Jamf Pro tenant](#A-JumpCloud-tenant-configured-for-LDAP-integration-with-a-Jamf-Pro-tenant)
  - [Users who you wish to enroll using this zero-touch workflow added to the JumpCloud LDAP directory.](#Users-who-you-wish-to-enroll-using-this-zero-touch-workflow-added-to-the-JumpCloud-LDAP-directory)
- [Configuration Steps](#Configuration-Steps)
  - [Step 1 - Configuring JumpCloud and Jamf Zero-Touch Scripts](#Step-1---Configuring-JumpCloud-and-Jamf-Zero-Touch-Scripts)
  - [Step 2 - Configuring JumpCloud and Jamf Zero-Touch Policies](#Step-2---Configuring-JumpCloud-and-Jamf-Zero-Touch-Policies)
  - [Step 3 - Configure a JAMF Enrollment Kickstart Workflow](#Step-3---Configure-a-JAMF-Enrollment-Kickstart-Workflow)
  - [Step 4 - Configuring a Jamf PreStage Enrollment Profile for a JumpCloud and Jamf Zero-Touch Workflow](#Step-4---Configuring-a-Jamf-PreStage-Enrollment-Profile-for-a-JumpCloud-and-Jamf-Zero-Touch-Workflow)
- [Testing the workflow](#Testing-the-workflow)

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

In **Step 3** a Jamf Enrollment Kickstart workflow is configured to ensure the execution of the zero-touch workflow.

**Step 4** creates a prestage enrollment profile which will trigger the execution of the JumpCloud and Jamf zero-touch workflow and the automatic execution of the policies configured in **Steps 2 and 3**.

A master orchestration policy which runs after DEP enrollment calls six Jamf policies in sequence to:

1. Installs the JumpCloud agent
2. Waits for the JumpCloud agent to register with the associated JumpCloud tenant.
3. Associates the logged in user to their newly registered system in JumpCloud.
4. Informs the user using "User Interaction" messages that they need to log out and log to complete onboarding.
5. Inform the user to enter their current password for both the PREVIOUS PASSWORD and PASSWORD fields during login.
6. Log the user out so they can log back in. The JumpCloud agent completes the necessary steps for account takeover during this login.

A Jamf Enrollment Kickstart workflow is used to to ensure that the master orchestration policy runs on targeted machines post DEP enrollment.

Steps are broken out into individual policies to leverage the "User Interaction" "Start" and "Complete" messages in Jamf and inform users as to what actions are occurring on their systems.

Using individual policies vs a single master policy allows for more granular logging. These logs can come in very handy during troubleshooting events.

The master orchestration policy is called by a launch daemon via the Jamf Enrollment Kickstart workflow.

Shout out to [Yohan460](https://github.com/Yohan460) for creating and documenting a easy to use and reliable [Jamf Enrollment kickstart workflow](https://github.com/Yohan460/JAMF-Enrollment-Kickstart) which is leveraged in this guide.

Reasoning for using a kickstart workflow over the Jamf "Enrollment Complete" tigger can be [found here](https://github.com/Yohan460/JAMF-Enrollment-Kickstart/wiki/10-Reasoning#reasoning).

The six nested polices called by the orchestration script run using the "Custom Event" trigger where the event name is used by the orchestration script to ensure the nested polices run in a specific order.

The seven policies call five scripts. These scripts are the meat and potatoes needed for the "Zero-Touch" JumpCloud workflow.

### Step 1 - Configuring JumpCloud and Jamf Zero-Touch Scripts

Create the below five scripts in Jamf pro by navigating to "Settings" >  "Computer Management" > "Scripts"

1. [jc_install_jcagent](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent.md) 
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

### Step 3 - Configure a JAMF Enrollment Kickstart Workflow

If you are introducing this workflow to a net new Jamf environment which has has no existing machine use the below guide.

  - [New JSS configuration Guide](https://github.com/Yohan460/JAMF-Enrollment-Kickstart/wiki/40-New-JSS-configuration-Guide#new-jss-configuration-guide)

If you are introducing zero-touch to an existing Jamf environment with existing machines use the below guide.

  - [Pre-existing JSS configuration Guide](https://github.com/Yohan460/JAMF-Enrollment-Kickstart/wiki/50-Pre-existing-JSS-configuration-Guide)

See the [Implementation Guide](https://github.com/Yohan460/JAMF-Enrollment-Kickstart/wiki/30-Implementation-Guide#jamf-enrollment-kickstart-implementation-guide) for additional information.

Regardless of which method is used to setup the kickstart workflow the launch daemon calls the policy with a custom trigger specified as "InitialConfig" to invoke the zero-touch workflow.

Ensure that the [Zero-Touch JumpCloud Orchestration Policy](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/policies/Zero-Touch%20JumpCloud%20Orchestration%20Policy.md) is configured with a custom trigger set with an event name of `InitialConfig`.

### Step 4 - Configuring a Jamf PreStage Enrollment Profile for a JumpCloud and Jamf Zero-Touch Workflow

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

Under "Options" > "Account Settings" >  select the type of account that you would like users to be created with. The [jc_account_association](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_account_association.md) script will respect this setting when binding users to their system in JumpCloud.


## Testing the workflow

This article from SimpleMDM gives a great tutorial for how to setup a DEP sandbox environment to test out the macOS zero-touch deployment workflow using virtual machines VMWare Fusion, Parallels, or VirtualBox.

[Test Apple DEP with VMware, Parallels, and VirtualBox](https://simplemdm.com/2018/04/03/apple-dep-vmware-parallels-virtualbox/)
