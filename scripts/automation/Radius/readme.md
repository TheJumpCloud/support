# Generate Radius Certificates for users

The PowerShell automations in this directory are designed to help administrators generate user certificates for passwordless Radius Server Authentication.

## Requirements

This automation has been tested with OpenSSL 3.0.7 at the time of this writing. OpenSSL 3.x.x is required to generate the Radius Authentication certificates. The following items are required to use this automation workflow

- PowerShell 7.x.x ([PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3))
- OpenSSL 3.x.x (Tested with 3.0.7)
- [JumpCloud PowerShell Module](https://www.powershellgallery.com/packages/JumpCloud/2.1.3) 

### MacOS Requirements

MacOS ships with a version of OpenSSL under the distribution name LibreSSL. LibreSSL is sufficient to generate the `usernameCN` and `emailDN` type certificates but not the `emailSAN` type certificate (due to the inclusion of x509 subject headers in the certificate body). As such a distribution of OpenSSL 3.x.x is required to run these scripts.

To install the latest version of OpenSSL on mac, install the [Homebrew package manager](https://brew.sh/) and install the following [formulae](https://formulae.brew.sh/formula/openssl@3)

Some packages or applications in MacOS will rely on the pre-configured LibreSSL distribution. To use the Homebrew version of OpenSSL in this project, simply change the `$openSSLBinary` variable to point to the Homebrew bin location ex:

In `Config.ps1` change `$opensslBinary` to point to `'/usr/local/Cellar/openssl@3/3.0.7/bin/openssl'`
$opensslBinary = '/usr/local/Cellar/openssl@3/3.0.7/bin/openssl'

### Windows Requirements

Windows does not typically ship with a preconfigured version of OpenSSL but a pre-compiled version of OpenSSL can be installed from [Shining Light Productions](https://slproweb.com/products/Win32OpenSSL.html). OpenSSL can of course be downloaded and configured from [source](https://www.openssl.org/source) if desired.

If the pre-compiled version of OpenSSL was installed, the OpenSSL should be installed in `C:\Program Files\OpenSSL-Win64\bin\`. There should exist an `openssl.exe` in that directory. In addition there should also exist a `legacy.dll` file in that same directory.

To set the required system environment variables for this automation

- Open Control Panel
- Select "Edit the system environment variables"
- under the "System Properties" window and "Advanced" tab, select the "Environment Variables..." box
- Under the "User Variables for yourAccount" Click the "New..." box
  - Set the Variable Name to: `OPENSSL_MODULES`
  - Set the Variable Value to: `C:\Program Files\OpenSSL-Win64\bin` or the location of the `legacy.dll` file included in your OpenSSL distribution
  - Click "OK"
- Under the "System variables" section scroll down to the "Path" variable, select it and click "Edit..."
  - Add a new line entry for this variable and type `C:\Program Files\OpenSSL-Win64\bin` or the location of the `openssl.exe` file included in your OpenSSL distribution
  - Click "OK"
- Click "OK" to close and save the Environment Variables dialog box
- Click "OK to close and save the System Properties dialog box

The `openssl` command should be available in new PowerShell terminal windows.

## Setup

To generate a set of Radius certificates. The two scripts `Generate-RootCert.ps1` and `Generate-UserCerts.ps1` must be used. A configuration file `Config.ps1` must also be edited prior to running the cert generation scripts.

### Set the Radius Config

Before Running either the `Generate-RootCert.ps1` and `Generate-UserCerts.ps1` scripts the environment variables for your JumpCloud Organization must first be set. Open the `config.ps1` file with a text editor.

#### Set Your API Key ID

Change the variable `$JCAPIKEY` to an [API Key](https://support.jumpcloud.com/s/article/jumpcloud-apis1) from an administrator in your JumpCloud Tenant. An administrator API Key with at least [read/write access](https://support.jumpcloud.com/support/s/article/JumpCloud-Roles) is required.

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

After setting environment variables in the `config.ps1` file. The `Generate-RootCert.ps1` file should then be ran in order to generate the self-signed Radius authentication certificate.

In a PowerShell terminal or environment navigate to this directory:

`cd "~/Path/To/support/scripts/automation/Radius/"`

Run the `Generate-RootCert.ps1` file

`./Generate-RootCert.ps1`

After successfully running the script the openssl extension files should each be updated with your subject headers set from the `config.ps1` file.

Within the `/Cert` directory, two files should have been created:

`selfsigned-ca-cert.pem` and `selfsigned-ca-key.pem`

The certificate in this directory is to be uploaded to JumpCloud to act as the certificate authority for subsequently generated user certificates.

### User Cert Generation

With the certificate authority generated, the user certs can then be generated. Run the `Generate-UserCerts.ps1` file:

`./Generate-UserCerts.ps1`

The script will go fetch all users found in the user group specified in `config.ps1`. For each user in the group, a `.pfx` certificate will be generated in the `/UserCerts` directory.

Each user will then need to install their respective certificate on their devices.

## Certificate Distribution

### Distribute Certificates

After Generating all the user certificates, the `Distribute-UserCerts.ps1` file is used to create commands in the JumpCloud Console for distribution to end users.

In a PowerShell terminal or environment navigate to this directory:

`cd "~/Path/To/support/scripts/automation/Radius/"`

Run the `Distribute-UserCerts.ps1` file

`./Distribute-UserCerts.ps1`

Commands will be generated in your JumpCloud Tenant for each user in the Radius User Group and their corresponding system associations. This script will prompt you to kick off the generated commands. If the commands are invoked, they should be queued for all users in the Radius User Group. These commands are queued with a TTL timeout of 10 days — meaning that if the end user device is offline when the command is queued, for 10 days, the command will sit in the JumpCLoud console and wait for the device to come online before attempting to run.

### Monitor Certificate Deployment Status

After creating the commands to distribute the certificates to users, you can view the overall progress of the deployment through the `Monitor-CertDeployment.ps1` script. This script will query the deployment status of each generated command and display a table of the command status. If a command is no longer queued (Either through cancellation or the TTL timeout of 10 days exceeded) or if the command failed (either through some standard error or end user not being logged in (exit code 4)) running the `Monitor-CertDeployment.ps1` script will prompt you to retry those dequeued or failed commands.

Output for pending commands:
![pending and successful commands](./images/monitor_pending.png)

Output for re-running commands:
![rerunning commands](./images/monitor_retry.png)

### End User Experience

After a user's certificate has been distributed to a system, those users can then connect to a radius network with certificate based authentication.

### MacOS

In MacOS a user simply needs to select the radius network from the wireless networks dialog prompt. An option to authenticate with a certificate should be presented. After selecting the user's certificate, the MacOS user is prompted to enter their system password. They can do this and select "Always Allow" or will otherwise be prompted to enter their password three times.

### Windows

In Windows, select the radius network from the wireless networks dialog prompt, an option to select a certificate should be displayed. Select the certificate which corresponds with the user on the device. Select "OK"

![select network](./images/windows_select_network.png)

Before Connecting, users can view the authentication source. Click "Connect" to connect to the network, no password is necessary.

![select network](./images/windows_auth.png)

### Troubleshooting

#### Clearing Commands Queue

If needed, you can clear out your entire commands queue. Copy and paste the following code to a PowerShell terminal window where you've already run `Connect-JCOnline`

```powershell
function Get-JCQueuedCommands {
    begin {
        $headers = @{
            "x-api-key" = $Env:JCApiKey
            "x-org-id"  = $Env:JCOrgId

        }
        $limit = [int]100
        $skip = [int]0
        $resultsArray = @()
    }
    process {
        while (($resultsArray.results).Count -ge $skip) {
            $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/queuedcommand/workflows?limit=$limit&skip=$skip" -Method GET -Headers $headers
            $skip += $limit
            $resultsArray += $response.results
        }
    }
    end {
        return $resultsArray
    }
}
$headers = @{
    "x-api-key" = $Env:JCApiKey
    "x-org-id"  = $Env:JCOrgId
}
$queuedCommands = Get-JCQueuedCommands
foreach ($queue in $queuedCommands.id) {
    $response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/v2/commandqueue/$($queue)" -Method DELETE -Headers $headers
}
```
