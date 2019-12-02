## 1.2.5

#### RELEASE DATE

December 2, 2019

#### RELEASE NOTES

- ConvertSID Function updated to work on windows 7 and powershell 2.0

## 1.2.4

#### RELEASE DATE

November 26, 2019

#### RELEASE NOTES

- Add $AzureADProfile Parameter to allow conversion via migration.ps1 script

## 1.2.3

#### RELEASE DATE

November 19, 2019

#### RELEASE NOTES

- Force reboot without delay or keypress to work with CLI deployments
- Update Boolean options for EULA, Agent, LeaveDomain & ForceReboot

## 1.2.2

#### RELEASE DATE

October 29, 2019

#### RELEASE NOTES

- Fix Win7/Powershell 2.0 SID conversion query used in local admin check in GUI

## 1.2.1

#### RELEASE DATE

October 14, 2019

#### RELEASE NOTES

- Improve further and reduce migapp.xml & miguser.xml entrys. This will reduce overall file count and scanning times.

- Aditional Pester tests and azure pipeline CI for improved automated testing.

## 1.2.0

#### RELEASE DATE

September 27, 2019

#### RELEASE NOTES

- Improve and reduce migapp.xml & miguser.xml entrys. This will reduce overall file count and scanning times.

- Add UI loading feedback using write-progress. 

- Add localadmin column to UI for profiles.

- Add profile size column to UI for profiles. Also add system c:\ available space to UI.

- Introduce Pester tests and azure pipeline CI for improved automated testing.


## 1.1.0

#### RELEASE DATE

September 6, 2019

#### RELEASE NOTES

- Fix netbios name to use better function and account for cases where netbios name is different than domain name.

- Change ADK install path to use default.

- Improve install and running of USMT on x86 and x64 systems.

- Introduce custom config.xml to remove APAPI prompt.

- Introduce custom migapp.xml and miguser.xml to add more applications and downloads folder migration.
