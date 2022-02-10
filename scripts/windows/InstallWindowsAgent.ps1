# To run unattended pass in the parameter -JumpCloudConnectKey in when calling the InstallWindowsAgent.ps1
# Example ./InstallWindowsAgent.ps1 -JumpCloudConnectKey "56b403784365r6o2n311cosr218u1762le4y9e9a"
# Your JumpCloudConnectKey can be found on the systems tab within the JumpCloud admin console.


Param (
    [Parameter (Mandatory = $true)]
    [string] $JumpCloudConnectKey
)

#--- Modify Below This Line At Your Own Risk ------------------------------

# JumpCloud Agent Installation Variables
$msvc2013x64File = 'vc_redist.x64.exe'
$msvc2013x86File = 'vc_redist.x86.exe'
$msvc2013x86Link = 'https://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x86.exe'
$msvc2013x64Link = 'https://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x64.exe'
$TempPath = 'C:\Windows\Temp\'
$msvc2013x86Install = "$TempPath$msvc2013x86File /install /quiet /norestart"
$msvc2013x64Install = "$TempPath$msvc2013x64File /install /quiet /norestart"
$AGENT_PATH = "${env:ProgramFiles}\JumpCloud"
$AGENT_BINARY_NAME = "JumpCloud-agent.exe"
$AGENT_INSTALLER_URL = "https://s3.amazonaws.com/jumpcloud-windows-agent/production/JumpCloudInstaller.exe"
$AGENT_INSTALLER_PATH = "C:\windows\Temp\JumpCloudInstaller.exe"

# JumpCloud Agent Installation Functions
Function AgentIsOnFileSystem()
{
    Test-Path -Path:(${AGENT_PATH} + '/' + ${AGENT_BINARY_NAME})
}
Function InstallAgent()
{
    $params = ("${AGENT_INSTALLER_PATH}", "-k ${JumpCloudConnectKey}", "/VERYSILENT", "/NORESTART", "/NOCLOSEAPPLICATIONS", "/NORESTARTAPPLICATIONS", "/LOG=$env:TEMP\jcUpdate.log")
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
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $WebClient = New-Object -TypeName:('System.Net.WebClient')
    $WebClient.DownloadFile("$Link", "$Path")
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

#Flush DNS Cache Before Install

ipconfig /FlushDNS

# JumpCloud Agent Installation Logic

DownloadAndInstallAgent -msvc2013x64link:($msvc2013x64Link) -TempPath:($TempPath) -msvc2013x64file:($msvc2013x64File) -msvc2013x64install:($msvc2013x64Install) -msvc2013x86link:($msvc2013x86Link) -msvc2013x86file:($msvc2013x86File) -msvc2013x86install:($msvc2013x86Install)