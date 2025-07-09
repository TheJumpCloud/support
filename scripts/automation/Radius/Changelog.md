## 2.1.0

Release Date: July 3, 2025

#### RELEASE NOTES

```
This release is a minor update to the Radius Cert Deployment tool. This version of the tool is now a PowerShell Module, which allows for easier updates and management of the tool. The module can be installed and updated from the PowerShell Gallery.
```

#### Features:

- The Radius Cert Deployment tool is now a PowerShell Module
- The module and the cert locations are now configurable via a new public function `Set-JCRConfig`
- All configuration settings which were previously stored in `config.ps1` are now variables configured with the `Set-JCRConfig` function
- The module can be installed and updated from the PowerShell Gallery using `Install-Module JumpCloud.Radius`

#### Bug Fixes:

- Fixed an issue where the macOS CommandNames were not stored correctly in the users.json file.
- Fixed an issue where the tool would not work correctly when only one user was assigned to the radius user group.

## 2.0.0

Release Date: January 30, 2024

#### RELEASE NOTES

```
This release offers a significant overhaul for the Radius Cert Deployment tool, many new underlying functions have been introduced to reduce the number of required API calls. Most notably, the tool will cache data from an organization on load.
```

#### Features:

- Added an option to both generate and deploy radius certificates by username
- Association data is cached up front rather than gathered throughout the script, offering performance improvements for organizations with a large number of radius users
- Added ability to run each public function headless in order to automate cert generation and distribution
- Added a table to keep track of generated/deployed certificates when using the tool
- Added password validation (re-enter) when generating root certificate
- Added Start-GenerateRootCert menu
  - Functionalities added
    - New: creates new root cert. If there is an existing root cert, user gets prompted to overwrite the cert
    - Replace: replaces the current cert. If you replace root cert, it will contain a different serial number and user certs generated with the previous CA will no longer authenticate
    - Renew: renewing the root CA will contain the same serial number and CA subject headers. User certs generated with the previous CA will continue to authenticate.

## 1.1.0

Release Date: December 13, 2023

#### RELEASE NOTES

```
Fixed an issue where similar usernames were having incorrect certificates deployed
```

#### Bug Fixes:

- Addressed a bug where similar usernames were having incorrect certificates deployed. Ex: john.smith and john

## 1.0.7

Release Date: December 1, 2023

#### RELEASE NOTES

```
In macOS, it's possible for a user to define their username as `user1234` or `USER1234`. When JumpCloud takes of a user it'll perform a case insensitive string comparison and take over the account that matches the username from JumpCloud.

Commands executed by JumpCloud in macOS run as shell scripts `/bin/bash` by default, this shell does not perform case-insensitive string comparisons. This patch version of the Radius Certificate Utility addresses this limitation by explicitly changing the `bash` match patterns to be case-insensitive.
```

#### Bug Fixes:

- Addressed a bug were users with differing casing (`user1234` vs `USER1234`) between the system and JumpCloud username

## 1.0.6

Release Date: September 25, 2023

#### RELEASE NOTES

```
Certificates distributed to macOS device are now imported using the -x flag to prevent them from being exported.
```

#### Bug Fixes:

- For users with multiple SSIDs where one SSID has a space in the name, previous versions of the script could not account for this. This version addresses this change by passing text with a ';' delimiter rather than a space.

## 1.0.5

Release Date: July 20, 2023

#### RELEASE NOTES

```
Addressed an issue generating certificates for users with localUsernames (systemUsernames specified in the JumpCloud console). These user certificates were generated with the localUsername instead of their username field. The resulting certificate would never be allowed to access a radius backed network as their localUsername does not match the username.
```

#### Bug Fixes:

- Certificates for users with localUsername (systemUsernames) should now authenticate to radius networks. Their CNs should now be based on their usernames, not localUsernames.

## 1.0.4

Release Date: June 5, 2023

#### RELEASE NOTES

```
Addressed an issue on macOS with EmailSAN and EmailDN type cert deployments where assigning network SSIDs during certificate import.
```

#### Bug Fixes:

- In previous versions, deploying either an EmailSAN or EmailDN type cert would throw an error while attempting to associate a network SSID to the newly imported certificate. The cert identifier in this case was updated to the SHA1 hash of the certificates instead of the common name (which was incorrectly identified in previous iterations of these example scripts).

## 1.0.3

Release Date: May 30, 2023

#### RELEASE NOTES

```
Fixed an issue affecting permissions on certain MacOS devices when attempting to deploy certs
Improved performance when reviewing Command Results by changing fetch requests to Search-JCSDKCommandResult endpoint
Added a condidtion for returning exit 4 on windows systems when no users are logged in
```

#### FEATURES:

- Fixed an issue affecting permissions on certain MacOS devices when attempting to deploy certs
- Improved performance when reviewing Command Results by changing fetch requests to Search-JCSDKCommandResult endpoint

## 1.0.2

Release Date: May 2, 2023

#### RELEASE NOTES

```
Fixed an issue with the JCUSERCERTPASS not being correctly passed into Windows devices when changed from default
```

#### FEATURES:

- JCUSERCERTPASS was not being correctly referenced when the device commands are generated resulting in certificates not being installed
- Adjusted error tracking for more precise results when a certificate wasn't installed

## 1.0.1

Release Date: April 21, 2023

#### RELEASE NOTES

```
Users with Local User Account names that differ from their JumpCloud Username are now supported
```

#### FEATURES:

- If a user's local account name (systemUsername) is specified on an account, the certificates for those users will be generated with their local account name (not username) and installed correctly.

## 1.0.0

Release Date: March 21, 2023

#### RELEASE NOTES

```
Initial release of the Passwordless Radius User Certificate Generation automation scripts
```

#### FEATURES:

- Generate/ Import CA Certificate
- Generate User Certificates from CA Certificate
- Distribute User Certificates to JumpCloud Devices w/ JumpCloud Commands
- Monitor Command Deployments
