# To run unattended pass in the parameter -JumpCloudConnectKey in when calling the InstallWindowsAgent.ps1
# Example ./InstallWindowsAgent.ps1 -JumpCloudConnectKey "56b403784365r6o2n311cosr218u1762le4y9e9a"
# Your JumpCloudConnectKey can be found on the systems tab within the JumpCloud admin console.

Param (
    [Parameter (Mandatory = $true)]
    [string] $JumpCloudConnectKey
)

#--- Modify Below This Line At Your Own Risk ------------------------------

# JumpCloud Agent Installation Variables
$TempPath = 'C:\Windows\Temp\'
$AGENT_PATH = Join-Path ${env:ProgramFiles} "JumpCloud"
$AGENT_BINARY_NAME = "jumpcloud-agent.exe"
$AGENT_INSTALLER_URL = "https://cdn02.jumpcloud.com/production/jcagent-msi-signed.msi"
$AGENT_INSTALLER_PATH = "C:\windows\Temp\jcagent-msi-signed.msi"
# JumpCloud Agent Installation Functions
Function InstallAgent() {
    msiexec /i $AGENT_INSTALLER_PATH /quiet JCINSTALLERARGUMENTS=`"-k $JumpCloudConnectKey /VERYSILENT /NORESTART /NOCLOSEAPPLICATIONS /L*V "C:\Windows\Temp\jcUpdate.log"`"
}
Function DownloadAgentInstaller() {
    (New-Object System.Net.WebClient).DownloadFile("${AGENT_INSTALLER_URL}", "${AGENT_INSTALLER_PATH}")
}
Function DownloadAndInstallAgent() {
    If (Test-Path -Path "$($AGENT_PATH)\$($AGENT_BINARY_NAME)") {
        Write-Output 'JumpCloud Agent Already Installed'
    } else {
        Write-Output 'Downloading JCAgent Installer'
        # Download Installer
        DownloadAgentInstaller
        Write-Output 'JumpCloud Agent Download Complete'
        Write-Output 'Running JCAgent Installer'
        # Run Installer
        InstallAgent

        # Check if agent is running as a service
        # Do a loop for 5 minutes to check if the agent is running as a service
        # The agent pulls cef files during install which may take longer then previously.
        for ($i = 0; $i -lt 300; $i++) {
            Start-Sleep -Seconds 1
            #Output the errors encountered
            $AgentService = Get-Service -Name "jumpcloud-agent" -ErrorAction SilentlyContinue
            if ($AgentService.Status -eq 'Running') {
                Write-Output 'JumpCloud Agent Succesfully Installed'
                exit
            }
        }
        Write-Output 'JumpCloud Agent Failed to Install'
    }
}

#Flush DNS Cache Before Install

ipconfig /FlushDNS

# JumpCloud Agent Installation Logic

DownloadAndInstallAgent