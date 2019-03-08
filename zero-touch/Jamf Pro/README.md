### Configuring a Zero-Touch macOS Onboarding Experience Using the Apple Device Enrollment Program (DEP), jamf Pro, and JumpCloud


![Zero-TouchJamf.png](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/diagrams/Zero-TouchJamf.png)


## Prerequisites

- An Apple Device Enrollment (DEP) Account
    -The Apple DEP portal was initially launched as a stand alone console but now exists as a nested feature within Apple Business Manager.     
    - Need a DEP account? [Click here to sign up.](https://business.apple.com/#enrollment)
- A Jamf Pro tenant configured as an MDM server within Apple Device Enrollment
  - Jamf KB article: [Integrating with Apple's Device Enrollment (formerly DEP)](https://www.jamf.com/jamf-nation/articles/359/integrating-with-apple-s-device-enrollment-formerly-dep)
- A JumpCloud tenant configured for LDAP integration with a Jamf Pro tenant
  - JumpCloud KB article: [Configuring JAMF Cloud to use JumpCloud's LDAP-as-a-Service](https://support.jumpcloud.com/customer/portal/articles/2589762)

## Configuration Steps

This guide is broken into three steps:

- **Step 1 - Configuring JumpCloud and Jamf Zero-Touch Scripts**
- **Step 2 - Configuring JumpCloud and Jamf Zero-Touch Policies**
- **Step 3 - Configuring a Jamf PreStage Enrollment Profile for a  JumpCloud and Jamf Zero-Touch Workflow**

The scripts configured in **Step 1** are used to configure the policies configured in **Step 2**.

**Step 3** creates a prestage enrollment profile which will trigger the execution of the JumpCloud and Jamf "Zero-Touch" workflow and the automatic execution of the policies configured in **Step 2**.

A master orchestration policy which runs after DEP enrollment calls six Jamf policies in sequence to:

1. Install the JumpCloud agent
2. Wait for the JumpCloud agent to register with the associated JumpCloud tenant.
3. Associate the logged in user to the newly registered system in the associated JumpCloud tenant.
4. Inform the user using "User Interaction" messages that they need to log out and log to complete onboarding.
5. Inform the user to enter their current password for both the PREVIOUS PASSWORD and PASSWORD fields during login.
6. Log the user out so they can log back in. The JumpCloud agent completes the necessary steps for account takeover during this login.

Steps are broken out into individual policies to leverage the "User Interaction" "Start" and "Complete" messages in Jamf and inform users as to what actions are occurring on their systems.

Using individual policies vs a single master policy allows for more granular logging. These logs can come in very handy during troubleshooting events.

The only policy that must be set to trigger on the event of "Enrollment" is the master  orchestration policy.

The six nested polices called by the orchestration script run by the orchestration policy are each set to a "Custom Event" where the event name is used by the orchestration script to ensure the nested polices run in a specific order.

The seven policies call five scripts. These scripts are the meat and potatoes needed for the "Zero-Touch" JumpCloud workflow.

### Step 1 - Configuring JumpCloud and Jamf Zero-Touch Scripts

Create the below five scripts in Jamf pro by navigating to "Settings" >  "Computer Management" > "Scripts"

1. - [jc_install_jcagent](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent.md) for Mac versions < 10.13.x or all versions where JumpCloud will not be managing Filevault users. 
   - [jc_install_jcagent_and_service_account](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_install_jcagent_and_service_account.md) for Mac versions 10.13.x and above, where JumpCloud will manage Filevault users.
     - Ensure that the credentials specified for the Jamf management account configured under "Settings" >  "Global Management" > "User-Initiated Enrollment" > "Platforms" > "macOS" align with the credentials specified for the `SECURETOKEN_ADMIN_USERNAME=''` and `SECURETOKEN_ADMIN_PASSWORD=''` in the configured Jamf script.
     - To update and secure the credentials for this user you can use the JumpCloud agent to takeover this account and update the credentials post DEP enrollment.
2. [jc_five_second_pause](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_five_second_pause.md)
3. [jc_account_association](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_account_association.md)
4. [jc_account_logout](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_account_logout.md)
5. [jc_zero-touch_orchestration](https://github.com/TheJumpCloud/support/blob/master/zero-touch/Jamf%20Pro/scripts/jc_zero-touch_orchestration.md)

### Step 2 - Configuring JumpCloud and Jamf Zero-Touch Policies

Create the below six policies before creating the master orchestration policy.

Note that the name of the policies do not have to be exact but the "Custom Event" names must be created accurately or the master orchestration script will fail.




### Step 3 - Configuring a Jamf PreStage Enrollment Profile for a  JumpCloud and Jamf Zero-Touch Workflow
