# Version 1.1 - Updates restart counter to 10 seconds and adds agent install validation for MS C++ 2013

# Silent JumpCloud Agent Installation Script

$CONNECT_KEY = "" # <--- paste your organizations connect key between the " ". This key can be found within the JumpCloud admin console on the 'Systems' tab by clicking the green (+) in the top left corner.

# ------- DO NOT MODIFY BELOW THIS LINE ------------------------

# JumpCloud Agent Installation Variables
$AGENT_PATH = "${env:ProgramFiles}\JumpCloud"
$AGENT_CONF_FILE = "\Plugins\Contrib\jcagent.conf"
$AGENT_BINARY_NAME = "jumpcloud-agent.exe"
$AGENT_SERVICE_NAME = "jumpcloud-agent"
$AGENT_INSTALLER_URL = "https://cdn02.jumpcloud.com/production/JumpCloudInstaller.exe"
$AGENT_INSTALLER_PATH = "$env:TEMP\JumpCloudInstaller.exe"
$AGENT_UNINSTALLER_NAME = "unins000.exe"
$EVENT_LOGGER_KEY_NAME = "hklm:\SYSTEM\CurrentControlSet\services\eventlog\Application\jumpcloud-agent"
$INSTALLER_BINARY_NAMES = "JumpCloudInstaller.exe,JumpCloudInstaller.tmp"


# Agent Install Helper Functions
Function AgentIsInstalled() {
    $inServiceMgr = AgentIsInServiceManager
    $onFileSystem = AgentIsOnFileSystem

    $inServiceMgr -Or $onFileSystem
}

Function AgentIsInServiceManager() {
    try {
        $services = Get-Service -Name "${AGENT_SERVICE_NAME}" -ErrorAction Stop
        $true
    } catch {
        $false
    }
}

Function AgentIsOnFileSystem() {
    Test-Path ${AGENT_PATH}/${AGENT_BINARY_NAME}
}

Function AgentInstallerExists() {
    Test-Path ${AGENT_INSTALLER_PATH}
}

Function InstallAgent() {
    $params = ("${AGENT_INSTALLER_PATH}", "-k ${CONNECT_KEY}", "/VERYSILENT", "/NORESTART", "/SUPRESSMSGBOXES", "/NOCLOSEAPPLICATIONS", "/NORESTARTAPPLICATIONS", "/LOG=$env:TEMP\jcUpdate.log")
    Invoke-Expression "$params"
}

Function AgentIsInstalled() {
    $inServiceMgr = AgentIsInServiceManager
    $onFileSystem = AgentIsOnFileSystem

    $inServiceMgr -Or $onFileSystem
}

Function DownloadAgentInstaller() {
    (New-Object System.Net.WebClient).DownloadFile("${AGENT_INSTALLER_URL}", "${AGENT_INSTALLER_PATH}")
}

# JumpCloud Agent Install
Function DownloadAndInstallAgent() {
    $agentIsInstalled = AgentIsInstalled
    if (-Not $agentIsInstalled) {
        Write-Host -nonewline "Downloading agent installer..."

        DownloadAgentInstaller

        if (AgentInstallerExists) {
            Write-Host " complete."

            Write-Host -nonewline "Installing agent..."
            InstallAgent
            Start-Sleep -s 5

            $ConfirmInstall = AgentIsInServiceManager

            [int]$ConfirmInstallCounter = 0

            while ($ConfirmInstall -ne $true) {
                Start-Sleep -s 2
                $ConfirmInstall = AgentIsInServiceManager
                $ConfirmInstallCounter ++

                if ($ConfirmInstallCounter -eq 30) {
                    Write-Error "Agent installation failed. Please rerun this script,`nand if that doesn't work, please reboot and try again.`nIf neither work, please contact support@jumpcloud.com"
                    exit 1
                }
            }

            $exitCode = $?
            $agentIsInstalled = AgentIsInstalled

            Write-Host " complete. (exit code=$exitCode)"

            if ($exitCode -ne $true) {
                Write-Error "Agent installation failed. Please rerun this script,`nand if that doesn't work, please reboot and try again.`nIf neither work, please contact support@jumpcloud.com"
                exit 1
            } else {
                Write-Host "`n* * * SUCCESS! Agent installation complete. * * *"
                Start-Sleep -s 2
            }
        } else {
            Write-Error "Could not download agent installer from ${AGENT_INSTALLER_URL}. Install FAILED."
            exit 1
        }
    } else {
        Write-Host "Agent is already installed, not installing again."
    }
}

Function ForceRebootComputerWithDelay {
    Param(
        [int]$TimeOut = 10
    )
    $continue = $true

    while ($continue) {
        if ([console]::KeyAvailable) {
            Write-Host "Restart Canceled by key press"
            Exit
        } else {
            Write-Host "Press any key to cancel... restarting in $TimeOut" -NoNewLine
            Start-Sleep -Seconds 1
            $TimeOut = $TimeOut - 1
            Clear-Host
            if ($TimeOut -eq 0) {
                $continue = $false
                $Restart = $true
            }
        }
    }
    if ($Restart -eq $True) {
        Write-Host "Restarting Computer..."
        Restart-Computer -ComputerName $env:COMPUTERNAME -Force
    }
}

DownloadAndInstallAgent

if ($?) {
    ForceRebootComputerWithDelay
}

