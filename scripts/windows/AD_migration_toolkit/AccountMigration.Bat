REM This .Bat file launches the AccountMigration.ps1 file as administrtor. Right click and select Run-As Administrator to launch.
REM When migrating a Windows machine from Active Directory to JumpCloud the AccountMigration.bat should be run prior to launching the SystemMigration.Bat
@ECHO OFF
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}"