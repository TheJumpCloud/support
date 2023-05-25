## 1.0.3

Release Date: May 24, 2023

#### RELEASE NOTES

```
Fixed an issue affecting permissions on certain MacOS devices when attempting to deploy certs
Improved performance when reviewing Command Results by changing fetch requests to Search-JCSDKCommandResult endpoint
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
