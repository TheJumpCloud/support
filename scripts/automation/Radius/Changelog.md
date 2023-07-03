## 1.0.5

Release Date: July 3, 2023

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
Iniital release of the Passwordless Radius User Certificate Generation automation scritps
```

#### FEATURES:

- Generate/ Import CA Certificate
- Generate User Certificates from CA Certificate
- Distribute User Certificates to JumpCloud Devices w/ JumpCloud Commands
- Monitor Command Deployments
