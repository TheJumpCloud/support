#region Functions
#Verify Domain Account Function
Function VerifyAccount
{
    Param (
        [Parameter(Mandatory = $true)][System.String]$userName, [System.String]$domain = $null
    )
    $idrefUser = $null
    $strUsername = $userName
    If ($domain)
    {
        $strUsername += [String]("@" + $domain)
    }
    Try
    {
        $idrefUser = ([System.Security.Principal.NTAccount]($strUsername)).Translate([System.Security.Principal.SecurityIdentifier]) 
    }
    Catch [System.Security.Principal.IdentityNotMappedException]
    {
        $idrefUser = $null
    }
    If ($idrefUser)
    {
        Return $true
    }
    Else
    {
        Return $false
    }
}
#Logging function
<#
  .Synopsis
     Write-Log writes a message to a specified log file with the current time stamp.
  .DESCRIPTION
     The Write-Log function is designed to add logging capability to other scripts.
     In addition to writing output and/or verbose you can write to a log file for
     later debugging.
  .NOTES
     Created by: Jason Wasser @wasserja
     Modified: 11/24/2015 09:30:19 AM
  .PARAMETER Message
     Message is the content that you wish to add to the log file.
  .PARAMETER Path
     The path to the log file to which you would like to write. By default the function will
     create the path and file if it does not exist.
  .PARAMETER Level
     Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational)
  .EXAMPLE
     Write-Log -Message 'Log message'
     Writes the message to c:\Logs\PowerShellLog.log.
  .EXAMPLE
     Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
     Writes the content to the specified log file and creates the path and file specified.
  .EXAMPLE
     Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
     Writes the message to the specified log file as an error message, and writes the message to the error pipeline.
  .LINK
     https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0
  #>
Function Write-Log
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][Alias("LogContent")][string]$Message
        , [Parameter(Mandatory = $false)][Alias('LogPath')][string]$Path = 'C:\Windows\Temp\jcAdmu.log'
        , [Parameter(Mandatory = $false)][ValidateSet("Error", "Warn", "Info")][string]$Level = "Info"
    )
    Begin
    {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process
    {
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        If (!(Test-Path $Path))
        {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
        }
        Else
        {
            # Nothing to see here yet.
        }
        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # Write message to error, warning, or verbose pipeline and specify $LevelText
        Switch ($Level)
        {
            'Error'
            {
                Write-Error $Message
                $LevelText = 'ERROR:'
            }
            'Warn'
            {
                Write-Warning $Message
                $LevelText = 'WARNING:'
            }
            'Info'
            {
                Write-Verbose $Message
                $LevelText = 'INFO:'
            }
        }
        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End
    {
    }
}
Function Remove-ItemIfExists
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][String[]]$Path
        , [Switch]$Recurse
    )
    Process
    {
        Try
        {
            If (Test-Path -Path:($Path))
            {
                Remove-Item -Path:($Path) -Recurse:($Recurse)
            }
        }
        Catch
        {
            Write-Log -Message ('Removal Of Temp Files & Folders Failed') -Level Warn
        }
    }
}
#Download $Link to $Path
Function DownloadLink($Link, $Path)
{

    $WebClient = New-Object -TypeName:('System.Net.WebClient')
    $Global:IsDownloaded = $false
    $SplatArgs = @{ InputObject = $WebClient
        EventName               = 'DownloadFileCompleted'
        Action                  = {$Global:IsDownloaded = $true; }
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
# Add localuser to group
Function Add-LocalUser
{
    Param(
        [String[]]$computer
        , [String[]]$group
        , [String[]]$localusername
    )
    ([ADSI]"WinNT://$computer/$group,group").psbase.Invoke("Add", ([ADSI]"WinNT://$computer/$localusername").path)
}
#Check if program is on system
function Check_Program_Installed($programName) {
    $installed = $null
    $installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -match $programName})
    $installed32 = (Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -match $programName})
    if (($null -ne $installed) -or ($null -ne $installed32)) {
      return $true
    }
    else {
      return $false
    }
  }
#Check reg for program uninstallstring and silently uninstall

function Uninstall_Program($programName) {
  $Ver = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
      Get-ItemProperty |
          Where-Object {$_.DisplayName -match $programName } |
              Select-Object -Property DisplayName, UninstallString
  
     ForEach ($ver in $Ver) {
        If ($ver.UninstallString -and $ver.DisplayName -match 'Jumpcloud') {
            $uninst = $ver.UninstallString
            & cmd /C $uninst /Silent
        } If ($ver.UninstallString -and $ver.DisplayName -match 'FileZilla Client 3.45.1') {
            $uninst = $ver.UninstallString
            & cmd /c $uninst /S
        } else{
            $uninst = $ver.UninstallString
            & cmd /c $uninst /q /norestart
        }
    }
  }


#Start process and wait then close after 5mins
Function Start-NewProcess([string]$pfile, [string]$arguments, [int32]$Timeout = 300000)
{
    $p = New-Object System.Diagnostics.Process;
    $p.StartInfo.FileName = $pfile;
    $p.StartInfo.Arguments = $arguments
    [void]$p.Start();
    If (! $p.WaitForExit($Timeout))
    {
        Write-Log -Message "Windows ADK Setup did not complete after 5mins";
        Get-Process | Where-Object {$_.Name -like "adksetup*"} | Stop-Process
    }
}
# Validation
Function Test-IsNotEmpty ([System.String] $field)
{
    If (([System.String]::IsNullOrEmpty($field)))
    {
        Return $true
    }
    Else
    {
        Return $false
    }
}
Function Test-Is40chars ([System.String] $field)
{
    If ($field.Length -eq 40)
    {
        Return $true
    }
    Else
    {
        Return $false
    }
}
Function Test-HasNoSpaces ([System.String] $field)
{
    If ($field -like "* *")
    {
        Return $false
    }
    Else
    {
        Return $true
    }
}

Function DownloadAndInstallAgent(
    [System.String]$msvc2013x64Link
    , [System.String]$msvc2013Path
    , [System.String]$msvc2013x64File
    , [System.String]$msvc2013x64Install
    , [System.String]$msvc2013x86Link
    , [System.String]$msvc2013x86File
    , [System.String]$msvc2013x86Install
)
{
    If (!(Check_Program_Installed("Microsoft Visual C\+\+ 2013 x64")))
    {
        Write-Log -Message:('Downloading & Installing JCAgent prereq Visual C++ 2013 x64')
        DownloadLink -Link:($msvc2013x64Link) -Path:($msvc2013Path + $msvc2013x64File)
        Invoke-Expression -Command:($msvc2013x64Install)
        Write-Log -Message:('JCAgent prereq installed')
    }
    If (!(Check_Program_Installed("Microsoft Visual C\+\+ 2013 x86")))
    {
        Write-Log -Message:('Downloading & Installing JCAgent prereq Visual C++ 2013 x86')
        DownloadLink -Link:($msvc2013x86Link) -Path:($msvc2013Path + $msvc2013x86File)
        Invoke-Expression -Command:($msvc2013x86Install)
        Write-Log -Message:('JCAgent prereq installed')
    }
    If (!(AgentIsOnFileSystem))
    {
        Start-Sleep -s 20
        Write-Log -Message:('Downloading JCAgent Installer')
        #Download Installer
        DownloadAgentInstaller
        Write-Log -Message:('JumpCloud Agent Download Complete')
        Write-Log -Message:('Running JCAgent Installer')
        #Run Installer
        InstallAgent
        Write-Log -Message:('JumpCloud Agent Installer Completed')
    }
    If (Check_Program_Installed("Microsoft Visual C\+\+ 2013 x64") -and Check_Program_Installed("Microsoft Visual C\+\+ 2013 x86") -and AgentIsOnFileSystem)
    {
        Return $true
    }
    Else
    {
        Return $false
    }
}

Add-Type -MemberDefinition @"
[DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern uint NetApiBufferFree(IntPtr Buffer);
[DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern int NetGetJoinInformation(
  string server,
  out IntPtr NameBuffer,
  out int BufferType);
"@ -Namespace Win32Api -Name NetApi32

function GetNetBiosName {
  $pNameBuffer = [IntPtr]::Zero
  $joinStatus = 0
  $apiResult = [Win32Api.NetApi32]::NetGetJoinInformation(
    $null, # lpServer
    [Ref] $pNameBuffer, # lpNameBuffer
    [Ref] $joinStatus    # BufferType
  )
  if ( $apiResult -eq 0 ) {
    [Runtime.InteropServices.Marshal]::PtrToStringAuto($pNameBuffer)
    [Void] [Win32Api.NetApi32]::NetApiBufferFree($pNameBuffer)
  }
}

function ConvertSID {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $Sid
  )
  process
  {
    (New-Object System.Security.Principal.SecurityIdentifier($Sid)).Translate( [System.Security.Principal.NTAccount]).Value
  }
}

#endregion Functions

#region Agent Install Helper Functions
Function AgentIsOnFileSystem()
{
    Test-Path -Path:(${AGENT_PATH} + '/' + ${AGENT_BINARY_NAME})
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
Function ForceRebootComputerWithDelay
{
    Param(
        [int]$TimeOut = 10
    )
    $continue = $true

    while ($continue)
    {
        If ([console]::KeyAvailable)
        {
            Write-Host "Restart Canceled by key press"
            Exit;
        }
        Else
        {
            Write-Host "Press any key to cancel... restarting in $TimeOut" -NoNewLine
            Start-Sleep -Seconds 1
            $TimeOut = $TimeOut - 1
            Clear-Host
            If ($TimeOut -eq 0)
            {
                $continue = $false
                $Restart = $true
            }
        }
    }
    If ($Restart -eq $True)
    {
        Write-Host "Restarting Computer..."
        Restart-Computer -ComputerName $env:COMPUTERNAME -Force
    }
}
#endregion Agent Install Helper Functions


#region config xml
$usmtconfig = [xml] @"
<Configuration>
  <Applications/>
  <Documents/>
  <WindowsComponents>
    <component displayname="microsoft-windows-identity-foundation-migration" migrate="yes" ID="microsoft-windows-identity-foundation-migration"/>
    <component displayname="microsoft-windows-identityserver-migration" migrate="yes" ID="microsoft-windows-identityserver-migration"/>
    <component displayname="Microsoft-Windows-Profsvc" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-profsvc/microsoft-windows-profsvc/settings"/>
    <component displayname="TSPortalWebPart" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/tsportalwebpart/tsportalwebpart/settings"/>
    <component displayname="Microsoft-Windows-ServerManager-Shell" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-servermanager-shell/microsoft-windows-servermanager-shell/settings"/>
    <component displayname="Microsoft-Windows-WCFCoreComp" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-wcfcorecomp/microsoft-windows-wcfcorecomp/settings"/>
    <component displayname="WCF-NonHTTP-Activation" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/wcf-nonhttp-activation/wcf-nonhttp-activation/settings"/>
    <component displayname="Microsoft-Windows-NETFX35CDFComp" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-netfx35cdfcomp/microsoft-windows-netfx35cdfcomp/settings"/>
    <component displayname="WCF-HTTP-Activation" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/wcf-http-activation/wcf-http-activation/settings"/>
    <component displayname="Microsoft-Windows-AdvancedTaskManager" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-advancedtaskmanager/microsoft-windows-advancedtaskmanager/settings"/>
    <component displayname="Microsoft-Windows-RasmanService" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasmanservice/microsoft-windows-rasmanservice/settings"/>
    <component displayname="Microsoft-Windows-EnterpriseClientSync-Host" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-enterpriseclientsync-host/microsoft-windows-enterpriseclientsync-host/settings"/>
    <component displayname="Microsoft-Windows-International-TimeZones" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-international-timezones/microsoft-windows-international-timezones/settings"/>
    <component displayname="Microsoft-Windows-Application-Experience-Program-Compatibility-Assistant" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-application-experience-program-compatibility-assistant/microsoft-windows-application-experience-program-compatibility-assistant/settings"/>
    <component displayname="Microsoft-Windows-ReFS" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-refs/microsoft-windows-refs/settings"/>
    <component displayname="WindowsSearchEngine" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/windowssearchengine/windowssearchengine/settings"/>
    <component displayname="Microsoft-Windows-MSMPEG2VDEC" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-msmpeg2vdec/microsoft-windows-msmpeg2vdec/settings"/>
    <component displayname="Microsoft-Windows-shmig" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-shmig/microsoft-windows-shmig/settings"/>
    <component displayname="Microsoft-Windows-Runtime-Windows-Media" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-runtime-windows-media/microsoft-windows-runtime-windows-media/settings"/>
    <component displayname="Microsoft-Windows-Audio-AudioCore" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-audio-audiocore/microsoft-windows-audio-audiocore/settings"/>
    <component displayname="Microsoft-Windows-MFMPEG2SrcSnk" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-mfmpeg2srcsnk/microsoft-windows-mfmpeg2srcsnk/settings"/>
    <component displayname="Microsoft-Windows-DeliveryOptimization" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-deliveryoptimization/microsoft-windows-deliveryoptimization/settings"/>
    <component displayname="Microsoft-Windows-Security-CloudAP" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-security-cloudap/microsoft-windows-security-cloudap/settings"/>
    <component displayname="programs" migrate="yes" ID="programs">
      <component displayname="programs\media_center_settings" migrate="yes" ID="programs\media_center_settings">
        <component displayname="Microsoft-Windows-Video-TVVideoControl" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-video-tvvideocontrol/microsoft-windows-video-tvvideocontrol/settings"/>
      </component>
    </component>
    <component displayname="Windows-ID-Connected-Account-Provider-WLIDSvc" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/windows-id-connected-account-provider-wlidsvc/windows-id-connected-account-provider-wlidsvc/settings"/>
    <component displayname="Microsoft-Windows-notepad" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-notepad/microsoft-windows-notepad/settings"/>
    <component displayname="Microsoft-Windows-DesktopWindowManager-uDWM" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-desktopwindowmanager-udwm/microsoft-windows-desktopwindowmanager-udwm/settings"/>
    <component displayname="Microsoft-Windows-DataIntegrityScan" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-dataintegrityscan/microsoft-windows-dataintegrityscan/settings"/>
    <component displayname="Microsoft-Windows-UDFS" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-udfs/microsoft-windows-udfs/settings"/>
    <component displayname="Microsoft-Windows-mmsys" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-mmsys/microsoft-windows-mmsys/settings"/>
    <component displayname="Microsoft-Windows-Audio-VolumeControl" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-audio-volumecontrol/microsoft-windows-audio-volumecontrol/settings"/>
    <component displayname="Microsoft-Windows-PeerDist-Server-Migration" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-peerdist-server-migration/microsoft-windows-peerdist-server-migration/settings"/>
    <component displayname="Microsoft-Windows-MFSrcSnk" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-mfsrcsnk/microsoft-windows-mfsrcsnk/settings"/>
    <component displayname="Microsoft-Windows-WMPNSS-Service" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-wmpnss-service/microsoft-windows-wmpnss-service/settings"/>
    <component displayname="Microsoft-Windows-OfflineFiles-Core" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-offlinefiles-core/microsoft-windows-offlinefiles-core/settings"/>
    <component displayname="Microsoft-Windows-WinMDE" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-winmde/microsoft-windows-winmde/settings"/>
    <component displayname="Microsoft-Windows-SystemMaintenanceService" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-systemmaintenanceservice/microsoft-windows-systemmaintenanceservice/settings"/>
    <component displayname="Microsoft-Windows-fontext" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-fontext/microsoft-windows-fontext/settings"/>
    <component displayname="Microsoft-Windows-ScriptedDiagnosticsClient-Scheduled" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-scripteddiagnosticsclient-scheduled/microsoft-windows-scripteddiagnosticsclient-scheduled/settings"/>
    <component displayname="Microsoft-Windows-Extensible-Authentication-Protocol-Host-Service" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-extensible-authentication-protocol-host-service/microsoft-windows-extensible-authentication-protocol-host-service/settings"/>
    <component displayname="Microsoft-Windows-Client-SQM-Consolidator" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-client-sqm-consolidator/microsoft-windows-client-sqm-consolidator/settings"/>
    <component displayname="appearance_and_display" migrate="yes" ID="appearance_and_display">
      <component displayname="appearance_and_display\user_tile" migrate="yes" ID="appearance_and_display\user_tile">
        <component displayname="Microsoft-Windows-WindowsUIImmersive" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-windowsuiimmersive/microsoft-windows-windowsuiimmersive/settings"/>
      </component>
      <component displayname="appearance_and_display\taskbar_and_start_menu" migrate="yes" ID="appearance_and_display\taskbar_and_start_menu">
        <component displayname="Microsoft-Windows-explorer" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-explorer/microsoft-windows-explorer/settings"/>
        <component displayname="Microsoft-Windows-stobject" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-stobject/microsoft-windows-stobject/settings"/>
      </component>
      <component displayname="appearance_and_display\personalized_settings" migrate="yes" ID="appearance_and_display\personalized_settings">
        <component displayname="Microsoft-Windows-shell32" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-shell32/microsoft-windows-shell32/settings"/>
        <component displayname="Microsoft-Windows-CommandPrompt" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-commandprompt/microsoft-windows-commandprompt/settings"/>
        <component displayname="Microsoft-Windows-themeui" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-themeui/microsoft-windows-themeui/settings"/>
        <component displayname="Microsoft-Windows-uxtheme" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-uxtheme/microsoft-windows-uxtheme/settings"/>
      </component>
    </component>
    <component displayname="Microsoft-Windows-Security-ExchangeActiveSyncProvisioning" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-security-exchangeactivesyncprovisioning/microsoft-windows-security-exchangeactivesyncprovisioning/settings"/>
    <component displayname="Microsoft-Windows-DafDockingProvider" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-dafdockingprovider/microsoft-windows-dafdockingprovider/settings"/>
    <component displayname="Microsoft-Windows-Media-Import-API" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-media-import-api/microsoft-windows-media-import-api/settings"/>
    <component displayname="accessibility" migrate="yes" ID="accessibility">
      <component displayname="accessibility\accessibility_settings" migrate="yes" ID="accessibility\accessibility_settings">
        <component displayname="Microsoft-Windows-accessibilitycpl" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-accessibilitycpl/microsoft-windows-accessibilitycpl/settings"/>
      </component>
    </component>
    <component displayname="Microsoft-Windows-Shell-Sounds" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-shell-sounds/microsoft-windows-shell-sounds/settings"/>
    <component displayname="Microsoft-Windows-SettingSync" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-settingsync/microsoft-windows-settingsync/settings"/>
    <component displayname="Microsoft-Windows-X509CertificateEnrollment" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-x509certificateenrollment/microsoft-windows-x509certificateenrollment/settings"/>
    <component displayname="Microsoft-Windows-DisplayConfigSettings" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-displayconfigsettings/microsoft-windows-displayconfigsettings/settings"/>
    <component displayname="Microsoft-Windows-Security-IdentityStore" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-security-identitystore/microsoft-windows-security-identitystore/settings"/>
    <component displayname="performance_and_maintenance" migrate="yes" ID="performance_and_maintenance">
      <component displayname="performance_and_maintenance\error_reporting" migrate="yes" ID="performance_and_maintenance\error_reporting">
        <component displayname="Microsoft-Windows-ErrorReportingCore" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-errorreportingcore/microsoft-windows-errorreportingcore/settings"/>
      </component>
      <component displayname="performance_and_maintenance\diagnostics" migrate="yes" ID="performance_and_maintenance\diagnostics">
        <component displayname="Microsoft-Windows-Feedback-Service" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-feedback-service/microsoft-windows-feedback-service/settings"/>
        <component displayname="Microsoft-Windows-RemoteAssistance-Exe" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-remoteassistance-exe/microsoft-windows-remoteassistance-exe/settings"/>
      </component>
    </component>
    <component displayname="network_and_internet" migrate="yes" ID="network_and_internet">
      <component displayname="network_and_internet\internet_options" migrate="yes" ID="network_and_internet\internet_options">
        <component displayname="Microsoft-Windows-ieframe" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-ieframe/microsoft-windows-ieframe/settings"/>
        <component displayname="Microsoft-Windows-IE-Feeds-Platform" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-ie-feeds-platform/microsoft-windows-ie-feeds-platform/settings"/>
        <component displayname="Microsoft-Windows-IE-InternetExplorer" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-ie-internetexplorer/microsoft-windows-ie-internetexplorer/settings"/>
      </component>
      <component displayname="network_and_internet\networking_connections" migrate="yes" ID="network_and_internet\networking_connections">
        <component displayname="Microsoft-Windows-MPR" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-mpr/microsoft-windows-mpr/settings"/>
        <component displayname="Microsoft-Windows-Native-80211" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-native-80211/microsoft-windows-native-80211/settings"/>
        <component displayname="Microsoft-Windows-RasApi" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasapi/microsoft-windows-rasapi/settings"/>
        <component displayname="Microsoft-Windows-Wlansvc" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-wlansvc/microsoft-windows-wlansvc/settings"/>
        <component displayname="Microsoft-Windows-VWiFi" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-vwifi/microsoft-windows-vwifi/settings"/>
        <component displayname="Microsoft-Windows-Dot3svc" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-dot3svc/microsoft-windows-dot3svc/settings"/>
        <component displayname="Microsoft-Windows-RasConnectionManager" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasconnectionmanager/microsoft-windows-rasconnectionmanager/settings"/>
      </component>
    </component>
    <component displayname="Microsoft-Windows-sysdm" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-sysdm/microsoft-windows-sysdm/settings"/>
    <component displayname="sound_and_speech_recognition" migrate="yes" ID="sound_and_speech_recognition">
      <component displayname="sound_and_speech_recognition\speech_recognition" migrate="yes" ID="sound_and_speech_recognition\speech_recognition">
        <component displayname="Microsoft-Windows-SpeechCommon-OneCore" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-speechcommon-onecore/microsoft-windows-speechcommon-onecore/settings"/>
        <component displayname="Microsoft-Windows-SpeechCommon" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-speechcommon/microsoft-windows-speechcommon/settings"/>
      </component>
    </component>
    <component displayname="Security-Malware-Windows-Defender" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/security-malware-windows-defender/security-malware-windows-defender/settings"/>
    <component displayname="Microsoft-Windows-RasBase-RasSstp" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasbase-rassstp/microsoft-windows-rasbase-rassstp/settings"/>
    <component displayname="Microsoft-Windows-Desktop_Technologies-Text_Input_Services-IME-EAShared-Migration" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-desktop_technologies-text_input_services-ime-eashared-migration/microsoft-windows-desktop_technologies-text_input_services-ime-eashared-migration/settings"/>
    <component displayname="security" migrate="yes" ID="security">
      <component displayname="Microsoft-Windows-Rights-Management-Client-v2-Core" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rights-management-client-v2-core/microsoft-windows-rights-management-client-v2-core/settings"/>
      <component displayname="Microsoft-Windows-Rights-Management-Client-v1-API" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rights-management-client-v1-api/microsoft-windows-rights-management-client-v1-api/settings"/>
      <component displayname="Microsoft-Windows-Rights-Management-Client-Office-Protectors" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rights-management-client-office-protectors/microsoft-windows-rights-management-client-office-protectors/settings"/>
      <component displayname="security\security_options" migrate="yes" ID="security\security_options">
        <component displayname="Microsoft-Windows-Credential-Manager" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-credential-manager/microsoft-windows-credential-manager/settings"/>
        <component displayname="Microsoft-Windows-Security-Vault" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-security-vault/microsoft-windows-security-vault/settings"/>
      </component>
    </component>
    <component displayname="tablet_pc_settings" migrate="yes" ID="tablet_pc_settings">
      <component displayname="tablet_pc_settings\tablet_pc_input_panel" migrate="yes" ID="tablet_pc_settings\tablet_pc_input_panel">
        <component displayname="Microsoft-Windows-TabletPC-InputPanel" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-tabletpc-inputpanel/microsoft-windows-tabletpc-inputpanel/settings"/>
      </component>
      <component displayname="tablet_pc_settings\tablet_pc_general_options" migrate="yes" ID="tablet_pc_settings\tablet_pc_general_options">
        <component displayname="Microsoft-Windows-TabletPC-Platform-Input-Core" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-tabletpc-platform-input-core/microsoft-windows-tabletpc-platform-input-core/settings"/>
      </component>
      <component displayname="tablet_pc_settings\handwriting_recognition" migrate="yes" ID="tablet_pc_settings\handwriting_recognition">
        <component displayname="Microsoft-Windows-TabletPC-CoreInkRecognition" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-tabletpc-coreinkrecognition/microsoft-windows-tabletpc-coreinkrecognition/settings"/>
        <component displayname="Microsoft-Windows-TabletPC-InputPersonalization" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-tabletpc-inputpersonalization/microsoft-windows-tabletpc-inputpersonalization/settings"/>
      </component>
    </component>
    <component displayname="date_time_language_and_region" migrate="yes" ID="date_time_language_and_region">
      <component displayname="date_time_language_and_region\regional_language_options" migrate="yes" ID="date_time_language_and_region\regional_language_options">
        <component displayname="Microsoft-Windows-IME-Traditional-Chinese-Core" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-ime-traditional-chinese-core/microsoft-windows-ime-traditional-chinese-core/settings"/>
        <component displayname="Microsoft-Windows-MUI-Settings" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-mui-settings/microsoft-windows-mui-settings/settings"/>
        <component displayname="Microsoft-Windows-TableDrivenTextService-Migration" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-tabledriventextservice-migration/microsoft-windows-tabledriventextservice-migration/settings"/>
        <component displayname="Microsoft-Windows-International-Core" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-international-core/microsoft-windows-international-core/settings"/>
        <component displayname="Microsoft-Windows-TextServicesFramework-Migration" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-textservicesframework-migration/microsoft-windows-textservicesframework-migration/settings"/>
      </component>
    </component>
    <component displayname="Microsoft-Windows-eudcedit" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-eudcedit/microsoft-windows-eudcedit/settings"/>
    <component displayname="Microsoft-Windows-DiagCpl" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-diagcpl/microsoft-windows-diagcpl/settings"/>
    <component displayname="Microsoft-Windows-Feedback-CourtesyEngine" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-feedback-courtesyengine/microsoft-windows-feedback-courtesyengine/settings"/>
    <component displayname="additional_options" migrate="yes" ID="additional_options">
      <component displayname="additional_options\help_settings" migrate="yes" ID="additional_options\help_settings">
        <component displayname="Microsoft-Windows-Help-Client" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-help-client/microsoft-windows-help-client/settings"/>
      </component>
      <component displayname="additional_options\windows_core_settings" migrate="yes" ID="additional_options\windows_core_settings">
        <component displayname="Microsoft-Windows-RasMprDdm" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasmprddm/microsoft-windows-rasmprddm/settings"/>
        <component displayname="Microsoft-Windows-RPC-Local" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rpc-local/microsoft-windows-rpc-local/settings"/>
        <component displayname="Microsoft-Windows-COM-Base" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-com-base/microsoft-windows-com-base/settings"/>
        <component displayname="Microsoft-Windows-UPnPSSDP" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-upnpssdp/microsoft-windows-upnpssdp/settings"/>
        <component displayname="Microsoft-Windows-Web-Services-for-Management-Core" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-web-services-for-management-core/microsoft-windows-web-services-for-management-core/settings"/>
        <component displayname="Microsoft-Windows-Win32k-Settings" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-win32k-settings/microsoft-windows-win32k-settings/settings"/>
        <component displayname="Microsoft-Windows-Rasppp-NonEap" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasppp-noneap/microsoft-windows-rasppp-noneap/settings"/>
        <component displayname="Microsoft-Windows-TerminalServices-RemoteConnectionManager" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-terminalservices-remoteconnectionmanager/microsoft-windows-terminalservices-remoteconnectionmanager/settings"/>
        <component displayname="Microsoft-Windows-Microsoft-Data-Access-Components-(MDAC)-ODBC-DriverManager-Dll" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-microsoft-data-access-components-(mdac)-odbc-drivermanager-dll/microsoft-windows-microsoft-data-access-components-(mdac)-odbc-drivermanager-dll/settings"/>
        <component displayname="Microsoft-Windows-feclient" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-feclient/microsoft-windows-feclient/settings"/>
        <component displayname="Microsoft-Windows-ICM-Profiles" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-icm-profiles/microsoft-windows-icm-profiles/settings"/>
        <component displayname="Microsoft-Windows-dpapi-keys" migrate="no" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-dpapi-keys/microsoft-windows-dpapi-keys/settings"/>
        <component displayname="Microsoft-Windows-RPC-HTTP" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rpc-http/microsoft-windows-rpc-http/settings"/>
        <component displayname="Microsoft-Windows-UPnPControlPoint" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-upnpcontrolpoint/microsoft-windows-upnpcontrolpoint/settings"/>
        <component displayname="Microsoft-Windows-Crypto-keys" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-crypto-keys/microsoft-windows-crypto-keys/settings"/>
        <component displayname="Microsoft-Windows-RasBase" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasbase/microsoft-windows-rasbase/settings"/>
        <component displayname="Microsoft-Windows-CAPI2-certs" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-capi2-certs/microsoft-windows-capi2-certs/settings"/>
        <component displayname="Microsoft-Windows-UPnPDeviceHost" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-upnpdevicehost/microsoft-windows-upnpdevicehost/settings"/>
        <component displayname="Microsoft-Windows-SQM-Consolidator-Base" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-sqm-consolidator-base/microsoft-windows-sqm-consolidator-base/settings"/>
        <component displayname="Microsoft-Windows-COM-DTC-Setup" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-com-dtc-setup/microsoft-windows-com-dtc-setup/settings"/>
        <component displayname="Microsoft-Windows-Rasppp-Eap" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rasppp-eap/microsoft-windows-rasppp-eap/settings"/>
        <component displayname="Microsoft-Windows-TerminalServices-Drivers" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-terminalservices-drivers/microsoft-windows-terminalservices-drivers/settings"/>
        <component displayname="Microsoft-Windows-RPC-Remote" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-rpc-remote/microsoft-windows-rpc-remote/settings"/>
        <component displayname="Microsoft-Windows-SQMApi" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-sqmapi/microsoft-windows-sqmapi/settings"/>
      </component>
    </component>
    <component displayname="communications_and_sync" migrate="yes" ID="communications_and_sync">
      <component displayname="communications_and_sync\windows_mail" migrate="yes" ID="communications_and_sync\windows_mail">
        <component displayname="Microsoft-Windows-WAB" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-wab/microsoft-windows-wab/settings"/>
      </component>
      <component displayname="communications_and_sync\fax" migrate="yes" ID="communications_and_sync\fax">
        <component displayname="Microsoft-Windows-Fax-Status-Monitor" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-fax-status-monitor/microsoft-windows-fax-status-monitor/settings"/>
        <component displayname="Microsoft-Windows-Fax-Client-Applications" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-fax-client-applications/microsoft-windows-fax-client-applications/settings"/>
        <component displayname="Microsoft-Windows-Fax-Service" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-fax-service/microsoft-windows-fax-service/settings"/>
      </component>
    </component>
    <component displayname="hardware" migrate="yes" ID="hardware">
      <component displayname="hardware\phone_and_modem" migrate="yes" ID="hardware\phone_and_modem">
        <component displayname="Microsoft-Windows-TapiSetup" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-tapisetup/microsoft-windows-tapisetup/settings"/>
      </component>
      <component displayname="hardware\printers_and_faxes" migrate="yes" ID="hardware\printers_and_faxes">
        <component displayname="Microsoft-Windows-Printing-Spooler-Core-Localspl" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-printing-spooler-core-localspl/microsoft-windows-printing-spooler-core-localspl/settings"/>
        <component displayname="Microsoft-Windows-Printing-LocalPrinting" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-printing-localprinting/microsoft-windows-printing-localprinting/settings"/>
        <component displayname="Microsoft-Windows-Printing-Spooler-Networkclient" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-printing-spooler-networkclient/microsoft-windows-printing-spooler-networkclient/settings"/>
      </component>
    </component>
    <component displayname="snippingtool_settings" migrate="yes" ID="snippingtool_settings">
      <component displayname="Microsoft-Windows-SnippingTool-App" migrate="yes" ID="http://www.microsoft.com/migration/1.0/migxmlext/cmi/microsoft-windows-snippingtool-app/microsoft-windows-snippingtool-app/settings"/>
    </component>
  </WindowsComponents>
  <Policies>
    <ErrorControl>
      <!--   Example:

          <fileError>
            <nonFatal errorCode="33">* [*]</nonFatal>
            <fatal errorCode="any">C:\Users\* [*]</fatal>
          </fileError>
          <registryError>
            <nonFatal errorCode="5">* [*]</nonFatal>
          </registryError>
      -->
    </ErrorControl>
    <HardLinkStoreControl>
      <!--   Example:

          <fileLocked>
            <createHardLink>c:\Users\* [*]</createHardLink>
            <errorHardLink>C:\* [*]</errorHardLink>
          </fileLocked>
      -->
    </HardLinkStoreControl>
  </Policies>
  <ProfileControl>
    <!--   Example (local group mapping):

          <localGroups>
            <mappings>
              <changeGroup from="Administrators" to="Users" appliesTo="MigratedUsers">
                <include>
                  <pattern>DomainName1\Username</pattern>
                </include>
                <exclude>
                  <pattern>DomainName2\Username</pattern>
                </exclude>
              </changeGroup>
            </mappings>
          </localGroups>
          
      -->
    <!--   Example (domain and user mapping):

          <domains>
            <domain from="Domain1" to="Domain2"/>
          </domains>
          
          <users>
            <user from="Domain1\User1" to="Domain2\User2"/>
          </users>
          
      -->
  </ProfileControl>
</Configuration>
"@
#endregion config xml

#region migapp xml
$usmtmigapp = [xml] @"
<?xml version="1.0" encoding="UTF-8"?>
<migration urlid="http://www.microsoft.com/migration/1.0/migxmlext/migapp">
  <library prefix="MigSysHelper">MigSys.dll</library>
  <_locDefinition>
    <_locDefault _loc="locNone" />
    <_locTag _loc="locData">displayName</_locTag>
  </_locDefinition>
  <namedElements>
    <!-- Global -->
    <environment name="GlobalEnvX64">
      <conditions>
        <condition>MigXmlHelper.IsNative64Bit()</condition>
      </conditions>
      <variable name="HklmWowSoftware">
        <text>HKLM\SOFTWARE\Wow6432Node</text>
      </variable>
      <variable name="ProgramFiles32bit">
        <text>%ProgramFiles(x86)%</text>
      </variable>
      <variable name="CommonProgramFiles32bit">
        <text>%CommonProgramFiles(x86)%</text>
      </variable>
    </environment>
    <environment name="GlobalEnv">
      <conditions>
        <condition negation="Yes">MigXmlHelper.IsNative64Bit()</condition>
      </conditions>
      <variable name="HklmWowSoftware">
        <text>HKLM\Software</text>
      </variable>
      <variable name="ProgramFiles32bit">
        <text>%ProgramFiles%</text>
      </variable>
      <variable name="CommonProgramFiles32bit">
        <text>%CommonProgramFiles%</text>
      </variable>
    </environment>
    <!-- Global USER -->
    <environment context="User" name="GlobalEnvX64User">
      <conditions>
        <condition>MigXmlHelper.IsNative64Bit()</condition>
      </conditions>
      <variable name="VirtualStore_ProgramFiles32bit">
        <text>%CSIDL_VIRTUALSTORE_PROGRAMFILES(X86)%</text>
      </variable>
      <variable name="VirtualStore_CommonProgramFiles32bit">
        <text>%CSIDL_VIRTUALSTORE_COMMONPROGRAMFILES(X86)%</text>
      </variable>
    </environment>
    <environment context="User" name="GlobalEnvUser">
      <conditions>
        <condition negation="Yes">MigXmlHelper.IsNative64Bit()</condition>
      </conditions>
      <variable name="VirtualStore_ProgramFiles32bit">
        <text>%CSIDL_VIRTUALSTORE_PROGRAMFILES%</text>
      </variable>
      <variable name="VirtualStore_CommonProgramFiles32bit">
        <text>%CSIDL_VIRTUALSTORE_COMMONPROGRAMFILES%</text>
      </variable>
    </environment>
    <!-- For Windows Live Mail -->
    <environment name="WLMailNotLaunchedEnv">
      <conditions>
        <condition negation="Yes">MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live Mail [First Signin Done]")</condition>
      </conditions>
      <variable name="WLMailDataPath">
        <text>%WLMailStoreRoot%</text>
      </variable>
      <variable name="WLMailRegistryPath">
        <text>HKCU\Software\Microsoft\Windows Live Mail</text>
      </variable>
    </environment>
    <environment name="WLMailLaunchedEnv">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live Mail [First Signin Done]")</condition>
      </conditions>
      <variable name="WLMailDataPath">
        <text>%CSIDL_MYDOCUMENTS%\Migrated Mail</text>
      </variable>
      <variable name="WLMailRegistryPath">
        <text>HKCU\Software\Microsoft\Windows Live Mail\Migrated Keys</text>
      </variable>
    </environment>
    <!-- For Adobe Creative Suite-->
    <detects name="AdobePhotoshopCS">
      <detect>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Adobe\Photoshop\8.0")</condition>
      </detect>
      <detect>
        <condition>MigXmlHelper.DoesFileVersionMatch("%PhotoshopSuite8Path%\Photoshop.exe","FileVersion","8.*")</condition>
      </detect>
    </detects>
    <detects name="AdobeImageReadyCS">
      <detect>
        <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_APPDATA%\Adobe\ImageReady\CS\Settings\Adobe ImageReady CS Prefs")</condition>
      </detect>
      <detect>
        <condition>MigXmlHelper.DoesFileVersionMatch("%PhotoshopSuite8Path%\ImageReady.exe","FileVersion","8.*")</condition>
        <condition>MigXmlHelper.DoesFileVersionMatch("%PhotoshopSuite8Path%\ImageReady.exe","FileVersion","* 8.*")</condition>
      </detect>
    </detects>
    <!-- Windows Live paths -->
    <environment name="WLEnv">
      <variable name="WLMailInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows Live Mail [InstallRoot]")</script>
      </variable>
      <variable name="WLMailStoreRoot">
        <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Microsoft\Windows Live Mail [Store Root]")</script>
      </variable>
      <variable name="WLMessengerInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows Live\Messenger [InstallationDirectory]")</script>
      </variable>
      <variable name="WLPhotoGalleryInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows Live\Photo Gallery\WLXGPUPipeline [InstallLocation]")</script>
      </variable>
      <variable name="WLWriterInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows Live\Writer [InstallDir]")</script>
      </variable>
    </environment>
    <!-- Office paths -->
    <environment name="COMMONOFFICEENV">
      <variable name="OFFICEINSTALLPATH">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Common\InstallRoot [Path]")</script>
      </variable>
      <variable name="FRONTPAGEEXE">
        <text>%OFFICEINSTALLPATH%\FrontPg.exe</text>
      </variable>
    </environment>
    <!-- Office x86 detects -->
    <detection name="Word">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Word\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Access">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Access\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Excel">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Excel\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="PowerPoint">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\PowerPoint\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Outlook">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Outlook\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Publisher">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Publisher\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="FrontPage">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\FrontPage\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Visio">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Visio [CurrentlyRegisteredVersion]")</condition>
      </conditions>
    </detection>
    <detection name="Visio15">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Visio\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Visio16">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Visio\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Visio17">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Visio\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project2003">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\MS Project")</condition>
      </conditions>
    </detection>
    <detection name="Project2007">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project14">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project15">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project16">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project17">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="OneNote">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\OneNote\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="InfoPath">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\InfoPath\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="SharePointDesigner">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\SharePoint Designer\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Lync15">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Lync\InstallRoot  [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Lync16">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Lync\InstallRoot  [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Lync17">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HklmWowSoftware%\Microsoft\Office\%OFFICEVERSION%\Lync\InstallRoot  [Path]")</condition>
      </conditions>
    </detection>
    <!-- Office x64 detects -->
    <detection name="Word_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Word\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Word_x32_64OS">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\SOFTWARE\Wow6432Node\Microsoft\Office\%OFFICEVERSION%\Word\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Access_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Access\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Excel_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Excel\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="PowerPoint_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\PowerPoint\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Outlook_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Outlook\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Publisher_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Publisher\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Visio_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Visio [CurrentlyRegisteredVersion]")</condition>
      </conditions>
    </detection>
    <detection name="Visio15_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Visio\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Visio16_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Visio\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Visio17_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Visio\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project14_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project15_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project16_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Project17_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Project\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="OneNote_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="InfoPath_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\InfoPath\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="SharePointDesigner_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\SharePoint Designer\InstallRoot [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Lync15_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Lync\InstallRoot  [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Lync16_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Lync\InstallRoot  [Path]")</condition>
      </conditions>
    </detection>
    <detection name="Lync17_x64">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Office\%OFFICEVERSION%\Lync\InstallRoot  [Path]")</condition>
      </conditions>
    </detection>
    <!-- Office SmartTags detects -->
    <detection name="MicrosoftOutlookEmailRecipientsSmartTags">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftListsSmartTags2003">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftListsSmartTags2007">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftListsSmartTags14">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftListsSmartTags15">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftListsSmartTags16">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftListsSmartTags17">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}")</condition>
      </conditions>
    </detection>
    <detection name="MicrosoftPlaceSmartTags">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}")</condition>
      </conditions>
    </detection>
    <!-- Windows Live detections -->
    <detection name="Mail12">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live Mail")</condition>
        <condition>MigXmlHelper.DoesFileVersionMatch("%WLMailInstPath%\wlmail.exe","ProductVersion","12.*")</condition>
      </conditions>
    </detection>
    <detection name="Mail14">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live Mail")</condition>
        <condition>MigXmlHelper.DoesFileVersionMatch("%WLMailInstPath%\wlmail.exe","ProductVersion","14.*")</condition>
      </conditions>
    </detection>
    <detection name="Mail15">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live Mail")</condition>
        <condition>MigXmlHelper.DoesFileVersionMatch("%WLMailInstPath%\wlmail.exe","ProductVersion","15.*")</condition>
      </conditions>
    </detection>
    <detection name="Messenger">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\MSNMessenger")</condition>
        <conditions operation="OR">
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLMessengerInstPath%\msnmsgr.exe","ProductVersion","8.5.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLMessengerInstPath%\msnmsgr.exe","ProductVersion","14.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLMessengerInstPath%\msnmsgr.exe","ProductVersion","15.*")</condition>
        </conditions>
      </conditions>
    </detection>
    <detection name="PhotoGallery">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live\Photo Gallery")</condition>
        <conditions operation="OR">
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLPhotoGalleryInstPath%\WLXPhotoGallery.exe","ProductVersion","12.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLPhotoGalleryInstPath%\WLXPhotoGallery.exe","ProductVersion","14.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLPhotoGalleryInstPath%\WLXPhotoGallery.exe","ProductVersion","15.*")</condition>
        </conditions>
      </conditions>
    </detection>
    <detection name="Writer">
      <conditions>
        <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Microsoft\Windows Live\Writer")</condition>
        <conditions operation="OR">
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLWriterInstPath%\WindowsLiveWriter.exe","ProductVersion","12.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLWriterInstPath%\WindowsLiveWriter.exe","ProductVersion","14.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WLWriterInstPath%\WindowsLiveWriter.exe","ProductVersion","15.*")</condition>
        </conditions>
      </conditions>
    </detection>
    <!-- Office 2003 to Office 2007 Settings Upgrade Rule -->
    <rules name="Office2003to2007SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2003 to Office 2010 x86 Settings Upgrade Rule -->
    <rules name="Office2003to14SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2003 to Office 2010 x64 Settings Upgrade Rule -->
    <rules name="Office2003to14SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2003 to Office 15 x86 Settings Upgrade Rule -->
    <rules name="Office2003to15SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2003 to Office 15 x64 Settings Upgrade Rule -->
    <rules name="Office2003to15SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2003 to Office 16 x86 Settings Upgrade Rule -->
    <rules name="Office2003to16SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2003 to Office 16 x64 Settings Upgrade Rule -->
    <rules name="Office2003to16SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0B000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2007 to Office 2010 x86 Settings Upgrade Rule -->
    <rules name="Office2007to14SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2007 to Office 2010 x64 Settings Upgrade Rule -->
    <rules name="Office2007to14SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2007 to Office 15 x86 Settings Upgrade Rule -->
    <rules name="Office2007to15SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2007 to Office 15 x64 Settings Upgrade Rule -->
    <rules name="Office2007to15SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2007 to Office 16 x86 Settings Upgrade Rule -->
    <rules name="Office2007to16SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2007 to Office 16 x64 Settings Upgrade Rule -->
    <rules name="Office2007to16SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\12.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2010 to Office 15 x86 Settings Upgrade Rule -->
    <rules name="Office14to15SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2010 to Office 15 x64 Settings Upgrade Rule -->
    <rules name="Office14to15SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2010 to Office 16 x86 Settings Upgrade Rule -->
    <rules name="Office14to16SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2010 to Office 16 x64 Settings Upgrade Rule -->
    <rules name="Office14to16SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2010 to Office 2010 x86 Settings Upgrade Rule -->
    <rules name="Office14to14SettingsMigrate" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2010 to Office 2010 x64 Settings Upgrade Rule -->
    <rules name="Office14to14SettingsMigrate_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 15 to Office 15 x86 Settings Upgrade Rule -->
    <rules name="Office15to15SettingsMigrate" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 15 to Office 15 x64 Settings Upgrade Rule -->
    <rules name="Office15to15SettingsMigrate_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 15 to Office 16 x86 Settings Upgrade Rule -->
    <rules name="Office15to16SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 15 to Office 16 x64 Settings Upgrade Rule -->
    <rules name="Office15to16SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 16 to Office 16 x86 Settings Upgrade Rule -->
    <rules name="Office16to16SettingsMigrate" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 16 to Office 16 x64 Settings Upgrade Rule -->
    <rules name="Office16to16SettingsMigrate_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 2010 to Office 17 x86 Settings Upgrade Rule -->
    <rules name="Office14to17SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 2010 to Office 17 x64 Settings Upgrade Rule -->
    <rules name="Office14to17SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\14.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 15 to Office 17 x86 Settings Upgrade Rule -->
    <rules name="Office15to17SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 15 to Office 17 x64 Settings Upgrade Rule -->
    <rules name="Office15to17SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\15.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 16 to Office 17 x86 Settings Upgrade Rule -->
    <rules name="Office16to17SettingsUpgrade" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 16 to Office 17 x64 Settings Upgrade Rule -->
    <rules name="Office16to17SettingsUpgrade_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0C000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\16.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Office 17 to Office 17 x86 Settings Upgrade Rule -->
    <rules name="Office17to17SettingsMigrate" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\17.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\17.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
      <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
        <objectSet>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </locationModify>
    </rules>
    <!-- Office 17 to Office 17 x64 Settings Upgrade Rule -->
    <rules name="Office17to17SettingsMigrate_x64" context="System">
      <include>
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\LanguageResources [SKULanguage]</pattern>
        </objectSet>
      </include>
      <addObjects>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [UpgradeVersion]</location>
          <attributes>DWORD</attributes>
          <bytes>0E000000</bytes>
        </object>
        <object>
          <location type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</location>
          <attributes>DWORD</attributes>
          <bytes>00000000</bytes>
        </object>
      </addObjects>
      <contentModify script="MigSysHelper.ConvertToOfficeLangID('Registry','HKCU\Software\Microsoft\Office\17.0\Common\LanguageResources [SKULanguage]','HKLM\Software\Microsoft\Office\17.0\Common\LanguageResources [SKULanguage]')">
        <objectSet>
          <pattern type="Registry">HKLM\Software\Microsoft\Office\17.0\Common\Migration\%OFFICEPROGRAM% [Lang]</pattern>
        </objectSet>
      </contentModify>
    </rules>
    <!-- Outlook Pst Rule -->
    <rules name="OutlookPstPab" context="User">
      <include>
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [01020fff]</pattern>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e0324]</pattern>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e6600]</pattern>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e6700]</pattern>
          <content filter="MigSysHelper.ExtractSingleFileAnsiBin()">
            <objectSet>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e0324]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e6600]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e6700]</pattern>
            </objectSet>
          </content>
        </objectSet>
      </include>
      <include>
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001f0324]</pattern>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001f6600]</pattern>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001f6700]</pattern>
          <content filter="MigSysHelper.ExtractSingleFileUnicodeBin()">
            <objectSet>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e0324]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e6600]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001e6700]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001f0324]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001f6600]</pattern>
              <pattern type="Registry">%OUTLOOKPROFILESPATH%* [001f6700]</pattern>
            </objectSet>
          </content>
        </objectSet>
      </include>
      <contentModify script="MigSysHelper.SetPstPathInMapiStruct ()">
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [0102*]</pattern>
        </objectSet>
      </contentModify>
      <contentModify script="MigSysHelper.UpdateMvBinaryMapiStruct ()">
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [0102*]</pattern>
        </objectSet>
      </contentModify>
      <contentModify script="MigSysHelper.UpdateMvBinaryMapiStruct ()">
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [1102*]</pattern>
        </objectSet>
      </contentModify>
    </rules>
  </namedElements>
  <!-- Microsoft Office 2010 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.office14">Microsoft Office 2010</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64" />
    <environment>
      <variable name="OFFICEVERSION">
        <text>14.0</text>
      </variable>
    </environment>
    <role role="Container">
      <detection name="Access" />
      <detection name="Access_x64" />
      <detection name="Excel" />
      <detection name="Excel_x64" />
      <detection name="OneNote" />
      <detection name="OneNote_x64" />
      <detection name="Outlook" />
      <detection name="Outlook_x64" />
      <detection name="PowerPoint" />
      <detection name="PowerPoint_x64" />
      <detection name="Project14" />
      <detection name="Project14_x64" />
      <detection name="Publisher" />
      <detection name="Publisher_x64" />
      <detection name="Visio" />
      <detection name="Visio_x64" />
      <detection name="Word" />
      <detection name="Word_x64" />
      <detection name="InfoPath" />
      <detection name="InfoPath_x64" />
      <detection name="SharePointDesigner" />
      <detection name="SharePointDesigner_x64" />
      <!-- Office 2010 Common Settings -->
      <component context="UserAndSystem" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office14common">Office 2010 Common Settings</displayName>
        <role role="Settings">
          <!-- For Office 2010 -->
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\14.0\Common [Theme]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Common\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Common\Toolbars\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include filter="MigXmlHelper.IgnoreIrrelevantLinks()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\User Settings\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\14.0\* [*]</pattern>
                <!-- Quick access toolbars -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Extract custom dictionaries and related files -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Internet\NetworkStatusCache\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Open Find\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\14.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Custom dictionaries -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>
      <!-- Microsoft Office Access 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14access">Microsoft Office Access 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Access</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Access" />
          <detection name="Access_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings\* [*] </pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules>
            <include>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access14.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\* [*.mdw]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\CMA\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Common\Toolbars\Settings\ [Microsoft Access]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRU9]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Settings [MRUFlags9]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Access\Options [Default Database Directory]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office Excel 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14excel">Microsoft Office Excel 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Excel</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Excel" />
          <detection name="Excel_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Excel\Error Checking\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Excel\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Excel\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Excel\* [*]</pattern>
              </objectSet>
            </include>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office OneNote 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14onenote">Microsoft Office OneNote 2010</displayName>
        <environment>
          <variable name="OneNoteCachePath">
            <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Microsoft\Office\14.0\OneNote\General [CachePath]")</script>
          </variable>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="OneNote" />
          <detection name="OneNote_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="File">%OneNoteCachePath%\OneNoteOfflineCache_Files\* [*]</pattern>
                <pattern type="File">%OneNoteCachePath% [OneNoteOfflineCache.onecache]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\OneNote\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\14.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\OneNote\Options\Other [EnableAudioSearch]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\14.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office InfoPath 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14infopath">Microsoft Office InfoPath 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="InfoPath" />
          <detection name="InfoPath_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\InfoPath\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\InfoPath\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office SharePoint Designer 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14sharepointdesigner">Microsoft SharePoint Designer 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>SharePointDesigner</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="SharePointDesigner" />
          <detection name="SharePointDesigner_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office Outlook 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14outlook">Microsoft Office Outlook 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Outlook</text>
          </variable>
          <variable name="OUTLOOKPROFILESPATH">
            <text>HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Outlook" />
          <detection name="Outlook_x64" />
          <rules name="OutlookPstPab" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Exchange\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Stationery\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Signatures\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <!-- Move .pst files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Outlook\Search\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move journals -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Outlook\Journal\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move .FAV files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001e023d]</pattern>
                    <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001f023d]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!-- We don't migrate .ost files, as recommended by the Outlook team -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*.ost]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.xml]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office PowerPoint 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14powerpoint">Microsoft Office PowerPoint 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>PowerPoint</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="PowerPoint" />
          <detection name="PowerPoint_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\PowerPoint\Options\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\PowerPoint\Internet\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\PowerPoint\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Project 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14project">Microsoft Project 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Project</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Project14" />
          <detection name="Project14_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\MS Project\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\MS Project\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\14\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\14\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office Publisher 2010 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14publisher">Microsoft Office Publisher 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Publisher</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Publisher" />
          <detection name="Publisher_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Publisher\Preferences\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office SmartTags -->
      <component context="User" type="Application">
        <displayName _locID="migapp.office14smarttag">Microsoft Office SmartTags</displayName>
        <role role="Container">
          <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
          <detection name="MicrosoftListsSmartTags14" />
          <detection name="MicrosoftPlaceSmartTags" />
          <!-- Microsoft Outlook Email Recipients SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office14emailsmarttag">Microsoft Outlook Email Recipients SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Lists SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office14listsmarttag">Microsoft Lists SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftListsSmartTags14" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Place SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office14placesmarttag">Microsoft Place SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftPlaceSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
        </role>
      </component>
      <!-- Microsoft Office Visio 2010 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.visio14">Microsoft Office Visio 2010</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Visio</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Visio" />
          <detection name="Visio_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\14.0\Visio\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\14.0\Visio\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [LicenseCache]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [ConfigChangeID]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [MyShapesPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [DrawingsPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [StartUpPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [StencilPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Application [TemplatePath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Quick Shapes\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Security\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Visio\Recent Templates\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
          <rules name="Office14to15SettingsUpgrade_x64" />
        </role>
      </component>
      <!-- Microsoft Office Word 2010 (32-bit) -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14word32bit">Microsoft Office Word 2010 (32-bit)</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
          <variable name="OFFICEVERSION">
            <text>14.0</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Word" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\14.0\Word\Data\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [Normal.dotm]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [NormalEmail.dotm]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [Normal.dotm]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [NormalEmail.dotm]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
            <unconditionalExclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\Options [PROGRAMDIR]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\Data\* [*]</pattern>
              </objectSet>
            </unconditionalExclude>
          </rules>
          <rules name="Office14to15SettingsUpgrade" />
        </role>
      </component>
      <!-- Microsoft Office Word 2010 (64-bit) -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office14word64bit">Microsoft Office Word 2010 (64-bit)</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
          <variable name="OFFICEVERSION">
            <text>14.0</text>
          </variable>
        </environment>
        <role role="Container">
          <detection name="Word_x64" />
          <component context="UserAndSystem" type="Application">
            <displayName _locID="migapp.office2010word64bitbody">Microsoft Office Word 2010 (64-bit) Body</displayName>
            <role role="Settings">
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\software\Microsoft\Office\11.0\Word\Data\* [*]</pattern>
                    <pattern type="Registry">HKCU\software\Microsoft\Office\12.0\Word\Data\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\* [*]</pattern>
                    <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [Normal.dotm]</pattern>
                    <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [NormalEmail.dotm]</pattern>
                    <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                  </objectSet>
                </include>
                <merge script="MigXmlHelper.SourcePriority()">
                  <objectSet>
                    <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [Normal.dotm]</pattern>
                    <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [NormalEmail.dotm]</pattern>
                    <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                  </objectSet>
                </merge>
                <exclude>
                  <objectSet>
                    <!-- keep the rest of HKCU\Software\Microsoft\Office\14.0\Word\Data for 64 to 64 bit settings -->
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\Options [PROGRAMDIR]</pattern>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\Data [PROGRAMDIR]</pattern>
                  </objectSet>
                </exclude>
              </rules>
              <rules name="Office14to15SettingsUpgrade_x64" />
            </role>
          </component>
          <!-- If migrating from Office 2010 to Office 2010+ delete Word "Data" Settings key if target is 32-bit Office on 64 bit OS -->
          <component context="UserAndSystem" type="Application">
            <displayName _locID="migapp.office2010word64bitlegacysettings">Microsoft Office Word 2010 (64-bit) legacy settings</displayName>
            <role role="Settings">
              <detection name="Word_x32_64OS" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\software\Microsoft\Office\14.0\Word\Data\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <!-- mandatory include field -->
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\Data\* [*]</pattern>
                  </objectSet>
                </include>
                <unconditionalExclude>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\14.0\Word\Data\* [*]</pattern>
                  </objectSet>
                </unconditionalExclude>
              </rules>
            </role>
          </component>
        </role>
      </component>
    </role>
  </component>
  <!-- Microsoft Office 15 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.office15">Microsoft Office 15</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64" />
    <environment>
      <variable name="OFFICEVERSION">
        <text>15.0</text>
      </variable>
    </environment>
    <role role="Container">
      <detection name="Access" />
      <detection name="Access_x64" />
      <detection name="Excel" />
      <detection name="Excel_x64" />
      <detection name="OneNote" />
      <detection name="OneNote_x64" />
      <detection name="Outlook" />
      <detection name="Outlook_x64" />
      <detection name="PowerPoint" />
      <detection name="PowerPoint_x64" />
      <detection name="Project15" />
      <detection name="Project15_x64" />
      <detection name="Publisher" />
      <detection name="Publisher_x64" />
      <detection name="Visio15" />
      <detection name="Visio15_x64" />
      <detection name="Word" />
      <detection name="Word_x64" />
      <detection name="InfoPath" />
      <detection name="InfoPath_x64" />
      <detection name="SharePointDesigner" />
      <detection name="SharePointDesigner_x64" />
      <detection name="Lync15" />
      <detection name="Lync15_x64" />
      <!-- Office 15 Common Settings -->
      <component context="UserAndSystem" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office15common">Office 15 Common Settings</displayName>
        <role role="Settings">
          <!-- For Office 15 -->
          <rules>
            <destinationCleanup>
              <objectSet>
                <!--<pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Common [Theme]</pattern>-->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Toolbars\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include filter="MigXmlHelper.IgnoreIrrelevantLinks()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\User Settings\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\15.0\* [*]</pattern>
                <!-- Quick access toolbars -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Extract custom dictionaries and related files -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
                <!-- Web Extensibility Framework (WEF) -->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\WEF\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Internet\NetworkStatusCache\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Open Find\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\15.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Custom dictionaries -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>
      <!-- Microsoft Office Access 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15access">Microsoft Office Access 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Access</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Access" />
          <detection name="Access_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings\* [*] </pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules>
            <include>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access15.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\* [*.mdw]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\CMA\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Toolbars\Settings\ [Microsoft Access]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRU9]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Settings [MRUFlags9]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Access\Options [Default Database Directory]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Excel 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15excel">Microsoft Office Excel 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Excel</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Excel" />
          <detection name="Excel_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Excel\Error Checking\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Excel\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Excel\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Excel\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Excel\* [*]</pattern>
              </objectSet>
            </include>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office OneNote 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15onenote">Microsoft Office OneNote 15</displayName>
        <environment>
          <variable name="OneNoteCachePath">
            <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Microsoft\Office\15.0\OneNote\General [CachePath]")</script>
          </variable>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="OneNote" />
          <detection name="OneNote_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="File">%OneNoteCachePath%\OneNoteOfflineCache_Files\* [*]</pattern>
                <pattern type="File">%OneNoteCachePath% [OneNoteOfflineCache.onecache]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\OneNote\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\15.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\OneNote\Options\Other [EnableAudioSearch]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\15.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office InfoPath 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15infopath">Microsoft Office InfoPath 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="InfoPath" />
          <detection name="InfoPath_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\InfoPath\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\InfoPath\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office SharePoint Designer 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15sharepointdesigner">Microsoft SharePoint Designer 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>SharePointDesigner</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="SharePointDesigner" />
          <detection name="SharePointDesigner_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Outlook 2013 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15outlook">Microsoft Office Outlook 2013</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Outlook</text>
          </variable>
          <variable name="OUTLOOKPROFILESPATH">
            <text>HKCU\Software\Microsoft\Office\15.0\Outlook\Profiles\</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Outlook" />
          <detection name="Outlook_x64" />
          <rules name="OutlookPstPab" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Exchange\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Outlook\Profiles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Stationery\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Signatures\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <!-- Move .pst files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Outlook\Search\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move journals -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Outlook\Journal\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move .FAV files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Outlook\Profiles\* [001e023d]</pattern>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Outlook\Profiles\* [001f023d]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!-- We don't migrate .ost files, as recommended by the Outlook team -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*.ost]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.xml]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office PowerPoint 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15powerpoint">Microsoft Office PowerPoint 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>PowerPoint</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="PowerPoint" />
          <detection name="PowerPoint_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\PowerPoint\Options\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\PowerPoint\Internet\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\PowerPoint\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Project 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15project">Microsoft Project 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Project</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Project15" />
          <detection name="Project15_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\MS Project\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\MS Project\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\15\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\15\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Publisher 15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15publisher">Microsoft Office Publisher 2013</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Publisher</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Publisher" />
          <detection name="Publisher_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Publisher\Preferences\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office SmartTags -->
      <component context="User" type="Application">
        <displayName _locID="migapp.office15smarttag">Microsoft Office SmartTags</displayName>
        <role role="Container">
          <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
          <detection name="MicrosoftListsSmartTags15" />
          <detection name="MicrosoftPlaceSmartTags" />
          <!-- Microsoft Outlook Email Recipients SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office15emailsmarttag">Microsoft Outlook Email Recipients SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Lists SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office15listsmarttag">Microsoft Lists SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftListsSmartTags15" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Place SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office15placesmarttag">Microsoft Place SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftPlaceSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
        </role>
      </component>
      <!-- Microsoft Office Visio 15 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.visio15">Microsoft Office Visio 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Visio</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Visio15" />
          <detection name="Visio15_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Visio\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Visio\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [LicenseCache]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [ConfigChangeID]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [MyShapesPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [DrawingsPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [StartUpPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [StencilPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Application [TemplatePath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Quick Shapes\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Security\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Visio\Recent Templates\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Lync 15 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.lync15">Microsoft Office Lync 15</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Lync</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Lync15" />
          <detection name="Lync15_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Lync\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Lync\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Lync\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!--
              <enter information here>
                    -->
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Lync\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Word 15 (32-bit) -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office15word32bit">Microsoft Office Word 2013 (32-bit)</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
          <variable name="OFFICEVERSION">
            <text>15.0</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Word" />
          <detection name="Word_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Word\Data\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Toolbars\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Research\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\General\[SharedDocumentParts]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\General\[SharedTemplates]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\General\[Templates]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\General\[Themes]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Blog \* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Common\Spotlight\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Bibliography\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word.qat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word15.customUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Word15.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa15.pip]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word.qat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word15.customUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Word15.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa15.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa15.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
            <unconditionalExclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Word\Options\[PROGRAMDIR]</pattern>
                <!-- A user would only set these two setting to mitigate performance issues on an older machine. It's likely that users are upgrading to a more powerful machine, so let the defaults kick back in for these settings -->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Word\Options\[LiveDrag]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\15.0\Word\Options\[LivePreview]</pattern>
                <!-- We can't know if the source \Word\Data\ blobs will be valid on the destination system, so exclude them-->
                <pattern type="Registry">HKCU\software\Microsoft\Office\15.0\Word\Data\* [*]</pattern>
              </objectSet>
            </unconditionalExclude>
          </rules>
          <rules name="Office15to15SettingsMigrate" />
          <rules name="Office15to15SettingsMigrate_x64" />
        </role>
      </component>
    </role>
  </component>
  <!-- Microsoft Office 16 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.office16">Microsoft Office 16</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64" />
    <environment>
      <variable name="OFFICEVERSION">
        <text>16.0</text>
      </variable>
    </environment>
    <role role="Container">
      <detection name="Access" />
      <detection name="Access_x64" />
      <detection name="Excel" />
      <detection name="Excel_x64" />
      <detection name="OneNote" />
      <detection name="OneNote_x64" />
      <detection name="Outlook" />
      <detection name="Outlook_x64" />
      <detection name="PowerPoint" />
      <detection name="PowerPoint_x64" />
      <detection name="Project16" />
      <detection name="Project16_x64" />
      <detection name="Publisher" />
      <detection name="Publisher_x64" />
      <detection name="Visio16" />
      <detection name="Visio16_x64" />
      <detection name="Word" />
      <detection name="Word_x64" />
      <detection name="InfoPath" />
      <detection name="InfoPath_x64" />
      <detection name="SharePointDesigner" />
      <detection name="SharePointDesigner_x64" />
      <detection name="Lync16" />
      <detection name="Lync16_x64" />
      <!-- Office 16 Common Settings -->
      <component context="UserAndSystem" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office16common">Office 16 Common Settings</displayName>
        <role role="Settings">
          <!-- For Office 16 -->
          <rules>
            <destinationCleanup>
              <objectSet>
                <!--<pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Common [Theme]</pattern>-->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Toolbars\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include filter="MigXmlHelper.IgnoreIrrelevantLinks()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\User Settings\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\16.0\* [*]</pattern>
                <!-- Quick access toolbars -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Extract custom dictionaries and related files -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
                <!-- Web Extensibility Framework (WEF) -->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\WEF\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Internet\NetworkStatusCache\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Open Find\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\16.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Custom dictionaries -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>
      <!-- Microsoft Office Access 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16access">Microsoft Office Access 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Access</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Access" />
          <detection name="Access_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings\* [*] </pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules>
            <include>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access16.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\* [*.mdw]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\CMA\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Toolbars\Settings\ [Microsoft Access]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRU9]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Settings [MRUFlags9]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Access\Options [Default Database Directory]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Excel 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16excel">Microsoft Office Excel 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Excel</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Excel" />
          <detection name="Excel_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Excel\Error Checking\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Excel\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Excel\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Excel\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Excel\* [*]</pattern>
              </objectSet>
            </include>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office OneNote 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16onenote">Microsoft Office OneNote 16</displayName>
        <environment>
          <variable name="OneNoteCachePath">
            <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Microsoft\Office\16.0\OneNote\General [CachePath]")</script>
          </variable>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="OneNote" />
          <detection name="OneNote_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="File">%OneNoteCachePath%\OneNoteOfflineCache_Files\* [*]</pattern>
                <pattern type="File">%OneNoteCachePath% [OneNoteOfflineCache.onecache]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\OneNote\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\16.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\OneNote\Options\Other [EnableAudioSearch]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\16.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office InfoPath 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16infopath">Microsoft Office InfoPath 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="InfoPath" />
          <detection name="InfoPath_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\InfoPath\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\InfoPath\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office SharePoint Designer 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16sharepointdesigner">Microsoft SharePoint Designer 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>SharePointDesigner</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="SharePointDesigner" />
          <detection name="SharePointDesigner_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Outlook 2016 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16outlook">Microsoft Office Outlook 2016</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Outlook</text>
          </variable>
          <variable name="OUTLOOKPROFILESPATH">
            <text>HKCU\Software\Microsoft\Office\16.0\Outlook\Profiles\</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Outlook" />
          <detection name="Outlook_x64" />
          <rules name="OutlookPstPab" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Exchange\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Outlook\Profiles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Stationery\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Signatures\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <!-- Move .pst files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Outlook\Search\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move journals -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Outlook\Journal\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move .FAV files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Outlook\Profiles\* [001e023d]</pattern>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Outlook\Profiles\* [001f023d]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!-- We don't migrate .ost files, as recommended by the Outlook team -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*.ost]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.xml]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office PowerPoint 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16powerpoint">Microsoft Office PowerPoint 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>PowerPoint</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="PowerPoint" />
          <detection name="PowerPoint_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\PowerPoint\Options\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\PowerPoint\Internet\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\PowerPoint\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Project 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16project">Microsoft Project 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Project</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Project16" />
          <detection name="Project16_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\MS Project\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\MS Project\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\16\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\16\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Publisher 16 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16publisher">Microsoft Office Publisher 2016</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Publisher</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Publisher" />
          <detection name="Publisher_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Publisher\Preferences\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office SmartTags -->
      <component context="User" type="Application">
        <displayName _locID="migapp.office16smarttag">Microsoft Office SmartTags</displayName>
        <role role="Container">
          <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
          <detection name="MicrosoftListsSmartTags16" />
          <detection name="MicrosoftPlaceSmartTags" />
          <!-- Microsoft Outlook Email Recipients SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office16emailsmarttag">Microsoft Outlook Email Recipients SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Lists SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office16listsmarttag">Microsoft Lists SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftListsSmartTags16" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Place SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office16placesmarttag">Microsoft Place SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftPlaceSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
        </role>
      </component>
      <!-- Microsoft Office Visio 16 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.visio16">Microsoft Office Visio 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Visio</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Visio16" />
          <detection name="Visio16_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Visio\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Visio\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [LicenseCache]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [ConfigChangeID]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [MyShapesPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [DrawingsPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [StartUpPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [StencilPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Application [TemplatePath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Quick Shapes\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Security\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Visio\Recent Templates\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Lync 16 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.lync16">Microsoft Office Lync 16</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Lync</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Lync16" />
          <detection name="Lync16_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Lync\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Lync\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Lync\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!--
              <enter information here>
                    -->
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Lync\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Word 16 (32-bit) -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office16word32bit">Microsoft Office Word 2016 (32-bit)</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
          <variable name="OFFICEVERSION">
            <text>16.0</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Word" />
          <detection name="Word_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Word\Data\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Toolbars\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Research\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\General\[SharedDocumentParts]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\General\[SharedTemplates]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\General\[Templates]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\General\[Themes]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Blog \* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Common\Spotlight\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Bibliography\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word.qat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word16.customUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Word16.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa16.pip]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word.qat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word16.customUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Word16.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa16.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa16.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
            <unconditionalExclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Word\Options\[PROGRAMDIR]</pattern>
                <!-- A user would only set these two setting to mitigate performance issues on an older machine. It's likely that users are upgrading to a more powerful machine, so let the defaults kick back in for these settings -->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Word\Options\[LiveDrag]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\16.0\Word\Options\[LivePreview]</pattern>
                <!-- We can't know if the source \Word\Data\ blobs will be valid on the destination system, so exclude them-->
                <pattern type="Registry">HKCU\software\Microsoft\Office\16.0\Word\Data\* [*]</pattern>
              </objectSet>
            </unconditionalExclude>
          </rules>
          <rules name="Office16to16SettingsMigrate" />
          <rules name="Office16to16SettingsMigrate_x64" />
        </role>
      </component>
    </role>
  </component>
  <!-- Microsoft Office 17 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.office17">Microsoft Office 17</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64" />
    <environment>
      <variable name="OFFICEVERSION">
        <text>17.0</text>
      </variable>
    </environment>
    <role role="Container">
      <detection name="Access" />
      <detection name="Access_x64" />
      <detection name="Excel" />
      <detection name="Excel_x64" />
      <detection name="OneNote" />
      <detection name="OneNote_x64" />
      <detection name="Outlook" />
      <detection name="Outlook_x64" />
      <detection name="PowerPoint" />
      <detection name="PowerPoint_x64" />
      <detection name="Project17" />
      <detection name="Project17_x64" />
      <detection name="Publisher" />
      <detection name="Publisher_x64" />
      <detection name="Visio17" />
      <detection name="Visio17_x64" />
      <detection name="Word" />
      <detection name="Word_x64" />
      <detection name="InfoPath" />
      <detection name="InfoPath_x64" />
      <detection name="SharePointDesigner" />
      <detection name="SharePointDesigner_x64" />
      <detection name="Lync17" />
      <detection name="Lync17_x64" />
      <!-- Office 17 Common Settings -->
      <component context="UserAndSystem" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office17common">Office 17 Common Settings</displayName>
        <role role="Settings">
          <!-- For Office 17 -->
          <rules>
            <destinationCleanup>
              <objectSet>
                <!--<pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Common [Theme]</pattern>-->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Toolbars\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include filter="MigXmlHelper.IgnoreIrrelevantLinks()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\User Settings\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\17.0\* [*]</pattern>
                <!-- Quick access toolbars -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Extract custom dictionaries and related files -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
                <!-- Web Extensibility Framework (WEF) -->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\WEF\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Internet\NetworkStatusCache\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Open Find\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\17.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.qat]</pattern>
                <!-- Custom dictionaries -->
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\*\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>
      <!-- Microsoft Office Access 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17access">Microsoft Office Access 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Access</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Access" />
          <detection name="Access_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings\* [*] </pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Access\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules>
            <include>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access17.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\* [*.mdw]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\CMA\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Toolbars\Settings\ [Microsoft Access]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRU9]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags7]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags8]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Settings [MRUFlags9]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Access\Options [Default Database Directory]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Excel 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17excel">Microsoft Office Excel 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Excel</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Excel" />
          <detection name="Excel_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Excel\Error Checking\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Excel\Internet\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Excel\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Excel\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Excel\* [*]</pattern>
              </objectSet>
            </include>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office OneNote 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17onenote">Microsoft Office OneNote 17</displayName>
        <environment>
          <variable name="OneNoteCachePath">
            <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Microsoft\Office\17.0\OneNote\General [CachePath]")</script>
          </variable>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="OneNote" />
          <detection name="OneNote_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="File">%OneNoteCachePath%\OneNoteOfflineCache_Files\* [*]</pattern>
                <pattern type="File">%OneNoteCachePath% [OneNoteOfflineCache.onecache]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\OneNote\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\17.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\OneNote\Options\Other [EnableAudioSearch]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\17.0\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [OneNote.officeUI]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office InfoPath 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17infopath">Microsoft Office InfoPath 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="InfoPath" />
          <detection name="InfoPath_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\InfoPath\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\InfoPath\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office SharePoint Designer 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17sharepointdesigner">Microsoft SharePoint Designer 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>SharePointDesigner</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="SharePointDesigner" />
          <detection name="SharePointDesigner_x64" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\SharePoint Designer\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Outlook 2017 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17outlook">Microsoft Office Outlook 2017</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Outlook</text>
          </variable>
          <variable name="OUTLOOKPROFILESPATH">
            <text>HKCU\Software\Microsoft\Office\17.0\Outlook\Profiles\</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Outlook" />
          <detection name="Outlook_x64" />
          <rules name="OutlookPstPab" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Exchange\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Outlook\Profiles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Stationery\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Signatures\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*]</pattern>
                <!-- Move .pst files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Outlook\Search\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move journals -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Outlook\Journal\* [*]</pattern>
                  </objectSet>
                </content>
                <!-- Move .FAV files -->
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Outlook\Profiles\* [001e023d]</pattern>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Outlook\Profiles\* [001f023d]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!-- We don't migrate .ost files, as recommended by the Outlook team -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook\* [*.ost]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.xml]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook\* [*.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office PowerPoint 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17powerpoint">Microsoft Office PowerPoint 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>PowerPoint</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="PowerPoint" />
          <detection name="PowerPoint_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\PowerPoint\Options\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\PowerPoint\Internet\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\PowerPoint\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Project 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17project">Microsoft Project 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Project</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Project17" />
          <detection name="Project17_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\MS Project\Options\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\MS Project\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\17\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\17\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Publisher 17 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17publisher">Microsoft Office Publisher 2017</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Publisher</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Publisher" />
          <detection name="Publisher_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Publisher\Preferences\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office SmartTags -->
      <component context="User" type="Application">
        <displayName _locID="migapp.office17smarttag">Microsoft Office SmartTags</displayName>
        <role role="Container">
          <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
          <detection name="MicrosoftListsSmartTags17" />
          <detection name="MicrosoftPlaceSmartTags" />
          <!-- Microsoft Outlook Email Recipients SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office17emailsmarttag">Microsoft Outlook Email Recipients SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Lists SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office17listsmarttag">Microsoft Lists SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftListsSmartTags17" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
          <!-- Microsoft Place SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office17placesmarttag">Microsoft Place SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftPlaceSmartTags" />
              <rules>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}\* [*]</pattern>
                  </objectSet>
                </include>
              </rules>
            </role>
          </component>
        </role>
      </component>
      <!-- Microsoft Office Visio 17 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.visio17">Microsoft Office Visio 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Visio</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Visio17" />
          <detection name="Visio17_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Visio\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Visio\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [LicenseCache]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [ConfigChangeID]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [MyShapesPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [DrawingsPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [StartUpPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [StencilPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Application [TemplatePath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Quick Shapes\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Security\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Visio\Recent Templates\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Lync 17 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.lync17">Microsoft Office Lync 17</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Lync</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Lync17" />
          <detection name="Lync17_x64" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Lync\Application\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Lync\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Lync\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <!--
              <enter information here>
                    -->
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Lync\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
      <!-- Microsoft Office Word 17 (32-bit) -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office17word32bit">Microsoft Office Word 2017 (32-bit)</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
          <variable name="OFFICEVERSION">
            <text>17.0</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Word" />
          <detection name="Word_x64" />
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Word\Data\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Toolbars\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Research\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\General\[SharedDocumentParts]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\General\[SharedTemplates]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\General\[Templates]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\General\[Themes]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Blog \* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Common\Spotlight\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Bibliography\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word.qat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word17.customUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Word17.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa17.pip]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word.qat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office\ [Word17.customUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Word17.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa17.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [WordMa17.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
            <unconditionalExclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Word\Options\[PROGRAMDIR]</pattern>
                <!-- A user would only set these two setting to mitigate performance issues on an older machine. It's likely that users are upgrading to a more powerful machine, so let the defaults kick back in for these settings -->
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Word\Options\[LiveDrag]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\17.0\Word\Options\[LivePreview]</pattern>
                <!-- We can't know if the source \Word\Data\ blobs will be valid on the destination system, so exclude them-->
                <pattern type="Registry">HKCU\software\Microsoft\Office\17.0\Word\Data\* [*]</pattern>
              </objectSet>
            </unconditionalExclude>
          </rules>
          <rules name="Office17to17SettingsMigrate" />
          <rules name="Office17to17SettingsMigrate_x64" />
        </role>
      </component>
    </role>
  </component>
</migration>
"@
#endregion migapp xml

#region miguser xml
$usmtmiguser = [xml] @"
<?xml version="1.0" encoding="UTF-8"?>
<migration urlid="http://www.microsoft.com/migration/1.0/migxmlext/miguser">

    <_locDefinition>
    <_locDefault _loc="locNone"/>
    <_locTag _loc="locData">displayName</_locTag>
    </_locDefinition>

	<!-- This component migrates My Downloads files  -->
    <component type="Documents" context="User">
        <displayName _locID="miguser.mydownloads">My Downloads</displayName>
        <paths>
            <path type="File">%FOLDERID_DOWNLOADS%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%FOLDERID_DOWNLOADS%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%FOLDERID_DOWNLOADS%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%FOLDERID_DOWNLOADS% [desktop.ini]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component> 
	
    <!-- This component migrates My Video files -->
    <component type="Documents" context="User">
        <displayName _locID="miguser.myvideo">My Video</displayName>
        <paths>
            <path type="File">%CSIDL_MYVIDEO%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_MYVIDEO%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_MYVIDEO%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_MYVIDEO% [desktop.ini]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>


    <!-- This component migrates My Music files -->
    <component type="Documents" context="User">
        <displayName _locID="miguser.mymusic">My Music</displayName>
        <paths>
            <path type="File">%CSIDL_MYMUSIC%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_MYMUSIC%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_MYMUSIC%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_MYMUSIC%\ [desktop.ini]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

    <!-- This component migrates Desktop files -->
    <component type="Documents" context="User">
        <displayName _locID="miguser.desktop">Desktop</displayName>
        <paths>
            <path type="File">%CSIDL_DESKTOP%</path>
        </paths>
        <role role="Settings">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_DESKTOP%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_DESKTOP%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_DESKTOP% [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_DESKTOP%\* [*]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

    <!-- This component migrates Start Menu files -->
    <component type="System" context="User">
        <displayName _locID="miguser.startmenu">Start Menu</displayName>
        <paths>
            <path type="File">%CSIDL_STARTMENU%</path>
        </paths>
        <role role="Settings">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_STARTMENU%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_STARTMENU%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_STARTMENU% [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_STARTMENU%\* [*]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

    <!-- This component migrates My Documents files -->
    <component type="Documents" context="User">
        <displayName _locID="miguser.mydocs">My Documents</displayName>
        <paths>
            <path type="File">%CSIDL_PERSONAL%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_PERSONAL%")</condition>
                </detect>
            </detects>
            <rules>
                <exclude>
                    <objectSet>
                        <pattern type="File">%CSIDL_MYMUSIC%\* [*]</pattern>
                        <pattern type="File">%CSIDL_MYPICTURES%\* [*]</pattern>
                        <pattern type="File">%CSIDL_MYVIDEO%\* [*]</pattern>
                    </objectSet>
                </exclude>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_PERSONAL%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_PERSONAL% [desktop.ini]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

    <!-- This component migrates My Pictures files -->
    <component type="Documents" context="User">
        <displayName _locID="miguser.mypics">My Pictures</displayName>
        <paths>
            <path type="File">%CSIDL_MYPICTURES%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_MYPICTURES%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_MYPICTURES%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_MYPICTURES% [desktop.ini]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

    <!-- This component migrates Favorites -->
    <component type="System" context="User">
        <displayName _locID="miguser.favs">Favorites</displayName>
        <paths>
            <path type="File">%CSIDL_FAVORITES%</path>
        </paths>
        <role role="Settings">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_FAVORITES%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_FAVORITES%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_FAVORITES% [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_FAVORITES%\* [*]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

    <!-- This component migrates Quick Launch files -->
    <component type="System" context="User">
        <displayName _locID="miguser.quicklaunch">Quick Launch</displayName>
        <paths>
            <path type="File">%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch</path>
        </paths>
        <role role="Settings">

            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_APPDATA%\Microsoft\Internet Explorer\Quick Launch\* [*]</pattern>
                    </objectSet>
                </merge>
            </rules>
        </role>
    </component>

</migration>
"@

#endregion miguser xml
