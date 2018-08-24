REM When migrating a Windows machine from Active Directory to JumpCloud the AccountMigration.bat should be run prior to launching the SystemMigration.Bat
@ECHO OFF
start /B /W wmic.exe /interactive:off ComputerSystem Where "Name='%computername%'" Call UnJoinDomainOrWorkgroup FUnjoinOptions=0
start /B /W wmic.exe /interactive:off ComputerSystem Where "Name='%computername%'" Call JoinDomainOrWorkgroup name="WORKGROUP"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"