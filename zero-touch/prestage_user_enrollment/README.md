**Configuring a Zero-Touch macOS onboarding experience for PreStaging user and system enrollment using DEPNotify, munkiPKG, JumpCloud, and your MDM of choice.**

Leveraging this workflow allows admins to install the JumpCloud agent siently and ensures that the JumpCloud Service Account is installed using DEP and an MDM.

The JumpCloud Service Account is required to manage users on FileVault protected macs. 

[Learn more about the JumpCloud Service Account here.](https://support.jumpcloud.com/customer/portal/articles/2944374)

*This example uses SimpleMDM*

![configuration_steps](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/diagrams/configuration_steps.png?raw=true)

**Table Of Contents**
- [Prerequisites](#prerequisites)
  - [An Apple Device Enrollment (DEP) Account](#an-apple-device-enrollment-dep-account)
  - [An MDM server integrated with Apple DEP](#an-mdm-server-integrated-with-apple-dep)
  - [An Apple Developer Account](#an-apple-developer-account)
  - [munkipkg or an alternative macOS PKG building tool or application](#munkipkg-or-an-alternative-macos-pkg-building-tool-or-application)
  - [Users who you wish to enroll using this zero-touch workflow added to the JumpCloud directory.](#users-who-you-wish-to-enroll-using-this-zero-touch-workflow-added-to-the-jumpcloud-directory)
- [Zero-Touch Enrollment Workflow Diagram](#zero-touch-enrollment-workflow-diagram)
- [Component Definitions](#component-definitions)
- [Configuration Steps](#configuration-steps)
  - [Step 1 - Download the JumpCloud Bootstrap template script](#step-1---download-the-jumpcloud-bootstrap-template-script)
  - [Step 2 - Configuring the JumpCloud Tenant For DEP Zero-Touch](#step-2---configuring-the-jumpcloud-tenant-for-dep-zero-touch)
  - [Step 3 - Populating the Bootstrap template script variables](#step-3---populating-the-bootstrap-template-script-variables)
    - [Variable Definitions](#variable-definitions)
  - [Step 4 - Selecting a User Configuration Module](#step-4---selecting-a-user-configuration-module)
    - [Pending User Configuration Modules](#pending-user-configuration-modules)
    - [Pending or Active User Configuration Modules](#pending-or-active-user-configuration-modules)
  - [Step 5 - Populating the Bootstrap template script with a User Configuration Module](#step-5---populating-the-bootstrap-template-script-with-a-user-configuration-module)
  - [Step 6 - Creaking a PKG from the Bootstrap template script using munkiPKG](#step-6---creaking-a-pkg-from-the-bootstrap-template-script-using-munkipkg)
  - [Step 7 - Configuring MDM PreStage Settings](#step-7---configuring-mdm-prestage-settings)
  - [Step 8 - Configuring the PKG for MDM deployment](#step-8---configuring-the-pkg-for-mdm-deployment)
  - [Step 9 - Creating a Privacy Preference Policy](#step-9---creating-a-privacy-preference-policy)
- [Testing the workflow](#testing-the-workflow)

## Prerequisites

### An Apple Device Enrollment (DEP) Account

- The Apple DEP portal was initially launched as a stand alone console but now exists as a nested feature within Apple Business Manager
  -  Need a DEP account? [Click here to sign up.](https://business.apple.com/#enrollment)

### An MDM server integrated with Apple DEP

To implement this zero-touch workflow a MDM server must be configured to deploy the MDM profiles and PKG payload to DEP enrolled machines.

  - Jamf KB article: [Integrating with Apple's Device Enrollment (formerly DEP)](https://www.jamf.com/jamf-nation/articles/359/integrating-with-apple-s-device-enrollment-formerly-dep)
  - Simple MDM KB article: [How to Enroll in MDM with Apple DEP](https://simplemdm.com/mdm-apple-dep-how-to/)

### An Apple Developer Account

An Apple Developer Account is required to sign the macOS package created in this tutorial.

- Need a Apple Developer Account? [Click here to sign up.](https://developer.apple.com/programs/)

### munkipkg or an alternative macOS PKG building tool or application

The JumpCloud Bootstrap configuration script that is configured in this tutorial must be packaged and converted to a signed PKG.

- munkiPKG is an easy to use command line utility that is used in this tutorial to convert the bootstrap configuration script to a PKG.
  - Need to download munkipkg? [Click here](https://github.com/munki/munki-pkg#munkipkg)  


### Users who you wish to enroll using this zero-touch workflow added to the JumpCloud directory.

  - JumpCloud KB article: [Getting Started: Users](https://jumpcloud.desk.com/customer/en/portal/articles/2778996-getting-started-users)

## Zero-Touch Enrollment Workflow Diagram

![zero_touch_enrollment_workflow](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/diagrams/zero_touch_enrollment_workflow.png?raw=true)

## Component Definitions

**DEP:** The Apple Device Enrollment Program.

**MDM Server:** A Mobile Device Management server registered with Apple DEP.

**jumpcloud_bootstrap_template.sh:** The template .sh file that contains the logic for the zero-touch workflow. This file has variables that must be populated with org specific settings and has fields to populate with a user configuration module. This .sh file is converted to a PKG and is the payload which is run which drives the zero-touch workflow.

**user_configuration_modules:** The folder that contains the user configuration modules. The user configuration modules provide optionality for how PreStaged users locate and activate their JumpCloud accounts during DEP onboarding.

**Enrollment User:** The admin account pushed down via the MDM. Logging into this account is the first step in kicking off the zero-touch workflow. This account gets taken over and then inactivated on the system in the zero-touch workflow. Logging in with an Enrollment User is required to install the JumpCloud service account which manages SecureTokens and FileVault enabled users.

**JumpCloud Service Account:** The JumpCloud Service Account is created using the **Enrollment User** credentials. The JumpCloud Service Account is required to manage SecureTokens and FileVault enabled users. This users is created as a hidden user on macOS machines.

**JumpCloud Decryption User:** The UID of this account is used to encrypt the JumpCloud API key in tandem with the JumpCloud Org ID using the "EncryptKey()" function. This account gets pushed down to the account during zero-touch enrollment and the UID is used to decrypt the "$ENCRYPTED_KEY" variable.

**JumpCloud System Context API:** A method for authenticating to the JumpCloud API without an API key. A system can modify only it's direct associations using this authentication method.

**JumpCloud DEP Enrollment User Group:** A JumpCloud user group which contains two members, the **Enrollment User** account and the **JumpCloud Decryption User** account. This user group is bound to the **JumpCloud DEP Enrollment System Group**.

**JumpCloud DEP Enrollment System Group:** The JumpCloud system group that a system adds itself to using System Context API authentication. When a system adds itself to the DEP Enrollment System group the **Enrollment User** account is taken over and converted to a standard user from an admin user and the **JumpCloud Decryption User** is bound to the machine. The zero-touch workflow removes the system from this group after DEP enrollment which deactivates both the **Enrollment User** and the **JumpCloud Decryption User** accounts.

**JumpCloud DEP POST Enrollment User Group:** A JumpCloud user group which contains one member the **Default Admin** account. This user group is bound to the **JumpCloud DEP POST Enrollment System Group**.

**JumpCloud DEP POST Enrollment System Group:** The JumpCloud  system group that a system adds itself to add the end of DEP enrollment. When a system adds itself to the DEP POST Enrollment System Group the **Default Admin** account is bound to the system.

**JumpCloud Bootstrap PKG:** The product archive package created from a configured jumpcloud_bootstrap_template.sh file using munkipkg or an alternative macOS PKG building tool.

**DEPNotify:** The application that drives the UI of the zero-touch workflow.

**JumpCloud Agent:** The JumpCloud Agent gets installed after the Enrollment User signs in. This agent is what manages local accounts on macOS machines and creates the JumpCloud Service Account.

**JumpCloud API:** The JumpCloud API is used in the **jumpcloud_bootstrap_template.sh** to drive the zero-touch workflow.

**Password Configuration Window:** A osascript that presents users with an input box to set a secure password with regex validation. A Privacy Preferences MDM Profile must be created to suppress the security pop-up.

**PreStaged JumpCloud Users:** Pending JumpCloud users configured with access to JumpCloud resources who activate their accounts using the zero-touch workflow.

## Configuration Steps

![configuration_steps](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/diagrams/configuration_steps.png?raw=true)

### Step 1 - Download the JumpCloud Bootstrap template script

Download the [jumpcloud_bootstrap_template.sh file](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/jumpcloud_bootstrap_template.sh) and open this file in your code editor of choice.

The JumpCloud Solution Architecture team loves to work with SH files in the code editor Visual Studio Code.

  - Want to try VS Code? [Click here to download](https://code.visualstudio.com/) 
### Step 2 - Configuring the JumpCloud Tenant For DEP Zero-Touch

**Configure JumpCloud Settings**

![Org Settings](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/UID_GID_Mgmt.png?raw=true)

To configure a JumpCloud tenant for zero-touch DEP integration you will first need to enable the setting for `Enable UID/GID management for users` in the JumpCloud "Settings"->"General" pane.

Enabling this setting is required to properly configure the **Decryption User**.

The UID if this user is used to create the the **ENCRYPTED_KEY** variable.

**Configure JumpCloud Users**

- Enrollment User

The enrollment user account will have the same displayName and username as the first account pushed down to your system via your MDM.

Create an enrollment user account and set the password for this account to be exactly the same as the settings configured in [Step 7](#Step-7---Configuring-MDM-PreStage-Settings)

Example:

![Welcome User](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/Welcome_User.png?raw=true)

This account is taken over during DEP enrollment and then disabled on the machine after DEP enrollment completes.

- Decryption User

The UID of the decryption user account will be used to populate the "ENCRYPTED_KEY=''" variable in [Step 3](#Step-3---Populating-the-Bootstrap-template-script-variables). Create a JumpCloud account and set a secure password for this account.

Under this users "User Security Settings and Permissions" check the box for "Enable as Admin/Sudo on all system associations" and "Enforce UID/GID consistency for all systems" and enter in a numerical "Unix UID" and "Unix GID" value over 7 characters.

Take note of the value populated for the "Unix UID" as this will be used in [Step 3](#Step-3---Populating-the-Bootstrap-template-script-variables) to create the "ENCRYPTED_KEY=''" variable.

Example:

![Decryption User](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/IT_Service_UID.png?raw=true)

- Default Admin (Optional)

This account will be used in this workflow to bind a default admin account to each DEP enrolled system when the system is added to the DEP Post Enrollment System Group. If you already have a default admin account in your JumpCloud tenant you can simply use this account.
 
For this user ensure that the box "Enable as Admin/Sudo on all system associations" under this users "User Security Settings and Permissions" is checked.

Example:

![Default Admin](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/Default_Admin.png?raw=true)

**Configure JumpCloud Groups**

- DEP Enrollment User Group

Create a JumpCloud User Group named "DEP Enrollment User Group" under the "Users" settings for this group add two users: the **Enrollment User** and the **Decryption User**.

Example: 

![DEP E User Group](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/DEP_Enrollment_User_Group.png?raw=true)

- DEP Enrollment System Group

Create a JumpCloud System Group named "DEP Enrollment System Group" under the "User Groups" settings for this group add the group "DEP Enrollment User Group"

Example:

![Dep E System Group](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/DEP_Enrollment_System_Group_ID.png?raw=true)

After creating the group take note of the "DEP  Enrollment System Group" JumpCloud ID value.

To find the JumpCloud ID value for a JumpCloud system group navigate to the "GROUPS" section of the JumpCloud admin portal and select the system group to bring up the system group details. Within the URL of the selected command the systemGroupID will be the 24 character string between 'system/' and '/details'. The JumpCloud PowerShell command Get-JCGroup can also be used to find the systemGroupID. The systemGroupID is the 'id' value which will be displayed for each JumpCloud group when Get-JCGroup is called.

Example:

![Dep E System Group ID](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/DEP_Enrollment_System_Group_ID.png?raw=true)


- DEP Post Enrollment User Group

Create a JumpCloud User Group named "DEP Post Enrollment User Group" under the "Users" settings for this group add one user: **Default Admin**.

![DEP Post Enrollment User Group](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/DEP_Post_Enroll_User_Group.png?raw=true)

- DEP Post Enrollment System Group

Create a JumpCloud System Group named "DEP Post Enrollment System Group" under the "User Groups" settings for this group add the group "DEP Post Enrollment User Group"

![DEP Post Enrollment System Group](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/DEP_Post_Enroll_System_Group.png?raw=true)

After creating the group take note of the "DEP Post Enrollment System Group" JumpCloud ID value.

To find the JumpCloud ID value for a JumpCloud system group navigate to the "GROUPS" section of the JumpCloud admin portal and select the system group to bring up the system group details. Within the URL of the selected command the systemGroupID will be the 24 character string between 'system/' and '/details'. The JumpCloud PowerShell command Get-JCGroup can also be used to find the systemGroupID. The systemGroupID is the 'id' value which will be displayed for each JumpCloud group when Get-JCGroup is called.

Example:

![DEP Post Enrollment System Group ID](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/DEP_Post_Enroll_System_Group_ID.png?raw=true)

### Step 3 - Populating the Bootstrap template script variables

Within the "General Settings" near the top of the  `jumpcloud_bootstrap_template.sh` file you will find the input section for org specific variables.

Example:
```SH
################################################################################
# General Settings - POPULATE THE BELOW VARIABLES                              #
################################################################################

### Bind user as admin or standard user ###
# Admin user: admin='true'
# Standard user: admin='false'
admin='false'

### Minimum password length ###
minlength=8

### JumpCloud Connect Key ###
YOUR_CONNECT_KEY=''

### Encrypted API Key ###
## Use below SCRIPT FUNCTION: EncryptKey to encrypt key
ENCRYPTED_KEY=''

### Username of the JumpCloud user whose UID is used for decryption ###
DECRYPT_USER=''

### JumpCloud System Group ID For DEP Enrollment ###
DEP_ENROLLMENT_GROUP_ID=''

### JumpCloud System Group ID For DEP POST Enrollment ###
DEP_POST_ENROLLMENT_GROUP_ID=''

### DEPNotify Welcome Window Title ###
WELCOME_TITLE=""

### DEPNotify Welcome Window Text use //n for line breaks ###
WELCOME_TEXT=''

### Boolean to delete the enrollment user set through MDM ###
DELETE_ENROLLMENT_USERS=true

### Username of the enrollment user account configured in the MDM.
### This account will be deleted if the above boolean is set to true.
ENROLLMENT_USER=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END General Settings                                                         ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

#### Variable Definitions

- `admin='false'`

This variable defines how users will be created through the zero-touch workflow. There are two possible values `admin='false'` (default) creates the user as a standard user. `admin='true'` creates users as admin users.

- `minlength=8`

This variable defines the minimum password length that a user can set during enrollment. Set this to match your JumpCloud password complexity settings.

- `YOUR_CONNECT_KEY=''`

Enter the connect key from your JumpCloud tenant. This can be found within the "Systems" tab by clicking the green plus and selecting Windows or Mac.

- `ENCRYPTED_KEY=''`

The `EncryptKey()` function must be used to create the **ENCRYPTED_KEY** variable.

```SH
function EncryptKey() {
    # Usage: EncryptKey "API_KEY" "DECRYPT_USER_UID" "ORG_ID"
    local ENCRYPTION_KEY=${2}${3}
    local ENCRYPTED_KEY=$(echo "${1}" | openssl enc -e -base64 -A -aes-128-ctr -nopad -nosalt -k ${ENCRYPTION_KEY})
    echo "Encrypted key: ${ENCRYPTED_KEY}"
}
```

Three parameters are used to create this encrypted string.

1. JumpCloud API key

Need help finding your JumpCloud API key? See KB:[Obtaining Your API Key](https://support.jumpcloud.com/customer/en/portal/articles/2429680-jumpcloud-apis#configuration)

2. UID of **Decryption User** created in [Step 2](#step-2---configuring-the-jumpcloud-tenant-for-dep-zero-touch)

To find the UID of the **Decryption User** expand the "User Security Settings and Permissions" and find this value under "Unix UID"

![UID Image](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/Decryption_User_UID_Circled.png?raw=true)

3. JumpCloud Organization ID

The JumpCloud Organization ID can be found under the "Settings"-> "General" pane in the JumpCloud admin console.

![Organization ID Image](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/Org_ID_Circled.png?raw=true)

Use the `EncryptKey()` function to generate the **ENCRYPTED_KEY** variable using these three parameters.

Usage: EncryptKey "API_KEY" "DECRYPT_USER_UID" "ORG_ID"

Example:

```SH
function EncryptKey() {
    # Usage: EncryptKey "API_KEY" "DECRYPT_USER_UID" "ORG_ID"
    local ENCRYPTION_KEY=${2}${3}
    local ENCRYPTED_KEY=$(echo "${1}" | openssl enc -e -base64 -A -aes-128-ctr -nopad -nosalt -k ${ENCRYPTION_KEY})
    echo "Encrypted key: ${ENCRYPTED_KEY}"
}

EncryptKey c57c341a4a38f132019770f1689bbe7530bdfef3 8675309 59664bf31254e1cc14e82117

Encrypted key: 43H/pQGRJ5Uut5R3wagbPSS/I2cATai4dUCnqsimkFQ6OvqnFerp9l8=
```

The `DecryptKey()` function can be used to validate that the encryption worked correctly.

Usage: DecryptKey "ENCRYPTED_KEY" "DECRYPT_USER_UID" "ORG_ID"

 Example:

```SH
function DecryptKey() {
    # Usage: DecryptKey "ENCRYPTED_KEY" "DECRYPT_USER_UID" "ORG_ID"
    echo "${1}" | openssl enc -d -base64 -aes-128-ctr -nopad -A -nosalt -k "${2}${3}"
}

DecryptKey 43H/pQGRJ5Uut5R3wagbPSS/I2cATai4dUCnqsimkFQ6OvqnFerp9l8= 8675309 59664bf31254e1cc14e82117

c57c341a4a38f132019770f1689bbe7530bdfef3
```

- `DECRYPT_USER=''`

Enter the username (case sensitive) of the **Decryption User** created in [Step 2](#step-2---configuring-the-jumpcloud-tenant-for-dep-zero-touch)

- `DEP_ENROLLMENT_GROUP_ID=''`

Enter the JumpCloud ID value of the **DEP Enrollment System Group**

- `DEP_POST_ENROLLMENT_GROUP_ID=''`

Enter the JumpCloud ID value of the **DEP Post Enrollment System Group**

- `WELCOME_TITLE=""`

Enter a welcome title that will launch when DEPNotify launches.

- `WELCOME_TEXT=''`

Enter welcome text that will load when DEPNotify launches.

Use \\n for line breaks.

- `DELETE_ENROLLMENT_USERS=true`

A Boolean variable that by default is set to true. This variable controls if the `DECRYPT_USER` and `ENROLLMENT_USER` accounts are deleted from the system at the end of the flow. It is recommend to leave this variable set to True to ensure that these users are removed.


- `ENROLLMENT_USER=""`

The username of the MDM enrollment user pushed down to the machine.

Example of populated variables:

```SH
################################################################################
# General Settings - POPULATE THE BELOW VARIABLES                              #
################################################################################

### Bind user as admin or standard user ###
# Admin user: admin='true'
# Standard user: admin='false'
admin='false'

### Minimum password length ###
minlength=8

### JumpCloud Connect Key ###
YOUR_CONNECT_KEY='b5a0d92cfe32096feb67e30528a5facd72fb4529'

### Encrypted API Key ###
## Use below SCRIPT FUNCTION: EncryptKey to encrypt key 503 UID used
ENCRYPTED_KEY='43H/pQGRJ5Uut5R3wagbPSS/I2cATai4dUCnqsimkFQ6OvqnFerp9l8='

### Username of the JumpCloud user whose UID is used for decryption ###
DECRYPT_USER='it.service'

### JumpCloud System Group ID For DEP Enrollment ###
DEP_ENROLLMENT_GROUP_ID='5d0a48cc1f247527b2f92266'

### JumpCloud System Group ID For DEP POST Enrollment ###
DEP_POST_ENROLLMENT_GROUP_ID='5d0a48fz45886d39c9dba975'

### DEPNotify Welcome Window Title ###
WELCOME_TITLE="Welcome to Azzipa.\\n Where we make backwards pizzas."

### DEPNotify Welcome Window Text use \\n for line breaks ###
WELCOME_TEXT='Sit back and relax as your computer configures itself for you. \\n\\n After configuration settings download you will be asked to activate your account and set a password!'

### Boolean to delete the enrollment user set through MDM ###
DELETE_ENROLLMENT_USERS=true

### Username of the enrollment user account configured in the MDM.
### This account will be deleted if the above boolean is set to true.
ENROLLMENT_USER="Welcome"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END General Settings                                                         ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

### Step 4 - Selecting a User Configuration Module

Within the  `prestage_user_enrollment` folder in the zero-touch support GitHub repo there is a folder named `user_configuration_modules` in this folder live the user configuration modules that give optionality for how users will activate their JumpCloud accounts through the DEPNotify registration window.

#### Pending User Configuration Modules

The below workflows can be used to activate **Pending** JumpCloud users. Pending users are users who have not set a password.

![pending_user_company_email](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/pending_company_email.png?raw=true)

- [pending_user_company_email](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/user_configuration_modules/pending_user_company_email.sh)

The JumpCloud user "email" field is used to lookup and locate a user by company email.

![pending_user_personal_email](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/personal_email.png?raw=true)

- [pending_user_personal_email](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/user_configuration_modules/pending_user_personal_email.sh)

There is no defined field for "personal email" in JumpCloud so the "description" field is used to lookup and locate a user by personal email. The "Description" field for users must be populated with a value for this workflow to succeed.

#### Pending or Active User Configuration Modules

The below workflows can be used to activate **Pending** or **Active** JumpCloud users. Pending users are users who have not set a password. Active users are users who have already set a pass code. A "secret" is required for these workflows. This is a value that is populated for the JumpCloud "employeeIdentifier" field and provided to employees prior to zero-touch DEP enrollment. The secret secures the enrollment and provides an additional factor of verification to activate or update the JumpCloud account.

![pending_or_active_user_company_email_and_secret](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/company_secret.png?raw=true)

- [pending_or_active_user_company_email_and_secret](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/user_configuration_modules/pending_or_active_user_company_email_and_secret.sh)

The input fields "Company Email" is used to query the "EMAIL" attribute for existing JumpCloud users. The input field "Secret" is used to query the "employeeIdentifier" attribute. The "employeeIdentifier" field for users must be populated with a value for this workflow to succeed. The "employeeIdentifier" attribute is required to be unique per user.

![pending_or_active_user_personal_email_and_secret](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/personal_email_secret.png?raw=true)

- [pending_or_active_user_personal_email_and_secret](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/user_configuration_modules/pending_or_active_user_personal_email_and_secret.sh)

The input fields "Personal Email" is used to query the "Description" attribute for existing JumpCloud users. The input field "Secret" is used to query the "employeeIdentifier" attribute. The "employeeIdentifier" field for users must be populated with a value for this workflow to succeed. The "employeeIdentifier" attribute is required to be unique per user.

![pending_or_active_user_last_name_and_secret](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/lastname_secret.png?raw=true)

- [pending_or_active_user_last_name_and_secret](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/user_configuration_modules/pending_or_active_user_last_name_and_secret.sh)


The input fields "Last Name" is used to query the "lastname" attribute for existing JumpCloud users. The input field "Secret" is used to query the "employeeIdentifier" attribute. The "employeeIdentifier" field for users must be populated with a value for this workflow to succeed. The "employeeIdentifier" attribute is required to be unique per user.

### Step 5 - Populating the Bootstrap template script with a User Configuration Module

After selecting a User Configuration Module you will need to insert two code blocks from the module into the  `jumpcloud_bootstrap_template.sh` file.

To find these locations search for the text: `INSERT-CONFIGURATION`

Copy in the entire contents of the  **DEPNotify PLIST Settings** code block from the selected module to the `jumpcloud_bootstrap_template.sh` file where it reads `#<--INSERT-CONFIGURATION for "DEPNotify PLIST Settings" below this line---------`.

```sh
################################################################################
# DEPNotify PLIST Settings - INSERT-CONFIGURATION                              #
################################################################################
#<--INSERT-CONFIGURATION for "DEPNotify PLIST Settings" below this line---------

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END DEPNotify PLIST Settings                                                 ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

Copy in the entire contents of the  **User Configuration Settings** code block from the selected module to the `jumpcloud_bootstrap_template.sh` file where it reads `#<--INSERT-CONFIGURATION for "User Configuration Settings" below this line-------`.

```sh
################################################################################
# User Configuration Settings - INSERT-CONFIGURATION                           #
################################################################################
#<--INSERT-CONFIGURATION for "User Configuration Settings" below this line-------

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# END User Configuration Settings                                              ~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

### Step 6 - Creaking a PKG from the Bootstrap template script using munkiPKG

- Creating a project using munkiPKG

Use munkipkg to create a new project folder.

Example:

```SH
munkipkg --create jumpcloud_bootstrap
```

Need help? See:[Creating a new project](https://github.com/munki/munki-pkg#creating-a-new-project)

- Move the `jumpcloud_bootstrap_template.sh` to the project folder

![payload move](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/payload_folder.png?raw=true)

- Update the build-info file and add signing information

Required Updates to build-info:

"distribution_style": true
"identifier": "com.github.munki.pkg.jumpcloud_bootstrap_template"
"install_location": "/private/tmp"
"preserve_xattr": true,
"identifier": "com.github.munki.pkg.jumpcloud_bootstrap_template"
Example build-info.json:

```JSON
{
    "postinstall_action": "none",
    "suppress_bundle_relocation": true,
    "name": "jumpcloud_bootstrap_template.pkg",
    "distribution_style": true,
    "preserve_xattr": true,
    "install_location": "/private/tmp",
    "version": "1.0",
    "ownership": "recommended",
    "identifier": "com.github.munki.pkg.jumpcloud_bootstrap_template",
    "signing_info": {
        "identity": "Developer ID Installer: {{ REDACTED Insert Developer ID}}"
    }
}
```

- Create a postinstall script file in the `scripts` folder

![postinstall script](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/postinstall_script.png?raw=true)

In the postinstall script add in the following payload

```sh
#!/bin/sh

# Enter the ENROLLMENT_USER within the '' of ENROLLMENT_USER=''
ENROLLMENT_USER=''

# Enter the ENROLLMENT_USER_PASSWORD within the '' of ENROLLMENT_USER_PASSWORD='' with the credentials of the admin with a secure token
ENROLLMENT_USER_PASSWORD=''

cat <<-EOF >/var/run/JumpCloud-SecureToken-Creds.txt
$ENROLLMENT_USER;$ENROLLMENT_USER_PASSWORD
EOF

sh /private/tmp/jumpcloud_bootstrap_template.sh

```

Populate the `ENROLLMENT_USER=''` and the `ENROLLMENT_USER_PASSWORD=''` with the values specified for this account in [Step 2](#step-2---configuring-the-jumpcloud-tenant-for-dep-zero-touch)

Example:

```sh
#!/bin/sh

# Enter the ENROLLMENT_USER within the '' of ENROLLMENT_USER=''
ENROLLMENT_USER='Welcome'

# Enter the ENROLLMENT_USER_PASSWORD within the '' of ENROLLMENT_USER_PASSWORD='' with the credentials of the admin with a secure token
ENROLLMENT_USER_PASSWORD='Welcome1!'

cat <<-EOF >/var/run/JumpCloud-SecureToken-Creds.txt
$ENROLLMENT_USER;$ENROLLMENT_USER_PASSWORD
EOF

sh /private/tmp/jumpcloud_bootstrap_template.sh

```

The presences of the `JumpCloud-SecureToken-Creds.txt` file is require to install the JumpCloud agent with the JumpCloud Service Account. The JumpCloud Service Account is mandatory to manage Secure Tokens and Filevault enabled users. The `JumpCloud-SecureToken-Creds.txt` is deleted by the agent install process and removed from the system.

- Creating the PKG

Use munkipkg to create the PKG and sign it with your Apple Developer Certificate.

Need help? See [Package signing](https://github.com/munki/munki-pkg#package-signing) and [Building a package](https://github.com/munki/munki-pkg#building-a-package)

### Step 7 - Configuring MDM PreStage Settings

- User Settings

In the MDM DEP Apple PreStage settings configure the MDM to not prompt the user to create an account by setting the value of "Prompt user to create" to **"No Account"**.

- Enrollment User

In the MDM DEP Apple PreStage settings enable the MDM to "Automatically create an administrator account" and specify the `Short name` of the username and the `Full name` of the first and last name of the **Enrollment User** configured in [Step 2](#step-2---configuring-the-jumpcloud-tenant-for-dep-zero-touch). Ensure that the password set for this account is also the same password specified for the **Enrollment User** account configured in [Step 2](#step-2---configuring-the-jumpcloud-tenant-for-dep-zero-touch)

Example: 

![Simple Settings](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/mdm_enrollment_user.png?raw=true)

### Step 8 - Configuring the PKG for MDM deployment

- Uploading PKG

Upload the PKG to the MDM

![PKG Upload](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/simple_mdm_pkg1.png?raw=true)

- PKG Settings

Ensure the PKG is configured for "Device Level Installation". By setting the PKG to "Device Level Installation" the PKG will install as soon as a device enrolls into MDM.

![Device Level](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/simple_device_level_install.png?raw=true)

- PKG Scoping

Scope the PKG to auto deploy to the machines you wish to configure for zero-touch configuration.

### Step 9 - Creating a Privacy Preference Policy

Create the below "Privacy Preference" profile. This will allow the osascript to run which prompts users to input a secure password.

**Identifier type:** path

**Identifier:**/System/Library/PrivateFrameworks/CommerceKit.framework/Versions/A/Resources/storedownloadd

**Code requirement:** identifier "com.apple.storedownloadd" and anchor apple

**Static code validation:** No

Apple Event Targets

**Identifier Type:** bundle ID

**Identifier:** com.apple.systemevents

**Code Requirement:** identifier "com.apple.systemevents" and anchor apple

**Access:** Allow

![Privacy P](https://github.com/TheJumpCloud/support/blob/master/zero-touch/prestage_user_enrollment/images/privacy_preference.png?raw=true)

## Testing the workflow

This article from SimpleMDM gives a great tutorial for how to setup a DEP sandbox environment to test out the macOS zero-touch deployment workflow using virtual machines VMWare Fusion, Parallels, or VirtualBox.

[Test Apple DEP with VMware, Parallels, and VirtualBox](https://simplemdm.com/2018/04/03/apple-dep-vmware-parallels-virtualbox/)
