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

#
# Update with your own JumpCloud connect key
#
$CONNECT_KEY = "your-JumpCloud-Connect-Key-here"

$AGENT_PATH = "${env:ProgramFiles}\JumpCloud"
$AGENT_CONF_FILE = "\Plugins\Contrib\jcagent.conf"
$AGENT_BINARY_NAME = "jumpcloud-agent.exe"

$AGENT_SERVICE_NAME = "jumpcloud-agent"

$AGENT_INSTALLER_URL = "https://s3.amazonaws.com/jumpcloud-windows-agent/production/JumpCloudInstaller.exe"
$AGENT_INSTALLER_PATH = "$env:TEMP\JumpCloudInstaller.exe"
$AGENT_UNINSTALLER_NAME = "unins000.exe"


$EVENT_LOGGER_KEY_NAME = "hklm:\SYSTEM\CurrentControlSet\services\eventlog\Application\jumpcloud-agent"

$INSTALLER_BINARY_NAMES = "JumpCloudInstaller.exe,JumpCloudInstaller.tmp"

#########################################################################################
#
# Agent Installer Funcs
#
#########################################################################################
Function DownloadAgentInstaller()
{
    (New-Object System.Net.WebClient).DownloadFile("${AGENT_INSTALLER_URL}", "${AGENT_INSTALLER_PATH}")
}

Function AgentInstallerExists()
{
    Test-Path ${AGENT_INSTALLER_PATH}
}

Function InstallAgent()
{
    $params = ("${AGENT_INSTALLER_PATH}", "-k ${CONNECT_KEY}", "/VERYSILENT", "/NORESTART", "/SUPRESSMSGBOXES", "/NOCLOSEAPPLICATIONS", "/NORESTARTAPPLICATIONS", "/LOG=$env:TEMP\jcUpdate.log")
    Invoke-Expression "$params"
}

Function UninstallAgent()
{
    # Due to PowerShell's incredible weakness in dealing with paths containing SPACEs, we need to
    # to hard-code this path...
    $params = ('C:\Program?Files\JumpCloud\unins000.exe', "/VERYSILENT", "/SUPPRESSMSGBOXES")
    Invoke-Expression "$params"
}

Function KillInstaller()
{
    try
    {
        Stop-Process -processname ${INSTALLER_BINARY_NAMES} -ErrorAction Stop
    }
    catch
    {
        Write-Output "Could not kill JumpCloud installer processes"
    }
}

Function KillAgent()
{
    try
    {
        Stop-Process -processname ${AGENT_BINARY_NAME} -ErrorAction Stop
    }
    catch
    {
        Write-Output "Could not kill running jumpcloud-agent process"
    }
}

Function InstallerIsRunning()
{
    try
    {
        Get-Process ${INSTALLER_BINARY_NAMES} -ErrorAction Stop
        $true
    }
    catch
    {
        $false
    }
}

Function AgentIsRunning()
{
    try
    {
        Get-Process ${AGENT_BINARY_NAME} -ErrorAction Stop
        $true
    }
    catch
    {
        $false
    }
}

Function AgentIsOnFileSystem()
{
    Test-Path ${AGENT_PATH}/${AGENT_BINARY_NAME}
}

Function DeleteAgent()
{
    try
    {
        Remove-Item ${AGENT_PATH}/${AGENT_BINARY_NAME} -ErrorAction Stop
    }
    catch
    {
        Write-Output "Could not remove remaining jumpcloud-agent.exe binary"
    }
}

#########################################################################################
#
# Service Manager Funcs
#
#########################################################################################
Function AgentIsInServiceManager()
{    
    try
    {
        $services = Get-Service -Name "${AGENT_SERVICE_NAME}" -ErrorAction Stop
        $true
    }
    catch
    {
        $false
    }
}

Function RemoveAgentService()
{
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='${AGENT_SERVICE_NAME}'"
    if ($service)
    {
        try
        {
            $service.Delete()
        }
        catch
        {
            Write-Output "Could not remove jumpcloud-agent service entry"
        }
    }
}

Function RemoveEventLoggerKey()
{
    try
    {
        Remove-Item -Path "$EVENT_LOGGER_KEY_NAME" -ErrorAction Stop
    }
    catch
    {
        Write-Output "Could not remove event logger key from registry"
    }
}



############################################################################################
#
# Work functions (uninstall, clean up, and reinstall)
#
############################################################################################
Function AgentIsInstalled()
{
    $inServiceMgr = AgentIsInServiceManager
    $onFileSystem = AgentIsOnFileSystem

    $inServiceMgr -Or $onFileSystem
}

Function CheckForAndUninstallExistingAgent()
{
    #
    # Is the installer running/hung?
    #
    if (InstallerIsRunning)
    {
        # Yep, kill it
        KillInstaller
        
        Write-Output "Killed running agent installer."
    }

    #
    # Is the agent running/hung?
    #
    if (AgentIsRunning)
    {
        # Yep, kill it
        KillAgent
        
        Write-Output "Killed running agent binary."
    }

    #
    # Is the agent still fully installed in both the service manager and on the file system?
    #
    if (AgentIsInstalled)
    {
        # Yep, try a normal uninstall
        UninstallAgent
        
        Write-Output "Completed agent uninstall."
    }
}

Function CleanUpAgentLeftovers()
{
    # Remove any remaining event logger key...
    RemoveEventLoggerKey

    #
    # Is the agent still in the service manager?
    #
    if (AgentIsInServiceManager)
    {
        # Try to remove it, though it probably won't remove because we may in the state
        # where the service is "marked for deletion" (requires reboot before further
        # modifications can be done on this service).
        RemoveAgentService
        
        if (AgentIsInServiceManager)
        {
            Write-Output "Unable to remove agent service, this system needs to be rebooted."
            Write-Output "Then you can re-run this script to re-install the agent."
            exit 1
        }
        
        Write-Output "Removed agent service entry."
    }

    #
    # Is the agent still on the file system?
    #
    if (AgentIsOnFileSystem)
    {
        # Yes, the installer was unsuccessful in removing it.
        DeleteAgent
        
        Write-Output "Removed remaining agent binary file."
    }
}

############################################################################################
#
# Do a normal agent install, and verify correct installation
#
############################################################################################
Function DownloadAndInstallAgent()
{
    $agentIsInstalled = AgentIsInstalled
    if (-Not $agentIsInstalled)
    {
        Write-Output  "Downloading agent installer..."

        DownloadAgentInstaller

        if (AgentInstallerExists)
        {
            Write-Output " complete."

            Write-Output  "Installing agent..."
            InstallAgent
            $exitCode = $?
            $agentIsInstalled = AgentIsInstalled

            Write-Output " complete. (exit code=$exitCode)"

            if ($exitCode -ne $true)
            {
                Write-Error "Agent installation failed. Please rerun this script,`nand if that doesn't work, please reboot and try again.`nIf neither work, please contact support@jumpcloud.com"
                exit 1
            }
            else
            {
                Write-Output "`n* * * SUCCESS! Agent installation complete. * * *" 
            }                
        }
        else
        {
            Write-Error "Could not download agent installer from ${AGENT_INSTALLER_URL}. Install FAILED."
            exit 1
        }
    }
    else
    {
        Write-Output "Agent is already installed, not installing again."
    }
}

CheckForAndUninstallExistingAgent

CleanUpAgentLeftovers

DownloadAndInstallAgent
