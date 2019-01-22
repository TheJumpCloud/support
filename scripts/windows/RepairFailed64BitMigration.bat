rem This script repairs a broken agent install after encountering the 64-bit OS upgrade bug on v0.10.41 
@echo off
rem We don't care about the output of this call, we just use it to verify we are administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: This script must be run as administrator
    pause
    exit /B 1
)

echo Reconfiguring the jumpcloud-agent service binary path
sc config jumpcloud-agent binPath= "C:\Program Files\JumpCloud\jumpcloud-agent.exe"
if %errorlevel% neq 0 (
    echo Error reconfiguring jumpcloud-agent service binary path. Cannot continue.
    pause
    exit /B 1
)
    
echo Restarting the jumpcloud-agent service
sc start jumpcloud-agent
if %errorlevel% neq 0 (
    echo Error restarting jumpcloud-agent service. Cannot continue.
    pause
    exit /B 1
)

echo Successfully reconfigured and restarted the jumpcloud-agent service
pause
exit /B 0
