**Configuring a Zero-Touch macOS Onboarding Experience Using the Apple Device Enrollment Program (DEP), Workspace ONE UEM, and JumpCloud**

![Zero-TouchWorkspaceONEUEM.png](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/diagrams/Zero-TouchWorkspaceONEUEM.png)

**Table Of Contents**
- [Prerequisites](#prerequisites)
  - [An Apple Device Enrollment (DEP) Account](#an-apple-device-enrollment-dep-account)
  - [A Workspace ONE UEM tenant configured as an MDM server within Apple Device Enrollment](#a-workspace-one-uem-tenant-configured-as-an-mdm-server-within-apple-device-enrollment)
  - [A JumpCloud tenant configured for LDAP integration with a Workspace ONE UEM tenant](#a-jumpcloud-tenant-configured-for-ldap-integration-with-a-workspace-one-uem-tenant)
  - [Users who you wish to enroll using this zero-touch workflow added to the JumpCloud LDAP directory.](#users-who-you-wish-to-enroll-using-this-zero-touch-workflow-added-to-the-jumpcloud-ldap-directory)
- [Configuration Steps](#configuration-steps)
  - [Step 1 - Configuring Workspace ONE UEM JumpCloud Zero-Touch Components](#step-1---configuring-workspace-one-uem-jumpcloud-zero-touch-components)
  - [Step 2 - Configuring a Workspace ONE UEM JumpCloud Zero-Touch Product](#step-2---configuring-a-workspace-one-uem-jumpcloud-zero-touch-product)
  - [Step 3 - Configuring a Workspace ONE UEM DEP Profile for a JumpCloud Zero-Touch Onboarding Workflow](#step-3---configuring-a-workspace-one-uem-dep-profile-for-a-jumpcloud-zero-touch-onboarding-workflow)
- [Testing the workflow](#testing-the-workflow)

## Prerequisites

### An Apple Device Enrollment (DEP) Account

- The Apple DEP portal was initially launched as a stand alone console but now exists as a nested feature within Apple Business Manager.
-  Need a DEP account? [Click here to sign up.](https://business.apple.com/#enrollment)

### A Workspace ONE UEM tenant configured as an MDM server within Apple Device Enrollment

  - VMware KB article: [Apple DEP Integration](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.4/vmware-airwatch-guides-94/GUID-AW94-C_IntegrateWithDEP.html)
### A JumpCloud tenant configured for LDAP integration with a Workspace ONE UEM tenant

  - JumpCloud KB article: [Configuring Workspace ONE UEM Directory Services to use JumpCloud's LDAP-as-a-Service](https://jumpcloud.desk.com/customer/portal/articles/2971642-configuring-workspace-one-uem-directory-services-to-use-jumpcloud-s-ldap-as-a-service)

### Users who you wish to enroll using this zero-touch workflow added to the JumpCloud LDAP directory.

  - JumpCloud KB article: [Add Users to the LDAP Directory](https://support.jumpcloud.com/customer/en/portal/articles/2439911-using-jumpcloud-s-ldap-as-a-service#addusers)

## Configuration Steps

Workspace ONE UEM components configured in **Step 1** are used to configure a Workspace ONE UEM Product in **Step 2**.

In **Step 3**  a DEP profile is created which will trigger the execution of the Product configured in **Step 2**  and kick off the zero-touch JumpCloud onboarding workflow.

The Product which runs after DEP enrollment executes a script which:

1. Install the JumpCloud agents
2. Waits for the JumpCloud agent to register with the associated JumpCloud tenant.
3. Associates the logged in user to their newly registered system in JumpCloud.
4. Informs the user using "AppleScript" messages that they need to log out and log in to complete onboarding.
5. Informs the user to enter their current password for both the PREVIOUS PASSWORD and PASSWORD fields during login.
6. Logs the user out so they can log back in.
   - The JumpCloud agent completes the necessary steps for account takeover during this login.
   - If using JumpCloud for FileVault management the user will receive their Secure Token during their next JumpCloud login after account takeover.

This script is passed four parameters using the "Run" action within "Files/Actions". These parameters must be entered in a specific order.

Example:

```
. /tmp/jc-zero-touch.sh "Your_JumpCloud_Connect_Key" "Admin_Username" "Admin_Password" "Your_JumpCloud_API_Key"
```

- Want to takeover this admin account during the DEP process and push down a secure password? See how to do this using the zero-touch [SystemGroupAddition](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Additions/SystemGroupAddition.md). This addition can be used to automatically add systems to a JumpCloud system group during enrollment. Any users that are in user groups that are bound to this system group will automatically be bound to these systems and their secure JumpCloud passwords will be pushed down.

Notification messages are displayed to end users to inform them of the onboardings steps occurring on their systems using Apple Scripts called by the Workspace ONE UEM agent.

A log file with time stamps and verbose information is outputted on machines to the /tmp folder by the [jc-zero-touch.sh script](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/files%26actions/jc-zero-touch.sh) named **jc-zero-touch_log.txt**.

This log file can be queried using the below JumpCloud command to see the result of the zero-touch workflow.
 - [Mac - Pull Workspace ONE UEM zero-touch log](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Mac%20Commands/Mac%20-%20Pull%20Workspace%20ONE%20UEM%20zero-touch%20log.md)

### Step 1 - Configuring Workspace ONE UEM JumpCloud Zero-Touch Components

Create the two below components by navigating to "DEVICES" >  "Provisioning" > "Components" in your Workspace ONE UEM administrative console.

1. "Conditions" > "ADD CONDITION" 
   - [JumpCloud zero-touch onboarding prompt](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/conditions/JumpCloud%20zero-touch%20onboarding%20prompt.md) 
2. "Files/Actions" > "ADD FILES/ACTIONS"
    - [JumpCloud zero-touch onboarding workflow](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/files%26actions/JumpCloud%20zero-touch%20onboarding%20workflow.md)


### Step 2 - Configuring a Workspace ONE UEM JumpCloud Zero-Touch Product

Create the below Workspace ONE UEM product by navigating to "DEVICES" >  "Provisioning" > "Product List View" and selecting "ADD PRODUCT".

   - [JumpCloud zero-touch onboarding orchestration](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/products/JumpCloud%20zero-touch%20onboarding%20orchestration.md)

### Step 3 - Configuring a Workspace ONE UEM DEP Profile for a JumpCloud Zero-Touch Onboarding Workflow

Note that for this to work the below prerequisites must be met!
- A Workspace ONE UEM tenant configured as an MDM server within Apple Device Enrollment
  - VMware KB article: [Apple DEP Integration](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/9.4/vmware-airwatch-guides-94/GUID-AW94-C_IntegrateWithDEP.html)
-  A JumpCloud tenant configured for LDAP integration with a Workspace ONE UEM tenant
     - JumpCloud KB article: [Configuring Workspace ONE UEM Directory Services to use JumpCloud's LDAP-as-a-Service](https://jumpcloud.desk.com/customer/portal/articles/2971642-configuring-workspace-one-uem-directory-services-to-use-jumpcloud-s-ldap-as-a-service)

In the Workspace ONE UEM admin console navigate to "Settings" > "Devices & Users" > "General" > "Message Templates"

Click  the "ADD" button and create a new "Message Template" with the following settings: [DEP JumpCloud authentication prompt](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/message%20templates/DEP%20JumpCloud%20authentication%20prompt.md)

Next, navigate to "Settings" > "Devices & Users" > "Apple" > "Apple macOS" > "Intelligent Hub Settings"

Ensure that `Install Hub after Enrollment` is set to **ENABLED**

Finally navigate to "Settings" > "Devices & Users" > "Apple" > "Device Enrollment Program"

Add a profile by clicking the `ADD PROFILE` button with the following settings: [JumpCloud authentication DEP profile](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Workspace%20ONE%20UEM/profiles/JumpCloud%20authentication%20DEP%20profile.md)

After saving the profile set it as the **Default Profile Assigned for Newly Synced Devices** and save.

If you have existing devices registered via DEP navigate to "Devices" > "Lifecycle" > "Enrollment Status", select the checkboxs next to the devices you wish to apply the DEP profile to, select "MORE ACTIONS" > "Assign DEP Profile" and select the newly created profile from the drop down list.

## Testing the workflow

This article from SimpleMDM gives a great tutorial for how to setup a DEP sandbox environment to test out the macOS zero-touch deployment workflow using virtual machines VMWare Fusion, Parallels, or VirtualBox.

[Test Apple DEP with VMware, Parallels, and VirtualBox](https://simplemdm.com/2018/04/03/apple-dep-vmware-parallels-virtualbox/)
