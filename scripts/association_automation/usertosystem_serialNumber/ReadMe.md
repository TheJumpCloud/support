
- [User To System Association via System Serial Number](#user-to-system-association-via-system-serial-number)
  - [Prerequisites](#prerequisites)
    - [The JumpCloud PowerShell Module](#the-jumpcloud-powershell-module)
  - [Configuration](#configuration)
    - [usertosystem_serialNumber.ps1](#usertosystemserialnumberps1)
    - [usertosystem_serialNumber.csv](#usertosystemserialnumbercsv)
  - [Usage](#usage)
  - [Troubleshooting](#troubleshooting)

# User To System Association via System Serial Number

Admins that wish to create automation scenarios to for associating JumpCloud users to JumpCloud managed systems can use the "usertosystem_serialNumber.ps1" and the "usertosystem_serialNumber.csv" to accomplish this task.

The "usertosystem_serialNumber.ps1" leverages the JumpCloud PowerShell module to associate users to systems using the systems serialNumber and the users JumpCloud username.

## Prerequisites

### The JumpCloud PowerShell Module

The JumpCloud PowerShell must be installed on the system that you intend to run the association automation workflow on.
Need to install the module? See: [Installing the JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

## Configuration

### usertosystem_serialNumber.ps1

The "usertosystem_serialNumber.ps1" contains logic that leverages the JumpCloud PowerShell module to make user to system associations from the input file "usertosystem_serialNumber.csv".

This file has two parameters that must be populated prior to running the script.

```PowerShell
$AssociationCSVPath = ""
$JCAPIKey = ""
```

The `$AssociationCSVPath` variable must be populated with the full file path to the "usertosystem_serialNumber.csv" file on the local system.

The `$JCAPIKey` variable must be populated with a JumpCloud API key. This API key is used to authenticate to the JumpCloud PowerShell module.

Example variables populated:

```PowerShell
$AssociationCSVPath = "/Users/buster/Desktop/usertosystem_serialNumber.csv"
$JCAPIKey = "lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382"

```
*lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382 is not a valid API key*

### usertosystem_serialNumber.csv

The "usertosystem_serialNumber.csv" file is the input file for the "usertosystem_serialNumber.ps1" PowerShell script. This CSV file has 5 mandatory CSV column headers: **Username,serialNumber,Administrator,Status,Log**

Admins are responsible for populating 3 of these colum headings.

These are: **Username,serialNumber,Administrator**

Admins should put an entry for each user to system association they would like to make in the "usertosystem_serialNumber.csv" file and populate the **Username** column with the JumpCloud username, the **serialNumber** column with the serialNumber of the system, and the **Administrator** column with either the value "True" or "False". The **Administrator** value determines if the user will be bound as a standard user or an admin user. If set to "True" the user will be bound to the system with Administrator permissions if set to False they will be bound as as standard user.

Example:

```Csv
Username,serialNumber,Administrator,Status,Log
colby.jack,VMaAUXL+fZQf,true
spring.onion,ec2477ca-5f36-cce9-a87d-ab14ddf3a915,false
```

User colby.jack will be bound to system with serial number `VMaAUXL+fZQf` with administrative permissions.
User spring.onion will be bound to system with serial number `ec2477ca-5f36-cce9-a87d-ab14ddf3a915` with standard permissions.

The column headings **Status,Log** will be updated after the "usertosystem_serialNumber.ps1" is run.

These fields should be left blank and **should not be modified** as the "usertosystem_serialNumber.ps1" contains logic that uses these fields.

After a successful run of the "usertosystem_serialNumber.ps1" the **Status,Log** fields will update with detailed information.

Example:

```CSV
Username,serialNumber,Administrator,Status,Log
colby.jack,VMaAUXL+fZQf,true,SUCCESS,User bound at 2019-08-23 14:06:11Z
spring.onion,ec2477ca-5f36-cce9-a87d-ab14ddf3a915,false,SUCCESS,User bound at 2019-08-23 14:07:12Z
```

After running the "usertosystem_serialNumber.ps1" both colby.jack and spring.onion were successfully bound to their respective systems.

## Usage

After populating the parameters in the "usertosystem_serialNumber.ps1" script file and adding association entries in the usertosystem_serialNumber.csv file (and filling in all three required fields: **Username,serialNumber,Administrator** for each entry) run the "usertosystem_serialNumber.ps1" file.

This can be invoked in a number of ways.

Example:

```PowerShell
. "/Users/buster/Desktop/usertosystem_serialNumber.ps1"
```

When run interactively a progress bar will display.

The `"/Users/buster/Desktop/usertosystem_serialNumber.ps1"` can be scheduled to run to setup an automated flow for binding users to systems.

When scheduled to run update the "usertosystem_serialNumber.csv" file with new association entries.

Entries that have a `SUCCESS` status can be removed or left in this CSV file as the logic in the "/Users/buster/Desktop/usertosystem_serialNumber.ps1" script only takes action on entries that are not in a `SUCCESS` status.

## Troubleshooting

The association may fail for the reasons shown below. The log output will reflect why the association failed and provide information to the admin to correct the issue.

- No serialNumber found

If no serialNumber is found ensure that the case sensitively of the serial inputted in the "usertosystem_serialNumber.csv" aligns with the format that is captured by the JumpCloud agent.

If the system simply has not had the JumpCloud agent installed then simply re run the script after the system has registered.

- Duplicate serialNumber

If more then one system is found with the same serialNumber the association will fail. To correct this remove any duplicate systems and try again.

- Inactive user

If the user being bound to the system is in an inactive state. Set a password for the user and try again.

- No username found

If no JumpCLoud user is found with the username of the user inputted in the "usertosystem_serialNumber.csv" file ensure that the case sensitively of the username inputted in the "usertosystem_serialNumber.csv" aligns with the format in the JumpCloud admin console.