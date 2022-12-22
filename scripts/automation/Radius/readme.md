# Generate Radius Certificates for users

The PowerShell automations in this directory are designed to help administrators generate user certificates for passwordless Radius Server Authentication.

## Setup

To generate a set of Radius certificates. The two scripts `Generate-Cert.ps1` and `Generate-UserCerts.ps1` must be used. A configuration file `Config.ps1` must also be edited prior to running the cert generation scripts.

### Set the Radius Config

Before Running either the `Generate-Cert.ps1` and `Generate-UserCerts.ps1` scripts the environment variables for your JumpCloud Organization must first be set. Open the `config.ps1` file with a text editor.

#### Set Your API Key ID

Change the variable `$JCAPIKEY` to an [API Key](https://support.jumpcloud.com/s/article/jumpcloud-apis1) from an administrator in your JumpCloud Tenant. An administrator API Key with at least [read-only access](https://support.jumpcloud.com/support/s/article/JumpCloud-Roles) is required.

#### Set Your Organization ID

Change the variable `$JCORGID` to the [organization ID value](https://support.jumpcloud.com/s/article/Settings-in-the-JumpCloud-Admin-Portal#AccessOrgID) from your JumpCloud Tenant.

#### Set Your User Group ID

Change the variable `$JCUSERGROUP` to the ID of the JumpCloud user group with access to the Radius server. To get the ID of a user group, navigate to the user group within the JumpCloud Administrator Console.

After selecting the User Group, view the url for the user group it should look similar to this url:
`https://console.jumpcloud.com/#/groups/user/5f808a1bb544064831f7c9fb/details`

The ID of the selected userGroup is the 24 character string between `/user/` and `/details`: `5f808a1bb544064831f7c9fb`

#### Set Your Certificate Subject Headers

Change the default values provided in the `$Subj` variable to Country, State, Locality, Organization, Organization Unit and Common Name values for your organization.

#### Set Desired User Certificate Type

Change the `$certType` variable to either `EmailSAN`, `EmailDN` or `UsernameCn`

## Certificate Generation

### Certificate Authority Generation

After setting environment variables in the `config.ps1` file. The `Generate-Cert.ps1` file should then be ran in order to generate the self-signed Radius authentication certificate.

In a PowerShell terminal or environment navigate to this directory:

`cd "~/Path/To/support/scripts/automation/Radius/"`

Run the `Generate-Cert.ps1` file

`./Generate-Cert.ps1`

After successfully running the script the openssl extension files should each be updated with your subject headers set from the `config.ps1` file.

Within the `/Cert` directory, two files should have been created:

`selfsigned-ca-cert.pem` and `selfsigned-ca-key.pem`

The certificate in this directory is to be uploaded to JumpCloud to act as the certificate authority for subsequently generated user certificates.

### User Cert Generation

With the certificate authority generated, the user certs can then be generated. Run the `Generate-UserCerts.ps1` file:

`./Generate-UserCerts.ps1`

The script will go fetch all users found in the user group specified in `config.ps1`. For each user in the group, a `.pfx` certificate will be generated in the `/UserCerts` directory.

Each user will then need to install their respective certificate on their devices.

### Windows specific instructions

The PowerShell scripts in this directory reference the OpenSSL binary. In MacOS, this is installed by default. In Windows you may need to add an alias to the OpenSSL executable before running the certificate generation scripts.

Your version of openssl may be installed elsewhere.

```powershell
Set-Alias "openssl" "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
```
