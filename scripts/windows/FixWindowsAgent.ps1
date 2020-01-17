<#
.SYNOPSIS
    Repairs an installation of the JumpCloud Windows agent
.DESCRIPTION
    Uninstalls any existing installations, and cleans up any remaining cruft,
    and reinstalls the agent.
.NOTES
    Name: FixWindowsAgent.ps1
    Author: www.jumpcloud.com
    Date Updated: 2019-12-09
.LINK
    http://support.jumpcloud.com
.EXAMPLE
    Example ./FixWindowsAgent.ps1 -JumpCloudConnectKey "56b403784365r6o2n311cosr218u1762le4y9e9a"
#>

Param (
    [Parameter (Mandatory = $true)]
    [string] $JumpCloudConnectKey
)

#--- Modify Below This Line At Your Own Risk ------------------------------

# JumpCloud Agent Installation Variables
$msvc2013x64File = 'vc_redist.x64.exe'
$msvc2013x86File = 'vc_redist.x86.exe'
$msvc2013x86Link = 'http://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x86.exe'
$msvc2013x64Link = 'http://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x64.exe'
$TempPath = 'C:\Windows\Temp\'
$msvc2013x86Install = "$TempPath$msvc2013x86File /install /quiet /norestart"
$msvc2013x64Install = "$TempPath$msvc2013x64File /install /quiet /norestart"
$AGENT_PATH = "${env:ProgramFiles}\JumpCloud"
$AGENT_BINARY_NAME = "JumpCloud-agent.exe"
$AGENT_INSTALLER_URL = "https://s3.amazonaws.com/jumpcloud-windows-agent/production/JumpCloudInstaller.exe"
$AGENT_INSTALLER_PATH = "C:\windows\Temp\JumpCloudInstaller.exe"

$AGENT_PATH = "${env:ProgramFiles}\JumpCloud"
$AGENT_BINARY_NAME = "jumpcloud-agent.exe"

$AGENT_SERVICE_NAME = "jumpcloud-agent"

$AGENT_INSTALLER_URL = "https://s3.amazonaws.com/jumpcloud-windows-agent/production/JumpCloudInstaller.exe"
$AGENT_INSTALLER_PATH = "$env:TEMP\JumpCloudInstaller.exe"


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
    }
}


Function InstallAgent()
{
    $params = ("${AGENT_INSTALLER_PATH}", "-k ${JumpCloudConnectKey}", "/VERYSILENT", "/NORESTART", "/SUPRESSMSGBOXES", "/NOCLOSEAPPLICATIONS", "/NORESTARTAPPLICATIONS", "/LOG=$env:TEMP\jcUpdate.log")
    Invoke-Expression "$params"
}
Function DownloadAgentInstaller()
{
    (New-Object System.Net.WebClient).DownloadFile("${AGENT_INSTALLER_URL}", "${AGENT_INSTALLER_PATH}")
}

Function CheckProgramInstalled($programName)
{
    $installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -match $programName })
    if (-not [System.String]::IsNullOrEmpty($installed))
    {
        return $true
    }
    else
    {
        return $false
    }
}

Function DownloadLink($Link, $Path)
{

    $WebClient = New-Object -TypeName:('System.Net.WebClient')
    $Global:IsDownloaded = $false
    $SplatArgs = @{ InputObject = $WebClient
        EventName               = 'DownloadFileCompleted'
        Action                  = { $Global:IsDownloaded = $true; }
    }
    $DownloadCompletedEventSubscriber = Register-ObjectEvent @SplatArgs
    $WebClient.DownloadFileAsync("$Link", "$Path")
    While (-not $Global:IsDownloaded)
    {
        Start-Sleep -Seconds 3
    } # While
    $DownloadCompletedEventSubscriber.Dispose()
    $WebClient.Dispose()

}


Function DownloadAndInstallAgent(
    [System.String]$msvc2013x64Link
    , [System.String]$TempPath
    , [System.String]$msvc2013x64File
    , [System.String]$msvc2013x64Install
    , [System.String]$msvc2013x86Link
    , [System.String]$msvc2013x86File
    , [System.String]$msvc2013x86Install
)
{
    If (!(CheckProgramInstalled("Microsoft Visual C\+\+ 2013 x64")))
    {
        Write-Output "Downloading & Installing JCAgent prereq Visual C++ 2013 x64"
        DownloadLink -Link:($msvc2013x64Link) -Path:($TempPath + $msvc2013x64File)
        Invoke-Expression -Command:($msvc2013x64Install)
        Write-Output "JCAgent Visual C++ 2013 x64 prereq installed"
    }
    If (!(CheckProgramInstalled("Microsoft Visual C\+\+ 2013 x86")))
    {
        Write-Output 'Downloading & Installing JCAgent prereq Visual C++ 2013 x86'
        DownloadLink -Link:($msvc2013x86Link) -Path:($TempPath + $msvc2013x86File)
        Invoke-Expression -Command:($msvc2013x86Install)
        Write-Output 'JCAgent prereq installed'
    }
    If (!(AgentIsOnFileSystem))
    {
        Write-Output 'Downloading JCAgent Installer'
        # Download Installer
        DownloadAgentInstaller
        Write-Output 'JumpCloud Agent Download Complete'
        Write-Output 'Running JCAgent Installer'
        # Run Installer
        InstallAgent

    }
    If (CheckProgramInstalled("Microsoft Visual C\+\+ 2013 x64") -and CheckProgramInstalled("Microsoft Visual C\+\+ 2013 x86") -and AgentIsOnFileSystem)
    {
        Write-Output 'JumpCloud Agent Installer Completed'
    }
    Else
    {
        Write-Output 'JumpCloud Agent Installer Failed'
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
            Write-Output "JumpCloud Agent Service Not Running"
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
        Write-Output "JumpCloud Agent Event Logger Key Not Present"
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

        Write-Output "Uninstalling agent"
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

    }

    #
    # Is the agent still on the file system?
    #
    if (AgentIsOnFileSystem)
    {
        # Yes, the installer was unsuccessful in removing it.
        DeleteAgent
        
    }
}

############################################################################################
#
# Do a normal agent install, and verify correct installation
#
############################################################################################

CheckForAndUninstallExistingAgent

CleanUpAgentLeftovers

#Flush DNS Cache Before Install

ipconfig /FlushDNS

DownloadAndInstallAgent -msvc2013x64link:($msvc2013x64Link) -TempPath:($TempPath) -msvc2013x64file:($msvc2013x64File) -msvc2013x64install:($msvc2013x64Install) -msvc2013x86link:($msvc2013x86Link) -msvc2013x86file:($msvc2013x86File) -msvc2013x86install:($msvc2013x86Install)