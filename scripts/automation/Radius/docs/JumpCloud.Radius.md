---
Module Name: JumpCloud.Radius
Module Guid: 71bfaf58-3326-4512-9a7f-a2d9dc19d6b5
Download Help Link:  
Help Version: 2.1.2
Locale: en-Us
---

# JumpCloud.Radius Module
## Description
Module for managing JumpCloud Radius user certificates.

## JumpCloud.Radius Cmdlets
### [Get-JCRCertReport](Get-JCRCertReport.md)
This cmdlet generates a report of RADIUS certificates for JumpCloud devices and their associated users.

### [Get-JCRGlobalVars](Get-JCRGlobalVars.md)
This function retrieves and updates global variables related to JumpCloud Radius deployment, including user associations and system caches.

### [Set-JCRConfig](Set-JCRConfig.md)
This function sets the configuration for the JumpCloud Radius module, allowing you to specify various parameters such as certificate subject headers, network SSID, last update timestamp, certificate secret password, OpenSSL binary path, user certificate validity days, radius directory, CA certificate validity days, user group, certificate expiration warning days, and certificate type.

### [Start-DeployUserCerts](Start-DeployUserCerts.md)
This function initiates the deployment of user certificates for JumpCloud Managed Users.

### [Start-GenerateRootCert](Start-GenerateRootCert.md)
This function generates a root certificate for the JumpCloud Radius module, allowing you to create or replace the root certificate as needed.

### [Start-GenerateUserCerts](Start-GenerateUserCerts.md)
This function generates user certificates for JumpCloud Managed Users, allowing you to specify the type of certificate generation and whether to replace existing certificates.

### [Start-MonitorCertDeployment](Start-MonitorCertDeployment.md)
This function monitors the deployment of certificates for JumpCloud Managed Users, ensuring that the deployment process is tracked and any issues are logged.

### [Start-RadiusDeployment](Start-RadiusDeployment.md)
This function is the root menu for the GUI portion of the JumpCloud Radius module. It provides a user interface for managing Radius deployments, including generating root certificates, user certificates, and monitoring deployments.

### [Update-JCRModule](Update-JCRModule.md)
This function updates the JumpCloud Radius module, ensuring that the latest configurations and settings are applied.


