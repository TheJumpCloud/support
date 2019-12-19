# Custom Configuration Profiles in JumpCloud

JumpCloud supports the management of custom configuration profiles through commands. Third party tools like [ProfileCreator] or 

## General settings for ProfileCreator

The ProfileCreator application has a well-documented [wiki](https://github.com/ProfileCreator/ProfileCreator/wiki). Consult the wiki for ProfileCreator specific issues or join the conversion over in the #profilecreator channel in the [MacAdmins Slack](https://www.macadmins.org/) for additional help.

When opening ProfileCreator for the first time, it's advised to set organizational identifiers. Profiles exported with ProfileCreator are identified with the organizational identifiers set under ProfileCreator > Preferences > Profile Defaults:

![example preferences](images/preferences.png)

Consider setting an organization name and identifier. Policies signed with an Apple Developer account are verified on system endpoints.

![verified policy example](images/verified.png)


## Command Examples

The following section will walk through several example custom configuration profiles. At the time of this writing development of ProfileCreator manifests were still in development although the application ProfileCreator is no longer in development. The following examples should be used as a reference and tested in an environment prior to deployment

* Catalina Notifications
* Password Prevention
* Custom Software on Dock
* Firefox Profile

#### Catalina Notifications Profile

This example demonstrates the work required to build a custom policy to allow notifications on several applications. As of the release of Catalina 10.15 users are prompted to allow or deny specific applications from prompting notification banners.

This profile will allow the JumpCloud tray application to send the user notifications.

To create a new profile, open ProfileCreator and click the [ + ] icon.

![new profile window](images/new_profile.png)

Select a name for the policy, add a description and change the organization name if the settings were not applied by default. Depending on the policy scope, a profile can be applied at the System or User level. In this example the notification payload is a System level payload.

![notification profile general settings](images/notification_general.png)

Scroll down the left column profile template window, under macOS select the Notifications Payload, add the payload and add the notification settings preference so that the window is editable like the example below. Profiles selected as part of the profile payload are listed in top left column under the General tab.

![notifications window pre-configuration](images/notifications_pre.png)

In order to add applications to the payload the "App Bundle Identifier" name is required. There are several methods for identifying an applications "App Bundle Identifier". A quick way to identify an given "App Bundle Identifier" is to run the following command, substituting "Microsoft Excel" for the name of an application as it exists in a systems /Applications window.

```bash
osascript -e 'id of app "Microsoft Excel"'
```

![terminal output](images/notification_terminal.png)

The result of that command run against the jumpcloud application is: `com.jumpcloud.jcagent-tray`. Copy that value into the "App Bundle Identifier" for the Notification payload preference. In the example image below the `com.apple.iCal` notification settings are also applied. Note the difference between "Alert Types" between the two preferences. Refer to Apple's documentation on [alert types](https://developer.apple.com/design/human-interface-guidelines/macos/system-capabilities/notifications/) for more information.

Assuming the profile is ready for deployment. Save and Export the profile. Optionally sign the profile.

Using the PowerShell module, import the Custom Configuration Profile command to a JumpCloud tenant.

```pwsh
Import-JCCommand "Bit.ly-REPLACE_ME"
```



### Signing Profiles

### Password Protect Profiles

### Caveats, MDM restrictions

Some profiles must be distributed though User Approved MDM, since JumpCloud does not currently support UAMDM JumpCloud is unable to distribute the following profiles:

Privacy Preference Policy Control Profiles

### Removal of profiles
