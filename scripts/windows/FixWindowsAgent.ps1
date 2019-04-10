<#
.SYNOPSIS
    Repairs an installation of the JumpCloud Windows agent
.DESCRIPTION
    Uninstalls any existing installations, and cleans up any remaining cruft,
    and reinstalls the agent.
.NOTES
    Name: FixWindowsAgent.ps1
    Author: www.jumpcloud.com
    Date created: 2016-02-08
.LINK
    http://support.jumpcloud.com
.EXAMPLE
    FixWindowsAgent.ps1
#>

# Get jumpcloud connect key from flag or env var
Param(
    [String]$JcConnectKey = $env:JC_CONNECT_KEY
)
if(-not($JcConnectKey)) { Throw "-JcConnectKey is required" }

$CONNECT_KEY="${JcConnectKey}"

$AGENT_PATH="${env:ProgramFiles}\JumpCloud"
$AGENT_CONF_FILE="\Plugins\Contrib\jcagent.conf"
$AGENT_BINARY_NAME="jumpcloud-agent.exe"

$AGENT_SERVICE_NAME="jumpcloud-agent"

$AGENT_INSTALLER_URL="https://s3.amazonaws.com/jumpcloud-windows-agent/production/JumpCloudInstaller.exe"
$AGENT_INSTALLER_PATH="$env:TEMP\JumpCloudInstaller.exe"
$AGENT_UNINSTALLER_NAME="unins000.exe"


$EVENT_LOGGER_KEY_NAME="hklm:\SYSTEM\CurrentControlSet\services\eventlog\Application\jumpcloud-agent"

$INSTALLER_BINARY_NAMES="JumpCloudInstaller.exe,JumpCloudInstaller.tmp"

#########################################################################################
#
# Agent Installer Funcs
#
#########################################################################################
Function InstallAgentDependency() {
    # Install VcRedist https://docs.stealthpuppy.com/docs/vcredist
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name VcRedist -Force
    Import-Module -Name VcRedist -Force

    # Get and install VC++ 2013 Redistributable package (x86 and x64)
    New-Item $env:TEMP\VcRedist -ItemType Directory -Force
    $VcList = Get-VcList -Release 2013
    $VcList | Save-VcRedist -ForceWebRequest -Path $env:TEMP\VcRedist
    Install-VcRedist -Silent -Path $env:TEMP\VcRedist -VcList $VcList
    Write-Host "Installed VC++ Distributions: "
    Get-InstalledVcRedist | Select Name, Version, ProductCode
}

Function DownloadAgentInstaller() {
    (New-Object System.Net.WebClient).DownloadFile("${AGENT_INSTALLER_URL}", "${AGENT_INSTALLER_PATH}")
}

Function AgentInstallerExists() {
    Test-Path ${AGENT_INSTALLER_PATH}
}

Function InstallAgent() {
    $params = ("${AGENT_INSTALLER_PATH}", "-k ${CONNECT_KEY}", "/VERYSILENT", "/NORESTART", "/SUPRESSMSGBOXES", "/NOCLOSEAPPLICATIONS", "/NORESTARTAPPLICATIONS", "/LOG=$env:TEMP\jcUpdate.log")
    Invoke-Expression "$params"
}

Function UninstallAgent() {
    # Due to PowerShell's incredible weakness in dealing with paths containing SPACEs, we need to
    # to hard-code this path...
    $params = ('C:\Program?Files\JumpCloud\unins000.exe', "/VERYSILENT", "/SUPPRESSMSGBOXES")
    Invoke-Expression "$params"
}

Function KillInstaller() {
    try {
        Stop-Process -processname ${INSTALLER_BINARY_NAMES} -ErrorAction Stop
    } catch {
        Write-Error "Could not kill JumpCloud installer processes"
    }
}

Function KillAgent() {
    try {
        Stop-Process -processname ${AGENT_BINARY_NAME} -ErrorAction Stop
    } catch {
        Write-Error "Could not kill running jumpcloud-agent process"
    }
}

Function InstallerIsRunning() {
    try {
        Get-Process ${INSTALLER_BINARY_NAMES} -ErrorAction Stop
        $true
    } catch {
        $false
    }
}

Function AgentIsRunning() {
    try {
        Get-Process ${AGENT_BINARY_NAME} -ErrorAction Stop
        $true
    } catch {
        $false
    }
}

Function AgentIsOnFileSystem() {
    Test-Path ${AGENT_PATH}/${AGENT_BINARY_NAME}
}

Function DeleteAgent() {
    try {
        Remove-Item ${AGENT_PATH}/${AGENT_BINARY_NAME} -ErrorAction Stop
    } catch {
        Write-Error "Could not remove remaining jumpcloud-agent.exe binary"
    }
}

#########################################################################################
#
# Service Manager Funcs
#
#########################################################################################
Function AgentIsInServiceManager() {
    try {
        $services = Get-Service -Name "${AGENT_SERVICE_NAME}" -ErrorAction Stop
        $true
    } catch {
        $false
    }
}

Function RemoveAgentService() {
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='${AGENT_SERVICE_NAME}'"
    if ($service) {
        try {
            $service.Delete()
        } catch {
            Write-Error "Could not remove jumpcloud-agent service entry"
        }
    }
}

Function RemoveEventLoggerKey() {
    try {
        Remove-Item -Path "$EVENT_LOGGER_KEY_NAME" -ErrorAction Stop
    } catch {
        Write-Error "Could not remove event logger key from registry"
    }
}



############################################################################################
#
# Work functions (uninstall, clean up, and reinstall)
#
############################################################################################
Function AgentIsInstalled() {
    $inServiceMgr = AgentIsInServiceManager
    $onFileSystem = AgentIsOnFileSystem

    $inServiceMgr -Or $onFileSystem
}

Function CheckForAndUninstallExistingAgent() {
    #
    # Is the installer running/hung?
    #
    if (InstallerIsRunning) {
        # Yep, kill it
        KillInstaller

        Write-Host "Killed running agent installer."
    }

    #
    # Is the agent running/hung?
    #
    if (AgentIsRunning) {
        # Yep, kill it
        KillAgent

        Write-Host "Killed running agent binary."
    }

    #
    # Is the agent still fully installed in both the service manager and on the file system?
    #
    if (AgentIsInstalled) {
        # Yep, try a normal uninstall
        UninstallAgent

        Write-Host "Completed agent uninstall."
    }
}

Function CleanUpAgentLeftovers() {
    # Remove any remaining event logger key...
    RemoveEventLoggerKey

    #
    # Is the agent still in the service manager?
    #
    if (AgentIsInServiceManager) {
        # Try to remove it, though it probably won't remove because we may in the state
        # where the service is "marked for deletion" (requires reboot before further
        # modifications can be done on this service).
        RemoveAgentService

        if (AgentIsInServiceManager) {
            Write-Host "Unable to remove agent service, this system needs to be rebooted."
            Write-Host "Then you can re-run this script to re-install the agent."
            exit 1
        }

        Write-Host "Removed agent service entry."
    }

    #
    # Is the agent still on the file system?
    #
    if (AgentIsOnFileSystem) {
        # Yes, the installer was unsuccessful in removing it.
        DeleteAgent

        Write-Host "Removed remaining agent binary file."
    }
}

############################################################################################
#
# Do a normal agent install, and verify correct installation
#
############################################################################################
Function DownloadAndInstallAgent() {
    $agentIsInstalled = AgentIsInstalled
    if (-Not $agentIsInstalled) {
        Write-Host -nonewline "Downloading agent installer..."

        DownloadAgentInstaller

        if (AgentInstallerExists) {
            Write-Host " complete."

            Write-Host -nonewline "Installing agent..."
            InstallAgent
            $exitCode = $?
            $agentIsInstalled = AgentIsInstalled

            Write-Host " complete. (exit code=$exitCode)"

            if ($exitCode -ne $true) {
                Write-Error "Agent installation failed. Please rerun this script,`nand if that doesn't work, please reboot and try again.`nIf neither work, please contact support@jumpcloud.com"
                exit 1
            } else {
               Write-Host "`n* * * SUCCESS! Agent installation complete. * * *"
            }
        } else {
            Write-Error "Could not download agent installer from ${AGENT_INSTALLER_URL}. Install FAILED."
            exit 1
        }
    } else {
        Write-Host "Agent is already installed, not installing again."
    }
}

InstallAgentDependency

CheckForAndUninstallExistingAgent

CleanUpAgentLeftovers

DownloadAndInstallAgent
