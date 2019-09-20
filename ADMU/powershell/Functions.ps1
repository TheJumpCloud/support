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

     Changelog:
      * Code simplification and clarification - thanks to @juneb_get_help
      * Added documentation.
      * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks
      * Revised the Force switch to work as it should - thanks to @JeffHicks

     To Do:
      * Add error handling if trying to create a log file in a inaccessible location.
      * Add ability to write $Message to $Verbose or $Error pipelines to eliminate
        duplicates.
  .PARAMETER Message
     Message is the content that you wish to add to the log file.
  .PARAMETER Path
     The path to the log file to which you would like to write. By default the function will
     create the path and file if it does not exist.
  .PARAMETER Level
     Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational)
  .PARAMETER NoClobber
     Use NoClobber if you do not wish to overwrite an existing file.
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
        , [Parameter(Mandatory = $false)][switch]$NoClobber
    )
    Begin
    {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process
    {
        # If the file already exists and NoClobber was specified, do not write to the log.
        If ((Test-Path $Path) -AND $NoClobber)
        {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
        }
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        ElseIf (!(Test-Path $Path))
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
    if ($null -ne $installed) {
      return $true
    }
    else {
      return $false
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
        # Download Installer
        DownloadAgentInstaller
        Write-Log -Message:('JumpCloud Agent Download Complete')
        Write-Log -Message:('Running JCAgent Installer')
        # Run Installer
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
  param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('Value')]
    $Sid 
  )
  
  process
  {
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    $objUser.Value
  }
} 


#endregion Functions

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
    <_locDefault _loc="locNone"/>
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

      <contentModify script='MigSysHelper.SetPstPathInMapiStruct ()'>
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [0102*]</pattern>
        </objectSet>
      </contentModify>

      <contentModify script='MigSysHelper.UpdateMvBinaryMapiStruct ()'>
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [0102*]</pattern>
        </objectSet>
      </contentModify>

      <contentModify script='MigSysHelper.UpdateMvBinaryMapiStruct ()'>
        <objectSet>
          <pattern type="Registry">%OUTLOOKPROFILESPATH%* [1102*]</pattern>
        </objectSet>
      </contentModify>
    </rules>

  </namedElements>

  <!-- Lotus Notes 6, 7 and 8 -->
  <component context="User" type="Application">
    <displayName _locID="migapp.lotusnotes">Lotus Notes</displayName>
    <environment>
      <variable name="NotesInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Lotus\Notes\Installer [PROGDIR]")</script>
      </variable>
      <variable name="NotesDataPath">
        <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Lotus\Notes\Installer [DATADIR]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%NotesInstPath%\notes.exe","ProductVersion","6.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%NotesInstPath%\notes.exe","ProductVersion","7.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%NotesInstPath%\notes.exe","ProductVersion","8.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <conditions operation="OR">
          <condition>MigXmlHelper.DoesFileVersionMatch("%NotesInstPath%\notes.exe","ProductVersion","6.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%NotesInstPath%\notes.exe","ProductVersion","7.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\VirtualStore\Program Files\Lotus\Notes\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\VirtualStore\Program Files (X86)\Lotus\Notes\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Notes\Installer [USENOTESFOREMAIL]</pattern>
          </objectSet>
        </include>
        <include>
          <objectSet>
            <pattern type="File">%NotesDataPath%\* [*]</pattern>
            <pattern type="File">%NotesInstPath%\ [formats.ini]</pattern>
            <pattern type="File">%NotesInstPath%\ [keyview.ini]</pattern>
            <pattern type="File">%NotesInstPath%\ [notestat.ini]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[InstallType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Timezone]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DST]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DSTLAW]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MailType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$$HasLANPort]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[PhoneLog]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Log]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[AltNameLanguage]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ContentLanguage]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WeekStart]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ViewWeekStart]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NavWeekStart]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[XLATE_CSID]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SPELL_LANG]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Region]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DatePickerDirection]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Passthru_LogLevel]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Console_LogLevel]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[VIEWIMP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[VIEWEXP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EDITIMP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EDITEXP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DDETimeout]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NAMEDSTYLE*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DefaultMailTemplate]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[TCPIP]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[LAN0]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Ports]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisabledPorts]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[KeyFilename]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[TemplateSetup]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Location]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MailFile]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$IEVersionMajor]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ECLSetup]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$headlineClientId]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DESKWINDOWSIZE]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WINDOWSIZEWIN]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MAXIMIZED]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NAMES]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartDocsLimitAmt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartAtchLimitAmt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefEncryptType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EmptyTrash]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[AltCalendar]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MIMEPromptMultilingual]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MIMEMultilingualMode]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[QuotePrefix]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[QuoteLineLength]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[AutoLogoffMinutes]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DeskIconColors]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[OLD_VCARD_REGISTRY_SETTIN]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[G]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[KitType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[FaultRecovery_Build]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnablePersistentBreakpoints]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$DisableCookies]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[StickyColumnSort]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisableForwardPrefix]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WindowSizeKeywords]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[BCASE_SITEMAP_DISPLAY]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$DisplayWindowMenu]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$headlineDisableHeadlines]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$MSOfficeToNotes]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Auto_Save_Enable]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[BackgroundPrinting]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[CertificateExpChecked]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ClassicDialogBoxCaption]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[CloseAllWinTabsPrompt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DefaultBrowser]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisableImageDithering]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisableOpenViewAsync]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableActiveXInBrowser]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableJavaApplets]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableJavaScript]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableJavaScriptErrorDialogs]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableLiveConnect]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnablePlugins]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ExitNotesPrompt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EXPAND_NAMES_PRINTING]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[LastHistoryPruneTime]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[LaunchDIIOPOnPreview]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MailUpgradeCheckTime]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MarkDocumentsPrompt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NO_SHELL_LINKS]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NoShowAttachmentWarning]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NoShowAttachmentWhenForwardingWarning]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Preferences]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[PromptForLocation]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefEncrypt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefFullDocs]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefFullText]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartAtchLimit]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartDocsLimit]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefReplImmed]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SaveStateOnExit]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ShowAccelerators]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ShowMIMEImagesAsAttachments]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SPELL_PREFERENCES]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[StrictDateTimeInput]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UNICODE_Display]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UNTAGGEDTEXT_FOLLOWS_FORM]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[URLBarInlineAutoComplete]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UseAccessNavigation]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UseTabToNavRODoc]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UseWebPalette]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[VIEW_ICONPOPUP]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WantThemes]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WWWDSP_PREFETCH_OBJECT]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WWWDSP_SYNC_BROWSERCACHE]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SU_IN_PROGRESS]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SU_DELAY_DAYS]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DontCheckDefaultMail]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[IM_ENABLE_SSO]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[IM_USE_CANONICAL_NAME]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%NotesInstPath%','%NotesInstPath%')">
          <objectSet>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[InstallType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Timezone]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DST]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DSTLAW]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MailType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$$HasLANPort]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[PhoneLog]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Log]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[AltNameLanguage]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ContentLanguage]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WeekStart]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ViewWeekStart]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NavWeekStart]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[XLATE_CSID]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SPELL_LANG]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Region]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DatePickerDirection]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Passthru_LogLevel]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Console_LogLevel]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[VIEWIMP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[VIEWEXP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EDITIMP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EDITEXP*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DDETimeout]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NAMEDSTYLE*]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DefaultMailTemplate]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[TCPIP]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[LAN0]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Ports]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisabledPorts]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[KeyFilename]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[TemplateSetup]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Location]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MailFile]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$IEVersionMajor]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ECLSetup]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$headlineClientId]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DESKWINDOWSIZE]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WINDOWSIZEWIN]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MAXIMIZED]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NAMES]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartDocsLimitAmt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartAtchLimitAmt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefEncryptType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EmptyTrash]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[AltCalendar]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MIMEPromptMultilingual]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MIMEMultilingualMode]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[QuotePrefix]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[QuoteLineLength]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[AutoLogoffMinutes]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DeskIconColors]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[OLD_VCARD_REGISTRY_SETTIN]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[G]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[KitType]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[FaultRecovery_Build]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnablePersistentBreakpoints]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$DisableCookies]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[StickyColumnSort]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisableForwardPrefix]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WindowSizeKeywords]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[BCASE_SITEMAP_DISPLAY]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$DisplayWindowMenu]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$headlineDisableHeadlines]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[$MSOfficeToNotes]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Auto_Save_Enable]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[BackgroundPrinting]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[CertificateExpChecked]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ClassicDialogBoxCaption]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[CloseAllWinTabsPrompt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DefaultBrowser]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisableImageDithering]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DisableOpenViewAsync]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableActiveXInBrowser]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableJavaApplets]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableJavaScript]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableJavaScriptErrorDialogs]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnableLiveConnect]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EnablePlugins]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ExitNotesPrompt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[EXPAND_NAMES_PRINTING]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[LastHistoryPruneTime]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[LaunchDIIOPOnPreview]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MailUpgradeCheckTime]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[MarkDocumentsPrompt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NO_SHELL_LINKS]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NoShowAttachmentWarning]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[NoShowAttachmentWhenForwardingWarning]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[Preferences]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[PromptForLocation]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefEncrypt]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefFullDocs]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefFullText]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartAtchLimit]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefPartDocsLimit]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ReplDefReplImmed]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SaveStateOnExit]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ShowAccelerators]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[ShowMIMEImagesAsAttachments]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SPELL_PREFERENCES]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[StrictDateTimeInput]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UNICODE_Display]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UNTAGGEDTEXT_FOLLOWS_FORM]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[URLBarInlineAutoComplete]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UseAccessNavigation]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UseTabToNavRODoc]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[UseWebPalette]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[VIEW_ICONPOPUP]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WantThemes]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WWWDSP_PREFETCH_OBJECT]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[WWWDSP_SYNC_BROWSERCACHE]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SU_IN_PROGRESS]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[SU_DELAY_DAYS]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[DontCheckDefaultMail]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[IM_ENABLE_SSO]</pattern>
            <pattern type="Ini">%NotesInstPath%\notes.ini|Notes[IM_USE_CANONICAL_NAME]</pattern>
          </objectSet>
        </locationModify>

        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%NotesDataPath%\* [*]</pattern>
            <pattern type="File">%NotesInstPath%\ [*.ini]</pattern>
          </objectSet>
        </merge>
        <exclude>
          <objectSet>
            <pattern type="File">%NotesDataPath%\Help\* [*]</pattern>
            <pattern type="File">%NotesDataPath%\Modems\* [*]</pattern>
          </objectSet>
        </exclude>
      </rules>
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%NotesInstPath%\notes.exe","ProductVersion","8.*")</condition>
        </conditions>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Notes\Installer [USENOTESFOREMAIL]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [bookmark.nsf]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [desktop6.ndk]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [headline.nsf]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [names.nsf]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [user.dic]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [user.id]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\workspace\* [*]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\workspace\logs\* [*]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[KitType]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[SharedDataDirectory]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[InstallType]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[InstallMode]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[Directory]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[FaultRecovery_Build]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[DefaultMailTemplate]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[FileDlgDirectory]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[SU_*]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[SUT_*]</pattern>
            <pattern type="Ini">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\notes.ini|Notes[AUTO_SAVE_USER*]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [bookmark.nsf]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [desktop6.ndk]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [headline.nsf]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [names.nsf]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [user.dic]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data [user.id]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Lotus\Notes\Data\workspace\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- RealPlayer Basic 11 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.realplayerbasic">RealPlayer Basic</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment name="GlobalEnvUser"/>
    <environment name="GlobalEnvX64User"/>
    <environment>
      <variable name="RealPlayerInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\RealPlay.exe [Path]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%RealPlayerInstPath%\realplay.exe","ProductVersion","11.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\RealNetworks\Preferences\RegionData []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [AnalogRecVol]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [AutoPlay]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CDName1]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CDName2]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CDNameTemplate]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CurSelEncoder]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CustomColumn0]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CustomColumn1]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CustomColumn2]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CustomName0]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CustomName1]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [CustomName2]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [DatabaseBackupMode]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [Encrypt]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ExtractMode]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [FileRenamingEnabled]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [FirstTime]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [FirstTimeB]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [Installed]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [LastSetEncodeBitrate]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [LastUserMetaHeight]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ListSortColumn]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ListSortDirection]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [M4A Audio]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [MigrateDatabase]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [MP3]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [NamingDefaultChoice]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [NetdetectOptions]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [NumEncoders]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgOrder]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgTracksColAMOrder]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgTracksColAMWidths]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgTracksColINOrder]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgTracksColINWidths]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgTracksColstrzOrder]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgTracksColstrzWidths]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [OrgWidths]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [PlayCursorExp]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [RealAudio 10]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [RealAudio Lossless]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [SelectedListNode]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ShowAutoRecDlg]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ShownColumns]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ShownColumnsAM]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ShownColumnsstrz]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [ShowTrackInfo]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [TagEditID3V1]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [TagEditID3V2]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [TagEditRealOne]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [TagReadPriority]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [teawma.dll_codecID]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [teawma.dll_flavorID]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [TrackNameTemplate]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [UIPrefs]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [UnknownTrackNameTemplate]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [UseVBR]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [VersionNum]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [WaveAudio]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [WindowsMediaAudio]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences\WatchFolders\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\AllowAuthID []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\AutoBWDetection []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\AutoTransport []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\BandwidthNotKnown []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\BufferedPlayTime []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\CacheEnabled []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\CacheMaxSize []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\caption_switch []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\ConnectionTimeout []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\LiveSuperBuffer []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\MaxBandwidth []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\overdub_or_caption []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\Quality []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\SendStatistics []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\ServerTimeOut []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\SuperBufferLength []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\SynchMM []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\systemAudioDesc []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\TestedFullScreen []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\TurboPlay []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\UDPPort []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\UseOverlay []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\UseUDPPort []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\UseWinDraw []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\AskToScanWatchfolders []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\AutosizeVideo []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\ClipListClearOrKeep []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\ClipListNumToKeep []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DevOptFilesEnableOnDownload []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DevOptFilesEnableOnTransfer []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DownloadAndRecording\ChangeToAutoHideTimeout []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DownloadAndRecording\ShowState []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DVDEnableCloseCaptions []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DVDEnableSubtitles []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DVDPreferredLanguage []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DVDStartPlaybackOnInsert []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\DVDStartPlaybackOnInsertMode []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\EnableHistoryInFileMenu []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\EnableInstantPlayback []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\ExternalTrackAdds []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\HurlErrInf []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\NetdetectOptions []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\PauseAtPlaybackStart []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\PrefsPosition []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\SuperBufferIncrease []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\TaikoImportStartedUpgrade []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\UniversalPlaybackOutsidePlayer []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\UseFullScreenControls []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\Warn []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\WarnOnClearTrackList []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Update\6.0\Preferences\ATH\AutoLaunch []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Update\6.0\Preferences\ATH\RefCount []</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Update\6.0\Preferences\BackgroundUpdate []</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\RealNetworks\Msg\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Update\6.0\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Visualizations\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\RealNetworks\Msg\Preferences\DBPath\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Preferences\UserDataPath\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [AppPath]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [DestAudioPath]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [DownloadDir]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [MSearchPath]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealJukebox\1.0\Preferences [TempAudioPath]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\CacheFilename\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealMediaSDK\6.0\Preferences\CookiesPath\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\InstallDate\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\Language\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\PluginFilePath\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\PluginHandlerData\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\RemovePluginHandlerData\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\RealPlayer\6.0\Preferences\SystemCookiesPath\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Update\6.0\Preferences\ATH\SkinXML\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\RealNetworks\Update\6.0\Preferences\PluginHandlerData\* [*]</pattern>
          </objectSet>
        </exclude>
        <include>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Real\Msg\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Real\RealPlayer\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Real\RealMediaSDK\* [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Real\Msg\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Real\RealPlayer\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Real\RealMediaSDK\* [*]</pattern>
          </objectSet>
        </merge>

        <!-- Now migrate the visualizations. For XP they are in %ProgramFiles% but for Vista  -->
        <!-- they are in the virtual store. In any case we will put them in the virtual store -->
        <!-- for all migrated users (as would happen if one downloads them on a Win7 system   -->
        <rules>
          <conditions>
            <condition>MigXmlHelper.IsOSLaterThan("NT","6.0")</condition>
          </conditions>
          <include>
            <objectSet>
              <pattern type="File">%VirtualStore_CommonProgramFiles32bit%\Real\Visualizations\* [*]</pattern>
            </objectSet>
          </include>
          <merge script="MigXmlHelper.SourcePriority()">
            <objectSet>
              <pattern type="File">%VirtualStore_CommonProgramFiles32bit%\Real\Visualizations\* [*]</pattern>
            </objectSet>
          </merge>
        </rules>
        <rules>
          <conditions>
            <condition negation="Yes">MigXmlHelper.IsOSLaterThan("NT","6.0")</condition>
          </conditions>
          <include>
            <objectSet>
              <pattern type="File">%CommonProgramFiles32bit%\Real\Visualizations\* [*]</pattern>
            </objectSet>
          </include>
          <locationModify script="MigXmlHelper.RelativeMove('%CommonProgramFiles32bit%\Real\Visualizations','%VirtualStore_CommonProgramFiles32bit%\Real\Visualizations')">
            <objectSet>
              <pattern type="File">%CommonProgramFiles32bit%\Real\Visualizations\* [*]</pattern>
            </objectSet>
          </locationModify>
          <merge script="MigXmlHelper.SourcePriority()">
            <objectSet>
              <pattern type="File">%CommonProgramFiles32bit%\Real\Visualizations\* [*]</pattern>
            </objectSet>
          </merge>
        </rules>
      </rules>
    </role>
  </component>

  <!-- Windows Live -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.wlive">Windows Live</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment name="WLEnv"/>
    <role role="Container">
      <detection name="Mail12"/>
      <detection name="Mail14"/>
      <detection name="Mail15"/>
      <detection name="Messenger"/>
      <detection name="PhotoGallery"/>
      <detection name="Writer"/>

      <!-- Windows Live Common Settings -->
      <component context="User" type="Application">
        <displayName _locID="migapp.wlcommon">Windows Live Common Settings</displayName>
        <role role="Settings">
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Communication Clients\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live Contacts\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows Live\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows Live Contacts\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows Live\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>

      <!-- Windows Live Mail 12 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.wlmail12">Windows Live Mail 12</displayName>
        <environment name="WLMailNotLaunchedEnv"/>
        <environment name="WLMailLaunchedEnv"/>
        <role role="Settings">
          <detection name="Mail12"/>
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live Mail\* [*]</pattern>
                <pattern type="File">%WLMailStoreRoot%\* [*]</pattern>
              </objectSet>
            </include>
            <locationModify script="MigXmlHelper.RelativeMove('HKCU\Software\Microsoft\Windows Live Mail','%WLMailRegistryPath%')">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live Mail\* [*]</pattern>
              </objectSet>
            </locationModify>
            <locationModify script="MigXmlHelper.RelativeMove('%WLMailStoreRoot%','%WLMailDataPath%')">
              <objectSet>
                <pattern type="File">%WLMailStoreRoot%\* [*]</pattern>
              </objectSet>
            </locationModify>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%WLMailStoreRoot%\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>

      <!-- Windows Live Mail 14/15 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.wlmail14">Windows Live Mail</displayName>
        <role role="Settings">
          <detection name="Mail14"/>
          <detection name="Mail15"/>
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live Mail\* [*]</pattern>
                <pattern type="File">%WLMailStoreRoot%\* [*]</pattern>
              </objectSet>
            </include>
            <locationModify script="MigXmlHelper.RelativeMove('%WLMailStoreRoot%','%WLMailStoreRoot%')">
              <objectSet>
                <pattern type="File">%WLMailStoreRoot%\* [*]</pattern>
              </objectSet>
            </locationModify>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%WLMailStoreRoot%\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>

      <!-- Windows Live Messenger -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.wlmessenger">Windows Live Messenger</displayName>
        <role role="Settings">
          <detection name="Messenger"/>
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [AppCompatCanary]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [AppSettings]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [CachedPolicy]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [CachedTCPNatType]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [CachedUDPNatType]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [EnableIdleDetect]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [IntroShownCount]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [MachineGuid]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [MachineName]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [PlayWinks]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [ProtocolHandler]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [ProtocolHandlerLock]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [RtlLogOutput]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [RTCTuned]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [SharePassportCredentials]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [ShowCustomEmoticons]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [ShowEmoticons]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [SNEWS_ContactID]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [SOCKS4Port]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger\PerPassportSettings\*\ [DisableCache]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Messenger\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [FtReceiveFolder]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger\PerPassportSettings\*\ [DisableCache]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [MachineGuid]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\MSNMessenger [MachineName]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Messenger\* [*.log]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Messenger\* [*.txt]</pattern>
                <!-- The 'Shared folders' feature is not supported anymore in Live Messenger 14 -->
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Messenger [activesharingfolder.dat]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Messenger\*\SharingMetadata\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Messenger\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>

      <!-- Windows Live Photo Gallery -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.wlphotogallery">Windows Live Photo Gallery</displayName>
        <role role="Settings">
          <detection name="PhotoGallery"/>
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Acquisition\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery [GalleryScopedFolders]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [AutoSignIn]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [EnableFaceDetection]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [InfoSectionCollapsed]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [LastLogin]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [MetadataSharingSettings]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [OriginalImagesCleanupDays]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [RememberMe]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library [ShowThumbnailInHoverTooltips]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library\PreviewPane\LabelAssignment\MRU [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\Library\Supressed [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\PersonTagMru [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\QuickPublishMru [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Gallery\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Photo Acquisition\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows Live Photo Gallery\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows Photo Gallery\Original Images\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Windows Live Photo Gallery\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>

      <!-- Windows Live Writer -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.wlwriter">Windows Live Writer</displayName>
        <role role="Settings">
          <detection name="Writer"/>
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\LinkGlossary [AutoLinkEnabled]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\LinkGlossary [AutoLinkTermsOnlyOnce]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\LinkGlossary [Initialized]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\Appearance [AppColorScale]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\BlogThis [BlogThisDefaultWeblog]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\BlogThis [CloseWindowOnPublish]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [AllowProviderButtons]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [AllowSettingsAutoUpdate]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [AutomationMode]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [AutoSaveDrafts]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [AutoSaveMinutes]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [CategoryReminder]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [CloseWindowOnPublish]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [FuturePublishDateWarning]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [M1Enabled]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [MainWindowBounds]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [MainWindowLocation]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [MainWindowMaximized]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [MainWindowScale]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [Ping]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [PingUrls]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [PostWindowBehavior]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [ShowPropertiesOnItemInsertion]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [TagReminder]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [TitleReminder]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor [ViewPostAfterPublish]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Autoreplace [Hyphens]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Autoreplace [OtherSpecialCharacters]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Autoreplace [SmartQuotes]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Drafts [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\HtmlEditor\Sidebar [SidebarVisible]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\RecentPosts [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Spelling [CheckSpellingBeforePublish]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Spelling [DictionaryLanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Spelling [IgnoreNumbers]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Spelling [IgnoreUppercase]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\Spelling [RealTimeSpellChecking]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\PostEditor\WordCount [ShowWordCount]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\Preferences\WebProxy [Port]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows Live\Writer\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Windows Live Writer\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Windows Live Writer\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Windows Live Writer\blogtemplates\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Windows Live Writer\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Windows Live Writer\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>
    </role>
  </component>

  <!-- QuickTime Player (5, 6 and 7) -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.quicktimeplayer">QuickTime Player</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="QuickTimeExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\QuickTimePlayer.exe []")</script>
      </variable>
    </environment>
    <environment context="System">
      <variable name="QuickTimeDataSystem">
        <text>%CSIDL_COMMON_APPDATA%\Apple Computer\QuickTime</text>
      </variable>
      <variable name="QuickTimeDataSystem">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Apple Computer, Inc.\QuickTime\SystemPreferences [FolderPath]","No"," "," \")</script>
      </variable>
    </environment>
    <environment context="User">
      <variable name="QuickTimeDataUser1">
        <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Apple Computer, Inc.\QuickTime\LocalUserPreferences [FolderPath]","No"," "," \")</script>
      </variable>
    </environment>
    <environment context="User">
      <conditions>
        <condition negation="Yes">MigXmlHelper.IsOSLaterThan("NT","6.0")</condition>
      </conditions>
      <variable name="QuickTimeDataUser2">
        <text>%CSIDL_APPDATA%\Apple Computer\QuickTime</text>
      </variable>
    </environment>
    <environment context="User">
      <conditions>
        <condition>MigXmlHelper.IsOSLaterThan("NT","6.0")</condition>
      </conditions>
      <variable name="QuickTimeDataUser2">
        <text>%CSIDL_LOCAL_APPDATA%\Apple Computer\QuickTime</text>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%QuickTimeExe%","ProductVersion","QuickTime 5.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%QuickTimeExe%","ProductVersion","QuickTime 6.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%QuickTimeExe%","ProductVersion","QuickTime 7.*")</condition>
        </detect>
      </detects>
      <rules context="System">
        <include>
          <objectSet>
            <pattern type="File">%QuickTimeDataSystem%\* [*]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%QuickTimeDataSystem%','%QuickTimeDataSystem%')">
          <objectSet>
            <pattern type="File">%QuickTimeDataSystem%\* [*]</pattern>
          </objectSet>
        </locationModify>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%QuickTimeDataSystem%\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">%HklmWowSoftware%\Apple Computer, Inc.\QuickTime\Favorite Movies\* [*]</pattern>
            <pattern type="Registry">%HklmWowSoftware%\Apple Computer, Inc.\QuickTime\Recent Movies\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Apple Computer, Inc.\QuickTime\Favorite Movies\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Apple Computer, Inc.\QuickTime\Recent Movies\* [*]</pattern>
            <pattern type="File">%QuickTimeDataUser1%\* [*]</pattern>
            <pattern type="File">%QuickTimeDataUser2%\* [*]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%\Apple Computer, Inc.\QuickTime','HKCU\Software\Classes\VirtualStore\MACHINE\SOFTWARE\Apple Computer, Inc.\QuickTime')">
          <objectSet>
            <pattern type="Registry">%HklmWowSoftware%\Apple Computer, Inc.\QuickTime\Favorite Movies\* [*]</pattern>
            <pattern type="Registry">%HklmWowSoftware%\Apple Computer, Inc.\QuickTime\Recent Movies\* [*]</pattern>
          </objectSet>
        </locationModify>
        <locationModify script="MigXmlHelper.RelativeMove('%QuickTimeDataUser1%','%QuickTimeDataUser1%')">
          <objectSet>
            <pattern type="File">%QuickTimeDataUser1%\* [*]</pattern>
          </objectSet>
        </locationModify>
        <locationModify script="MigXmlHelper.RelativeMove('%QuickTimeDataUser2%','%QuickTimeDataUser2%')">
          <objectSet>
            <pattern type="File">%QuickTimeDataUser2%\* [*]</pattern>
          </objectSet>
        </locationModify>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%QuickTimeDataUser1%\* [*]</pattern>
            <pattern type="File">%QuickTimeDataUser2%\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- iTunes (6, 7 and 8) -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.iTunes">iTunes</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="ITunesExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\ITunes.exe []")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%ITunesExe%","ProductVersion","6.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%ITunesExe%","ProductVersion","7.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%ITunesExe%","ProductVersion","8.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Apple Computer, Inc.\iTunes\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Apple Computer\iTunes\ [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\iTunes\* [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Apple Computer\iTunes\ [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\iTunes\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Microsoft Office 2003 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.msoffice2003">Microsoft Office 2003</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="OFFICEVERSION">
        <text>11.0</text>
      </variable>
    </environment>
    <role role="Container">
      <detection name="Word" />
      <detection name="Excel" />
      <detection name="PowerPoint" />
      <detection name="FrontPage" />
      <detection name="Access" />
      <detection name="Publisher" />
      <detection name="Outlook" />
      <detection name="Visio" />
      <detection name="Project2003"/>
      <detection name="OneNote"/>
      <!-- Office 2003 Common Settings -->
      <component context="UserAndSystem" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office2003common">Office 2003 Common Settings</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Office</text>
          </variable>
        </environment>
        <role role="Settings">
          <rules context="UserAndSystem">
            <!-- From AnyOfficeProduct -->
            <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\Custom Dictionaries [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\Recent [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Proof\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_APPDATA%\Microsoft\Proof')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\Custom Dictionaries [*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\1.0\Custom Dictionaries\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Shortcut Bar [LocalPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [LocationOfComponents]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Open Find\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [UseRWHlinkNavigation]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\InternetServer Cache\* [*]</pattern>
              </objectSet>
            </exclude>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Migration\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet\DoNotCheckIfOfficeIsHTMLEditor\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [AllowPNG]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [RelyOnVML]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [SaveNewWebPagesAsWebArchives]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars [BtnSize]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars [Tooltips]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars [AdaptiveMenus]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars [Animation]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars [ShowKbdShortcuts]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars [FontView]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\Proofing Tools\1.0\Custom Dictionaries\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [AlwaysSaveInDefaultEncoding]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [DoNotCheckIfOfficeIsHTMLEditor]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [DoNotRelyOnCSS]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [DoNotUpdateLinksOnSave]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [DownloadComponents]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [Encoding]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [ScreenSize]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Internet [ShowSlideAnimation]</pattern>
              </objectSet>
            </destinationCleanup>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Access 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.access2003">Microsoft Office Access 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Access</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Access" />
          <rules context="User">
            <!--  copy files -->
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\CMA\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings\ [Microsoft Access]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Access\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Access\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRU1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRU2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRU3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRU4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRU5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRU6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRUFlags1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRUFlags2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRUFlags3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRUFlags4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRUFlags5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Settings [MRUFlags6]</pattern>
              </objectSet>
            </exclude>
            <!-- force src -->
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access11.pip]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Access\Options [Default Database Directory]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Excel 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.excel2003">Microsoft Office Excel 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Excel</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Excel" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Excel\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings\ [Microsoft Excel]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Excel\ [EXCEL11.xlb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [EXCEL11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Excel\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Excel\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Excel\Recent Files\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Excel\Options\ [AltStartup]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Excel\Options\ [DefaultPath]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Excel\ [EXCEL11.xlb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [EXCEL11.pip]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office FrontPage 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.frontpage2003">Microsoft Office FrontPage 2003</displayName>
        <role role="Settings">
          <detection name="FrontPage" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\FrontPage\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings [Microsoft FrontPage]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\FrontPage\State [CmdUI.PRF]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [fp11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\FrontPage\Snippets [FPSnippetsCustom.xml]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\FrontPage [WecErrorLog]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\FrontPage\Explorer\FrontPage Explorer\Recent File List\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\FrontPage\Explorer\FrontPage Explorer\Recent Web List\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\FrontPage\State [CmdUI.PRF]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [fp11.pip]</pattern>
              </objectSet>
            </merge>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\FrontPage\Editor\DoNotCheckifFrontPageisDefaultHTMLEditor\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
          </rules>
        </role>
      </component>

      <!-- Microsoft Office Outlook 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.outlook2003">Microsoft Office Outlook 2003</displayName>
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
          <rules name="OutlookPstPab" />
          <rules context="User">
            <!-- addreg -->
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings [Microsoft Outlook]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Outlook\Journal\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Outlook\Journal\* [*]</pattern>
                  </objectSet>
                </content>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Signatures\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Stationery\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd11.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [views.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [OutlPrint]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSOut11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.NK2]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.xml]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Exchange\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001e023d]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001e023d]</pattern>
                  </objectSet>
                </content>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001f023d]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001f023d]</pattern>
                  </objectSet>
                </content>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [*]</pattern>
              </objectSet>
            </include>
            <!-- delreg -->
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Outlook [FirstRunDialog]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Outlook [Machine Name]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\*\0a0d020000000000c000000000000046 [111f031e]</pattern>
                <pattern type="Registry">HKCU\Identities\* [LDAP Server]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Internet Account Manager\Accounts\* [LDAP Server]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [LDAP Server]</pattern>
              </objectSet>
            </exclude>
            <!-- destdelreg -->
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [Connection Flags]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [Connection Type]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [Connectoid]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles [DefaultProfile]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Outlook\Setup\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <!-- forcesrcfile -->
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd11.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [views.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSOut11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.xml]</pattern>
              </objectSet>
            </merge>
            <!-- Outlook ForceDestFile -->
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office PowerPoint 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.powerpoint2003">Microsoft Office PowerPoint 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>PowerPoint</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="PowerPoint" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\RecentFolderList [Default]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings [Microsoft PowerPoint]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Powertpoint\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Powerpoint\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Recent File List\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\RecentFolderList\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\RecentFolderList [Default]</pattern>
              </objectSet>
            </merge>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Internet [HTMLVersion]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [AutoKeyboard Switching]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [BackgroundPrint]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [DisableNewAnimationUI]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [DisablePasswordUI]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [MaxNumberDesigns]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [Send TrueType fonts as bitmaps]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\PowerPoint\Options [Send printer information to OLE servers]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint [PPT11.pcb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [PowerP11.pip]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint [PPT11.pcb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [PowerP11.pip]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Publisher 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.publisher2003">Microsoft Office Publisher 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Publisher</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Publisher" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Publisher\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings [Microsoft Publisher]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher [pubcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Publis11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [*.jsp]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Publisher\Recent File List\* [*]</pattern>
              </objectSet>
            </exclude>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Publisher\UserInfo\* [FullName]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Publisher\UserInfo\* [CompanyName]</pattern>
              </objectSet>
            </destinationCleanup>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher [pubcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Publis11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.jsp]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Word 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.word2003">Microsoft Office Word 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Word" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Common\Toolbars\Settings [Microsoft Word]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [Normal.dot]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Word11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [WordMa11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Word\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Word\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Word\Data\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\11.0\Word\Options [PROGRAMDIR]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates [Normal.dot]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Word11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [WordMa11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office SmartTags -->
      <component context="User" type="Application" hidden="TRUE">
        <displayName _locID="migapp.smarttag2003">Microsoft Office SmartTags</displayName>
        <role role="Container">
          <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
          <detection name="MicrosoftListsSmartTags2003" />
          <detection name="MicrosoftPlaceSmartTags" />
          <!-- Microsoft Outlook Email Recipients SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.emailsmarttag2003">Microsoft Outlook Email Recipients SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
              <rules>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}\* [*]</pattern>
                  </objectSet>
                </include>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
              </rules>
            </role>
          </component>

          <!-- Microsoft Lists SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.listsmarttag2003">Microsoft Lists SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftListsSmartTags2003" />
              <rules>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </include>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
              </rules>
            </role>
          </component>

          <!-- Microsoft Place SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.placesmarttag2003">Microsoft Place SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftPlaceSmartTags" />
              <rules>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}\* [*]</pattern>
                  </objectSet>
                </include>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
              </rules>
            </role>
          </component>

        </role>
      </component>

      <!-- Microsoft Office Visio 2003 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.visio2003">Microsoft Office Visio 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Visio</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Visio" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\* [*]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Common\Toolbars\Settings\ [Microsoft Office Visio]</pattern>
                <pattern type="File">CSIDL_APPDATA\Microsoft\Office\ [Visio11.pip]</pattern>
                <pattern type="File">CSIDL_LOCAL_APPDATA\Microsoft\Visio\ [content.dat]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Visio\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Visio\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\Application\ [LastFile*]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\Application\ [MyShapesPath]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\Application\ [UserDictionaryPath1]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Visio11.pip]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\ [content.dat]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Project 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.project2003">Microsoft Project 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>MS Project</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Project2003" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Common\Toolbars\Settings [Microsoft Project]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSProj11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\11\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSProj11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\11\* [*]</pattern>
              </objectSet>
            </merge>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\Recent File List [*]</pattern>
              </objectSet>
            </exclude>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office OneNote 2003 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.onenote2003">Microsoft Office OneNote 2003</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="OneNote" />
          <rules context="User">
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\OneNote\* [*]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Common\LanguageResources [SKULanguage]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\OneNote\* [*]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Common\Toolbars\Settings\ [Microsoft Office OneNote]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [OneNot11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\ [Preferences.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\ [Toolbars.dat]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\OneNote\Options\Save\ [BackupLastAutoBackupTime]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\OneNote\Options\Save\ [BackupFolderPath]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\OneNote\General\ [LastCurrentFolderForBoot]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\OneNote\General\ [Last Current Folder]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [OneNot11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\ [Preferences.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\ [Toolbars.dat]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2003to2007SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade" />
          <rules name="Office2003to14SettingsUpgrade_x64" />
          <rules name="Office2003to15SettingsUpgrade" />
          <rules name="Office2003to15SettingsUpgrade_x64" />
        </role>
      </component>
    </role>
  </component>

  <!-- Microsoft Office 2007 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.office2007">Microsoft Office 2007</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="OFFICEVERSION">
        <text>12.0</text>
      </variable>
    </environment>
    <role role="Container">
      <detection name="Word"/>
      <detection name="PowerPoint"/>
      <detection name="Access"/>
      <detection name="Excel"/>
      <detection name="Outlook"/>
      <detection name="Publisher"/>
      <detection name="Visio"/>
      <detection name="Project2007"/>
      <detection name="OneNote"/>

      <!-- Office 2007 Common Settings -->
      <component context="UserAndSystem" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office2007common">Office 2007 Common Settings</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Office</text>
          </variable>
        </environment>
        <role role="Settings">
          <!-- For Office 2007 -->
          <rules context="User">
            <!-- From AnyOfficeProduct -->
            <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Shared Tools\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\Recent [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
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
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Shortcut Bar [LocalPath]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Internet [LocationOfComponents]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Open Find\* [*]</pattern>
              </objectSet>
            </exclude>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Internet\DoNotCheckIfOfficeIsHTMLEditor\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Internet [AllowPNG]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Internet [RelyOnVML]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Internet [SaveNewWebPagesAsWebArchives]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars [BtnSize]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars [Tooltips]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars [AdaptiveMenus]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars [Animation]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars [ShowKbdShortcuts]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars [FontView]</pattern>
              </objectSet>
            </destinationCleanup>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
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
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Access 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007access">Microsoft Office Access 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Access</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Access"/>
          <rules>
            <!--  copy files -->
            <include>
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\CMA\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars\Settings\ [Microsoft Access]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Access\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRU1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRU2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRU3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRU4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRU5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRU6]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRUFlags1]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRUFlags2]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRUFlags3]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRUFlags4]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRUFlags5]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Settings [MRUFlags6]</pattern>
              </objectSet>
            </exclude>
            <!-- force src -->
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Access11.pip]</pattern>
              </objectSet>
            </merge>
            <!-- force dest -->
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Access\Options [Default Database Directory]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Excel 2007 -->
      <component  context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007excel">Microsoft Office Excel 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Excel</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Excel"/>
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Excel\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars\Settings\ [Microsoft Excel]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Excel\ [EXCEL11.xlb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [EXCEL11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Excel\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Excel\Recent Files\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Excel\Options\ [AltStartup]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Excel\Options\ [DefaultPath]</pattern>
              </objectSet>
            </merge>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Excel\ [EXCEL11.xlb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [EXCEL11.pip]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Outlook 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007outlook">Microsoft Office Outlook 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Outlook</text>
          </variable>
          <variable name="OUTLOOKPROFILESPATH">
            <text>HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Outlook"/>
          <rules name="OutlookPstPab" />
          <rules context="User">
            <!-- addreg -->
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Outlook\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars\Settings [Microsoft Outlook]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [*]</pattern>

                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Office [*.officeUI]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Signatures\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Stationery\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd11.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [views.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [OutlPrint]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office  [MSOut11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Exchange\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.NK2]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.xml]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'%CSIDL_LOCAL_APPDATA%\Microsoft\Outlook')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Outlook\Journal\* [*]</pattern>
                  </objectSet>
                </content>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001e023d]</pattern>
                    <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\* [001f023d]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <!-- delreg -->
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Outlook [FirstRunDialog]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Outlook [Machine Name]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\*\0a0d020000000000c000000000000046 [111f031e]</pattern>
                <pattern type="Registry">HKCU\Identities\* [LDAP Server]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Internet Account Manager\Accounts\* [LDAP Server]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [LDAP Server]</pattern>
              </objectSet>
            </exclude>
            <!-- destdelreg -->
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [Connection Flags]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [Connection Type]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\Outlook\OMI Account Manager\Accounts\* [Connectoid]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles [DefaultProfile]</pattern>
              </objectSet>
            </destinationCleanup>
            <!-- forcesrcfile -->
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\FORMS [frmcache.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd11.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [outcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [views.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSOut11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.srs]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.xml]</pattern>
              </objectSet>
            </merge>
            <!-- Outlook ForceDestFile -->
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Outlook [*.rwz]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules context="System">
            <!-- addreg -->
            <include>
              <objectSet>
                <pattern type="Registry">%HklmWowSoftware%\Clients\Mail\Microsoft Outlook [MSIComponentID]</pattern>
                <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Outlook\Setup [MailSupport]</pattern>
              </objectSet>
            </include>
            <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
              <objectSet>
                <pattern type="Registry">%HklmWowSoftware%\Clients\Mail\Microsoft Outlook [MSIComponentID]</pattern>
                <pattern type="Registry">%HklmWowSoftware%\Microsoft\Office\12.0\Outlook\Setup [MailSupport]</pattern>
              </objectSet>
            </locationModify>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office PowerPoint 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007powerpoint">Microsoft Office PowerPoint 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Powerpoint</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="PowerPoint"/>
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\RecentFolderList [Default]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars\Settings [Microsoft PowerPoint]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint [PPT11.pcb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [PowerP11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Powerpoint\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Recent File List\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\RecentFolderList\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.DestinationPriority()">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\RecentFolderList [Default]</pattern>
              </objectSet>
            </merge>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Internet [HTMLVersion]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [AutoKeyboard Switching]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [BackgroundPrint]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [DisableNewAnimationUI]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [DisablePasswordUI]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [MaxNumberDesigns]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [Send TrueType fonts as bitmaps]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\PowerPoint\Options [Send printer information to OLE servers]</pattern>
              </objectSet>
            </destinationCleanup>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\PowerPoint [PPT11.pcb]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [PowerP11.pip]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Publisher 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007publisher">Microsoft Office Publisher 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Publisher</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Publisher"/>
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Publisher\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars\Settings [Microsoft Publisher]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Publis11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [*.jsp]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [pg_custom.xml]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher [pubcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher [custcols.scm]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\BusinessInfo\* [*]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Publisher\Content Library\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher\Font Schemes\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Publisher\Recent File List\* [*]</pattern>
              </objectSet>
            </exclude>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Publisher\UserInfo\* [FullName]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Publisher\UserInfo\* [CompanyName]</pattern>
              </objectSet>
            </destinationCleanup>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.acl]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher [pubcmd.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Publis11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [*.jsp]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Publisher Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office Word 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007word">Microsoft Office Word 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Word</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Word"/>
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Word\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Common\Toolbars\Settings [Microsoft Word]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Bibliography\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Word11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [WordMa11.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Word\File MRU\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Word\Data\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\12.0\Word\Options [PROGRAMDIR]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\QuickStyles\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [Word11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [WordMa11.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Document Building Blocks\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office SmartTags -->
      <component context="User" type="Application" hidden="TRUE">
        <displayName _locID="migapp.office2007smarttag">Microsoft Office SmartTags</displayName>
        <role role="Container">
          <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
          <detection name="MicrosoftListsSmartTags2007" />
          <detection name="MicrosoftPlaceSmartTags" />

          <!-- Microsoft Outlook Email Recipients SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office2007emailsmarttag">Microsoft Outlook Email Recipients SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftOutlookEmailRecipientsSmartTags" />
              <rules>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9}\* [*]</pattern>
                  </objectSet>
                </include>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{4FFB3E8B-AE75-48F2-BF13-D0D7E93FA8F9} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
              </rules>
            </role>
          </component>

          <!-- Microsoft Lists SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office2007listsmarttag">Microsoft Lists SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftListsSmartTags2007" />
              <rules>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </include>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{64AB6C69-B40E-40AF-9B7F-F5687B48E2B6}\* [*]</pattern>
                  </objectSet>
                </destinationCleanup>
              </rules>
            </role>
          </component>

          <!-- Microsoft Place SmartTags -->
          <component context="User" type="Application">
            <displayName _locID="migapp.office2007placesmarttag">Microsoft Place SmartTags</displayName>
            <role role="Settings">
              <detection name="MicrosoftPlaceSmartTags" />
              <rules>
                <include>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888}\* [*]</pattern>
                  </objectSet>
                </include>
                <destinationCleanup>
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\Common\Smart Tag\Recognizers\{87EF1CFE-51CA-4E6B-8C76-E576AA926888} [*]</pattern>
                  </objectSet>
                </destinationCleanup>
              </rules>
            </role>
          </component>

        </role>
      </component>

      <!-- Microsoft Office Visio 2007 -->
      <component type="Application" context="UserAndSystem">
        <displayName _locID="migapp.visio2007">Microsoft Office Visio 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Visio</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Visio" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\* [*]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Common\Toolbars\Settings\ [Microsoft Office Visio]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Visio12.pip]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\ [content.dat]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Visio\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Visio\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\Application\ [LastFile*]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\Application\ [MyShapesPath]</pattern>
                <pattern type="Registry">HKCU\software\Microsoft\Office\%OFFICEVERSION%\Visio\Application\ [UserDictionaryPath1]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [Visio12.pip]</pattern>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Visio\ [content.dat]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Project 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.project2007">Microsoft Project 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>Project</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="Project2007" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Common\Toolbars\Settings [Microsoft Office Project]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSProj12.pip]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\Recent Templates\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\MS Project\Recent File List [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office [MSProj12.pip]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>

      <!-- Microsoft Office OneNote 2007 -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.office2007onenote">Microsoft Office OneNote 2007</displayName>
        <environment>
          <variable name="OFFICEPROGRAM">
            <text>OneNote</text>
          </variable>
        </environment>
        <role role="Settings">
          <detection name="OneNote"/>
          <rules>
            <destinationCleanup>
              <objectSet>
                <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\OneNote\%OFFICEVERSION%\ [OneNoteOfflineCache.onecache]</pattern>
              </objectSet>
            </destinationCleanup>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\Common\Toolbars\Settings\ [Microsoft Office OneNote]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [OneNot12.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\%OFFICEVERSION%\ [Preferences.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\%OFFICEVERSION%\ [Toolbars.dat]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\Recent Templates\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\12\* [*]</pattern>
                <content filter="MigXmlHelper.ExtractSingleFile(NULL,'NULL')">
                  <objectSet>
                    <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\Recent Templates\* [Template*]</pattern>
                  </objectSet>
                </content>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\Office\ [OneNot12.pip]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\%OFFICEVERSION% [Preferences.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\OneNote\%OFFICEVERSION% [Toolbars.dat]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Microsoft\MS Project\12\* [*]</pattern>
              </objectSet>
            </merge>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\General\ [LastMyDocumentsPathUsed]</pattern>
                <pattern type="Registry">HKCU\Software\Microsoft\Office\%OFFICEVERSION%\OneNote\Options\Paths\ [BackupFolderPath]</pattern>
              </objectSet>
            </exclude>
          </rules>
          <rules name="Office2007to14SettingsUpgrade" />
          <rules name="Office2007to14SettingsUpgrade_x64" />
          <rules name="Office2007to15SettingsUpgrade" />
          <rules name="Office2007to15SettingsUpgrade_x64" />
        </role>
      </component>
    </role>
  </component>

  <!-- WinZip -->
  <component context="User" type="Application">
    <displayName _locID="migapp.winzip">WinZip</displayName>
    <environment>
      <variable name="HklmWowSoftware">
        <text>HKLM\Software</text>
      </variable>
      <variable name="WinZip8or9or10Exe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\winzip32.exe []")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Nico Mak Computing\WinZip\WinIni [win32_version]")</condition>
        </detect>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WinZip8or9or10Exe%","ProductVersion","8.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WinZip8or9or10Exe%","ProductVersion","9.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%WinZip8or9or10Exe%","ProductVersion","10.*")</condition>

        </detect>
      </detects>
      <rules>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\fm\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\ListView\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\ToolBar\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WIZARD\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\wzshlext\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Adjustable]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [AltDrag]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [AlwaysOnTop]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [AnimatedBusy]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [AutoOpen]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Beep]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [CheckOutIconOnly]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [CheckOutScan]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ExplorerButtons]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Extract95]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ExtractSkipOlder]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [FilterIndex]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [GrayButtons]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [IBS]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [LastTip]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Lower]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [MRUSize]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [QuikviewSeen]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [RecycleBin]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ReuseWindows]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Setup]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ShowTips]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [SpanDefault]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ViewerFont]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Wizard]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [256ColorBtn]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [FlatBtns]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [LargeBtn]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [PromptView]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ShowBtnText]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ShowComment]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [SmartDoc]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [TarCrLf]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ThemeInstaller]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [ToolTips]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\directories [gzAddDir]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\directories [gzExtractTo]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\directories [zDefDir]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\directories [ZipTempRemovableOnly]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\ListView\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\fm\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\ToolBar\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WIZARD\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\wzshlext\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Display]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Main]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WinZip [Viewdir]</pattern>
            <pattern type="Registry">HKCU\Software\Nico Mak Computing\WinZip\WIZARD [ExtractTo]</pattern>
          </objectSet>
        </exclude>
      </rules>
    </role>
  </component>

  <!-- Adobe Reader 9.0 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.adobereader7">Adobe Acrobat Reader</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>

    <environment>
      <variable name="AdobeReaderInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Adobe\Acrobat Reader\9.0\Installer [Path]")</script>
      </variable>
    </environment>

    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Adobe\Acrobat Reader")</condition>
        </detect>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%AdobeReaderInstPath%\Reader\AcroRd32.exe","ProductVersion","9.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bCacheFormData]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bFullScreenClick]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bOpenInPlace]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bAllowOpenFile]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bSaveAsLinearized]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bAllowByteRangeRequests]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bBrowserIntegration]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bDownloadEntireFile]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bAntialiasGraphics]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bAntialiasImages]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bAntialiasText]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bShowLargeDIBS]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bUseLogicalPageNumbers]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bDisplayAboutDialog]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bDisplayedSplash]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bEmitPostScriptXObjects]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [benableDDR]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bFullScreenIgnoreTrans]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bGreekText]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bIgnorePageClip]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bOverPrintPreview]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bUsePageCache]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bUseSlideTimer]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bUseSysSetting]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [bWrapSlideShowPages]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iTrustedMode]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iDefaultZoomType]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iDefaultZoomScale]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iPixelsPerInch]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iAccessColorPolicy]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iAntialiasThreshold]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iPixelsPerInch]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Originals [iDefaultMaxThreadZoom]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bDocAttachmentStatus]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bDocCertifiedStatus]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bDocOCGStatus]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bDocSecurityStatus]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bDocSignatureStatus]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bDocUserPropertiesStatus]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\DocumentStatus [bSuppressStatusDialog]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessBackgroundColorBlue]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessBackgroundColorGreen]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessBackgroundColorRed]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessColorPolicy]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessMaxDocModePages]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessOverrideDocColors]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessPageMode]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessTextColorBlue]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessTextColorGreen]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AccessTextColorRed]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AllowByteRangeRequests]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AllowOpenFile]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AntialiasGraphics]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AntialiasImages]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AntialiasThreshold]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [AntialiasText]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [BrowserCheck]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [DisplayAboutDialog]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [DefaultMaxThreadZoom]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [DefaultSlideTimer]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [DefaultZoomScale]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [DefaultZoomType]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [DownloadEntireFile]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [enableDDR]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenClick]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenColorBlue]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenColorGreen]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenColorRed]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenCursor]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenEscape]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [FullScreenTransitionType]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [Gamma]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [GreekText]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [GreekThreshold]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [IgnorePageClip]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [NoteFontName]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [NotePointSize]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [OpenInPlace]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [PageUnits]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [PageViewLayoutMode]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [TransparencyGrid]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [TrustedMode]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [UpdateFrequency]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [UseLogicalPageNumbers]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [UsePageCache]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [UseSlideTimer]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AdobeViewer [WrapSlideShowPages]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\AVGeneral\cToolbars\* [bHidden]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Adobe\Acrobat\9.0\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Adobe Acrobat\9.0\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\Installer\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Acrobat Reader\9.0\InstallPath\* [*]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Adobe\Acrobat\9.0\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Adobe Creative Suite 2 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.adobecs2">Adobe Creative Suite 2</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="PhotoshopSuite8Path">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Adobe\Photoshop\8.0 [ApplicationPath]")</script>
      </variable>
    </environment>
    <role role="Container">
      <detects name="AdobePhotoshopCS" />
      <detects name="AdobeImageReadyCS" />

      <!-- Adobe Photoshop CS -->
      <component context="UserAndSystem" type="Application">
        <displayName _locID="migapp.adobephotoshop">Adobe Photoshop CS</displayName>
        <environment context="User">
          <variable name="Photoshop8PersonalSettings">
            <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Adobe\Photoshop\8.0\ [SettingsFilePath]")</script>
          </variable>
        </environment>
        <environment context="System">
          <variable name="Photoshop8CommonColor">
            <text>%COMMONPROGRAMFILES%\Adobe\Color</text>
          </variable>
        </environment>
        <role role="Settings">
          <detects name="AdobePhotoshopCS" />
          <rules context="User">
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Adobe\Photoshop\8.0 [*]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\Lens Blur\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\Liquify\CS\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\Filter Gallery\CS\Photoshop\* [*]</pattern>
                <!-- changed %Photoshop8PersonalSettings%\* to %Photoshop8PersonalSettings%*
                                     as engine fail if %Photoshop8PersonalSettings% contains a '\' at the end.
                                     This has to be undone once the issue is fixed in engine.-->
                <pattern type="File">%Photoshop8PersonalSettings%* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Adobe\Photoshop\8.0 [AppWindowPosition]</pattern>
              </objectSet>
            </exclude>
            <destinationCleanup>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Adobe\Photoshop\8.0 [AppWindowMaximized]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\Photoshop\8.0 [ShowStatusWindow]</pattern>
              </objectSet>
            </destinationCleanup>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <!-- changed %Photoshop8PersonalSettings%\* to %Photoshop8PersonalSettings%*
                                     as engine fail if %Photoshop8PersonalSettings% contains a '\' at the end.
                                     This has to be undone once the issue is fixed in engine.-->
                <pattern type="File">%Photoshop8PersonalSettings%* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
          <rules context="System">
            <include>
              <objectSet>
                <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\8.0\Registration [COMPAN]</pattern>
                <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\8.0\Registration [NAME]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\* [*]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Proofing\* [*]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\* [*]</pattern>
                <!-- changed %Photoshop8PersonalSettings%\* to %Photoshop8PersonalSettings%*
                                     as engine fail if %Photoshop8PersonalSettings% contains a '\' at the end.
                                     This has to be undone once the issue is fixed in engine.-->
                <pattern type="File">%PhotoshopSuite8Path%\Presets\* [*]</pattern>
              </objectSet>
            </include>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\* [*]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Proofing\* [*]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\* [*]</pattern>
                <!-- changed %Photoshop8PersonalSettings%\* to %Photoshop8PersonalSettings%*
                                     as engine fail if %Photoshop8PersonalSettings% contains a '\' at the end.
                                     This has to be undone once the issue is fixed in engine.-->
                <pattern type="File">%PhotoshopSuite8Path%\Presets\* [*]</pattern>
              </objectSet>
            </merge>
            <exclude>
              <objectSet>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [CIERGB.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [JapanStandard.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [NTSC1953.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [PAL_SECAM.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [pcd4050e.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [pcd4050k.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [pcdcnycc.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [pcdekycc.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [pcdkoycc.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [Photoshop4DefaultCMYK.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [Photoshop5DefaultCMYK.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [ProPhoto.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [Recommended]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [SMPTE-C.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [stdpyccl.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\ [WideGamutRGB.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [AdobeRGB1998.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [AppleRGB.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [ColorMatchRGB.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [EuroscaleCoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [EuroscaleUncoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [JapanColor2001Coated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [JapanColor2001Uncoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [JapanWebCoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [sRGB Color Space Profile.icm]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [USSheetfedCoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [USSheetfedUncoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [USWebCoatedSWOP.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Profiles\Recommended\ [USWebUncoated.icc]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [Color Management Off.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [Emulate Photoshop 4.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [EU General Purpose Defaults.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [Europe Prepress Defaults.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [Japan Color Prepress.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [JP General Purpose Defaults.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [NA General Purpose Defaults.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [Photoshop 5 Default Spaces.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [US Prepress Defaults.csf]</pattern>
                <pattern type="File">%Photoshop8CommonColor%\Settings\ [Web Graphics Defaults.csf]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\Adobe Photoshop Only\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Assorted Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Basic Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Calligraphic Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Drop Shadow Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Faux Finish Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Natural Brushes 2.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Natural Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\ [Square Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\Adobe Photoshop Only\ [Dry Media Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\Adobe Photoshop Only\ [Special Effect Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\Adobe Photoshop Only\ [Thick Heavy Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Brushes\Adobe Photoshop Only\ [Wet Media Brushes.abr]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [VisiBone Read Me.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [DIC Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [FOCOLTONE Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (Coated).aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (Process).aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (ProSim).aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (Uncoated).aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TOYO Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TRUMATCH Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [ANPA Color.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [DIC Color Guide.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [FOCOLTONE.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS E Process.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS E.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS K Process.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS K.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS N Process.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS N.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS Z Process.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [HKS Z.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE metallic coated.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE pastel coated.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE pastel uncoated.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE process coated.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE solid coated.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE solid matte.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE solid to process EURO.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE solid to process.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [PANTONE solid uncoated.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [TOYO Color Finder.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [TOYO Process Color Finder.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Books\ [TRUMATCH.acb]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [Mac OS.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [VisiBone ReadMe.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [VisiBone.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [VisiBone2.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [Web Hues.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [Web Safe Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [Web Spectrum.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\ [Windows.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [ANPA Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [DIC Color Guide.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [DIC Swatch ReadMe.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [FOCOLTONE Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS E Process.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS E.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS K Process.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS K.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS N Process.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS N.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS Z Process.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS Z.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE metallic coated.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE pastel coated.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE pastel uncoated.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE process coated.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid coated.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid matte.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid to process EURO.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid to process.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid uncoated.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Photo Filter Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TOYO Color Finder.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TOYO Process Color Finder.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TRUMATCH Colors.aco]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Contours\ [Contours.shc]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [All.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Animals.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Arrows.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Banners.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Frames.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Music.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Nature.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Objects.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Ornaments.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Shapes.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Symbols.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [TalkBubbles.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Tiles.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Custom Shapes\ [Web.csh]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotone\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [423-1.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [423-2.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [423-3.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 1.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 2.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 3.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 4.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 1.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 2.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 3.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 4.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 1.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 2.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 3.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 4.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 8 bl 1.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 8 bl 2.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 8 bl 3.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 8 bl 4.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange bl 80% shad.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [478 brown (100%) bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [478 brown (100%) bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [478 brown (100%) bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [478 brown (100%) bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 286 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 286 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 286 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 286 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 485 bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 485 bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 485 bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 485 bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl CG10 CG4 WmG3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl CG10 WmG3 CG1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl CG10 WmG4 CG3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl WmG9 CG6 CG3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 430 493 557.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 431 492 556.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 541 513 5773.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 75% 50% 25%.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK blue.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK brown.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK cool.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK ext wm.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK neutral.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK wm.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl 404 WmGray 401 WmGray.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl 409 WmGray 407 WmGray.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl Cool Gray 10 WmGray 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl WmGray 7 WmGray 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-1.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-2.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-3.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-4.ADO]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 165 red orange 457 brown.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 172 orange 423 gray.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 313 aqua 127 gold.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 334 green 437 mauve.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 340 green 423 gray.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 437 burgundy 127 gold.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 50% 25%.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 1.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 2.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 3.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 4.ado]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Color Harmonies 1.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Color Harmonies 2.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Metals.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Noise Samples.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Pastels.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Simple.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Special Effects.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Gradients\ [Spectrums.grd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [1stFiveBySevens.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [EightByTen.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndSmaller.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndThreeByFive.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndThreeByThreeH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndThreeH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndTwoByTwoH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndTwoH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FiveBySevenAndTwoHByThreeH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FourByFives.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FourByFivesAndSmaller.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FourByFivesAndTwoByTwoH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [FourByFivesAndTwoHByThreeH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [ReadMe.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [TenByThirteen.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [ThreeHByFive.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [TwoByTwo.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [TwoByTwoH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [TwoHByThreeH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [TwoHByThreeHAndTwoByTwoH.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Layouts\ [TwoHByThreeQ.txt]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Colors\ [Black &amp; White.act]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Colors\ [Grayscale.act]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Colors\ [Mac OS.act]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Colors\ [Windows.act]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Output Settings\ [Background Image.iros]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Output Settings\ [Default Settings.iros]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Output Settings\ [XHTML.iros]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF 128 Dithered.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF 128 No Dither.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF 32 Dithered.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF 32 No Dither.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF 64 Dithered.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF 64 No Dither.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [GIF Restrictive.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [JPEG High.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [JPEG Low.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [JPEG Medium.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [PNG-24.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Optimized Settings\ [PNG-8 128 Dithered.irs]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Artist Surfaces.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Color Paper.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Grayscale Paper.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Nature Patterns.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Patterns 2.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Patterns.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Rock Patterns.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Texture Fill 2.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\ [Texture Fill.pat]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal Copper.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal Strong Copper.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal Strong.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Bubbles.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Carpet.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Coarse Weave.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Crystals.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Denim.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Purples.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Rough.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Slate.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Stone.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Streaks.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Stucco.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Water.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Wood.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Woven.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\Adobe ImageReady Only\ [Zebra.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [60's flowers.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Arrowheads.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Blossoms.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Borneo.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Deco.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Diamonds-cubes.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Drunkard's path.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Flowers 1.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Flowers 2.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Fractures.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Herringbone 1.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Herringbone 2.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [India.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Intricate surface.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Laguna.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Mali primitive.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Mayan bricks.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Mexican tile.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Mezzotint-shape.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Optical checkerboard.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Optical Squares.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Oriental fans.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Oriental flowers.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Pinwheel.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Plaid.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Quilt.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Random V's.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Rough diamonds.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Scales.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Scallops.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Snake diamonds.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Spiked.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Submerged stones.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Triangles grid.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Undulating lines gradation.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Waffle Illusion.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Waffle.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Water droplets.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Waves.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Weave-Y.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Patterns\PostScript Patterns\ [Wrinkle.ai]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Photoshop Actions\ [Commands.atn]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Photoshop Actions\ [Frames.atn]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Photoshop Actions\ [Image Effects.atn]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Photoshop Actions\ [Production.atn]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Photoshop Actions\ [Text Effects.atn]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Photoshop Actions\ [Textures.atn]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Scripts\ [Export Layers To Files.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Scripts\ [Layer Comps To Files.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Scripts\ [Layer Comps to PDF.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Scripts\ [Layer Comps to WPG.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Abstract Styles.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Buttons.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Dotted Strokes.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Glass Button Rollovers.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Glass Buttons.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Image Effects.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Photographic Effects.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Rollover Buttons.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Text Effects 2.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Text Effects.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Textures.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Web Rollover Styles.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Styles\ [Web Styles.asl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Blue Pastels.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Burnt Red Pastel Paper.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Charcoal on Paper.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Dirt.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Feathers.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Footprints.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Frosted Glass.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Granite.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Grass.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Lambswool.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Leafy Bush.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Linen.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Lines.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Mountains 1.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Purple Daisies.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Purple Pastels.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Puzzle.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Rust Flakes.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Sepia Marble Paper.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Snake Skin.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Spiky Bush.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Strands 1.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Stucco 2.psd]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Stucco Color.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Wild Red Flowers.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Wrinkle Wood Paper.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Yellow Green Chalk.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Textures\ [Yellow Tan Dry Brush.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Tools\ [Art History.tpl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Tools\ [Brushes.tpl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Tools\ [Crop and Marquee.tpl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Tools\ [Text.tpl]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Simple\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [bgtile01.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\  [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [CSScriptLib.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownBar.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownFeedButton.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownFeedButton_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownInfoButton.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownInfoButton_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpBar.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpClose.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpClose_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpFeedAt.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpFeedButton.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpFeedButton_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpImageAt.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpImageButton.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpImageButton_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [saved.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [bgtile01.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [CSScriptLib.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoDownBar.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoDownInfoButton.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoDownInfoButton_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoUpBar.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoUpClose.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoUpClose_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [CSScriptLib.js]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navB.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navT.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [photoTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [photoTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [point.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosed.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedFeed-over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedFeed.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedImage-over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedImage.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenClose-over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenClose.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenFeed-over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenFeed.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenFeedOn.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenImage-over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenImage.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenImageOn.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenT.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [saved.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titT.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [innerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [innerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [nextArrow.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [nextArrowover.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [pattern01.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [previousArrow.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [previousArrowover.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [saved.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [shadowBottom.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [shadowTop.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [innerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [innerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [nextArrow.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [nextArrowover.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [pattern01.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [previousArrow.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [previousArrowover.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [shadowBottom.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [shadowTop.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [camicon02.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [nextArrow.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [previousArrow.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [shadowBottom.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [shadowTop.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [FrameSet.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [innerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [innerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [next.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [next_disabled.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [pause.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [pause_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [play.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [play_over.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [previous.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [previous_disabled.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Simple\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Simple\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Simple\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Simple\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [background.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [home.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [innerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [innerBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [innerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [innerTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [next.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [outerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [outerBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [outerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [outerTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [previous.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 1\images\ [spacer.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\ [Caption.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [*]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\ [IndexPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\ [SubPage.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\ [Thumbnail.htm]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [background.jpg]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [galleryStyle.css]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [home.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerB.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerT.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [innerTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [next.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerB.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerBL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerBR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerCorner.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerT.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerTL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [outerTR.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [previous.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeL.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeN.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeNE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeNW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeS.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeSE.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeSW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeW.gif]</pattern>
                <pattern type="File">%PhotoshopSuite8Path%\Presets\Web Photo Gallery\Table 2\images\ [spacer.gif]</pattern>
              </objectSet>
            </exclude>
            <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
              <objectSet>
                <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\8.0\Registration [COMPAN]</pattern>
                <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\8.0\Registration [NAME]</pattern>
              </objectSet>
            </locationModify>
          </rules>
        </role>
      </component>

      <!-- Adobe ImageReady CS -->
      <component context="User" type="Application">
        <displayName _locID="migapp.adobeimageready">Adobe ImageReady CS</displayName>
        <role role="Settings">
          <detects name="AdobeImageReadyCS" />
          <rules>
            <include>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Adobe\ImageReady 8.0\Preferences\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\Filter Gallery\CS\ImageReady\* [*]</pattern>
                <pattern type="File">%CSIDL_APPDATA%\Adobe\ImageReady\CS\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\Liquify\CS\* [*]</pattern>
              </objectSet>
            </include>
            <exclude>
              <objectSet>
                <pattern type="Registry">HKCU\Software\Adobe\ImageReady 8.0\Preferences\PluginCache\* [*]</pattern>
                <pattern type="Registry">HKCU\Software\Adobe\ImageReady 8.0\Preferences\RecentFiles\* [*]</pattern>
              </objectSet>
            </exclude>
            <merge script="MigXmlHelper.SourcePriority()">
              <objectSet>
                <pattern type="File">%CSIDL_APPDATA%\Adobe\ImageReady\CS\* [*]</pattern>
              </objectSet>
            </merge>
          </rules>
        </role>
      </component>

    </role>
  </component>

  <!-- Adobe Photoshop CS 9-->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.adobephotoshop9">Adobe Photoshop CS 9</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="PhotoshopSuite9Path">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Adobe\Photoshop\9.0\ [ApplicationPath]")</script>
      </variable>
    </environment>
    <environment context="User">
      <variable name="Photoshop9PersonalSettings">
        <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Adobe\Photoshop\9.0\ [SettingsFilePath]")</script>
      </variable>
    </environment>
    <environment context="System">
      <variable name="Photoshop9CommonColor">
        <text>%COMMONPROGRAMFILES%\Adobe\Color</text>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Adobe\Photoshop\9.0")</condition>
        </detect>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%PhotoshopSuite9Path%\Photoshop.dll","FileVersion","9.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Adobe\Photoshop\9.0 [*]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Lens Blur\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Liquify\CS\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Filter Gallery\CS\Photoshop\* [*]</pattern>
            <!-- changed %Photoshop9PersonalSettings%\* to %Photoshop9PersonalSettings%*
                                     as engine fail if %Photoshop9PersonalSettings% contains a '\' at the end.
                                     This has to be undone once the issue is fixed in engine.-->
            <pattern type="File">%Photoshop9PersonalSettings%* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Adobe\Photoshop\9.0 [AppWindowPosition]</pattern>
          </objectSet>
        </exclude>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Adobe\Photoshop\9.0 [AppWindowMaximized]</pattern>
            <pattern type="Registry">HKCU\Software\Adobe\Photoshop\9.0 [ShowStatusWindow]</pattern>
          </objectSet>
        </destinationCleanup>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <!-- changed %Photoshop9PersonalSettings%\* to %Photoshop9PersonalSettings%*
                             as engine fail if %Photoshop9PersonalSettings% contains a '\' at the end.
                             This has to be undone once the issue is fixed in engine.-->
            <pattern type="File">%Photoshop9PersonalSettings%* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
      <rules context="System">
        <include>
          <objectSet>
            <!-- For version 9, the path for Registration has changed. So need to add that -->
            <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\9.0\Registration [COMPAN]</pattern>
            <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\9.0\Registration [NAME]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\* [*]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Proofing\* [*]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\* [*]</pattern>
            <!-- changed %Photoshop9PersonalSettings%\* to %Photoshop9PersonalSettings%*
                             as engine fail if %Photoshop9PersonalSettings% contains a '\' at the end.
                             This has to be undone once the issue is fixed in engine.-->
            <pattern type="File">%PhotoshopSuite9Path%\Presets\* [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\* [*]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Proofing\* [*]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\* [*]</pattern>
            <!-- changed %Photoshop9PersonalSettings%\* to %Photoshop9PersonalSettings%*
                             as engine fail if %Photoshop9PersonalSettings% contains a '\' at the end.
                             This has to be undone once the issue is fixed in engine.-->
            <pattern type="File">%PhotoshopSuite9Path%\Presets\* [*]</pattern>
          </objectSet>
        </merge>
        <exclude>
          <objectSet>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [CIERGB.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [JapanStandard.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [NTSC1953.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [PAL_SECAM.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [pcd4050e.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [pcd4050k.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [pcdcnycc.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [pcdekycc.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [pcdkoycc.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [Photoshop4DefaultCMYK.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [Photoshop5DefaultCMYK.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [ProPhoto.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [Recommended]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [SMPTE-C.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [stdpyccl.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\ [WideGamutRGB.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [AdobeRGB1999.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [AppleRGB.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [ColorMatchRGB.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [EuroscaleCoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [EuroscaleUncoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [JapanColor2001Coated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [JapanColor2001Uncoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [JapanWebCoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [sRGB Color Space Profile.icm]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [USSheetfedCoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [USSheetfedUncoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [USWebCoatedSWOP.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Profiles\Recommended\ [USWebUncoated.icc]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [Color Management Off.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [Emulate Photoshop 4.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [EU General Purpose Defaults.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [Europe Prepress Defaults.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [Japan Color Prepress.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [JP General Purpose Defaults.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [NA General Purpose Defaults.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [Photoshop 5 Default Spaces.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [US Prepress Defaults.csf]</pattern>
            <pattern type="File">%Photoshop9CommonColor%\Settings\ [Web Graphics Defaults.csf]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\Adobe Photoshop Only\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Assorted Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Basic Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Calligraphic Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Drop Shadow Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Faux Finish Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Natural Brushes 2.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Natural Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\ [Square Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\Adobe Photoshop Only\ [Dry Media Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\Adobe Photoshop Only\ [Special Effect Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\Adobe Photoshop Only\ [Thick Heavy Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Brushes\Adobe Photoshop Only\ [Wet Media Brushes.abr]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [VisiBone Read Me.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [DIC Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [FOCOLTONE Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (Coated).aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (Process).aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (ProSim).aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Pantone Colors (Uncoated).aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TOYO Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TRUMATCH Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [ANPA Color.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [DIC Color Guide.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [FOCOLTONE.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS E Process.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS E.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS K Process.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS K.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS N Process.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS N.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS Z Process.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [HKS Z.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE metallic coated.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE pastel coated.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE pastel uncoated.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE process coated.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE solid coated.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE solid matte.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE solid to process EURO.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE solid to process.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [PANTONE solid uncoated.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [TOYO Color Finder.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [TOYO Process Color Finder.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Books\ [TRUMATCH.acb]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [Mac OS.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [VisiBone ReadMe.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [VisiBone.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [VisiBone2.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [Web Hues.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [Web Safe Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [Web Spectrum.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\ [Windows.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [ANPA Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [DIC Color Guide.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [DIC Swatch ReadMe.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [FOCOLTONE Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS E Process.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS E.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS K Process.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS K.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS N Process.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS N.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS Z Process.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [HKS Z.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE metallic coated.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE pastel coated.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE pastel uncoated.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE process coated.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid coated.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid matte.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid to process EURO.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid to process.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [PANTONE solid uncoated.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [Photo Filter Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TOYO Color Finder.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TOYO Process Color Finder.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Color Swatches\Adobe Photoshop Only\ [TRUMATCH Colors.aco]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Contours\ [Contours.shc]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [All.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Animals.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Arrows.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Banners.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Frames.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Music.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Nature.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Objects.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Ornaments.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Shapes.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Symbols.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [TalkBubbles.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Tiles.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Custom Shapes\ [Web.csh]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotone\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [423-1.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [423-2.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [423-3.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [424 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 1.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 2.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 3.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 7 bl 4.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 1.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 2.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 3.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Cool Gray 9 bl 4.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 1.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 2.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 3.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 11 bl 4.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 9 bl 1.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 9 bl 2.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 9 bl 3.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Gray-Black Duotones\ [Warm Gray 9 bl 4.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange (25%) bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [144 orange bl 90% shad.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [159 dk orange bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [327 aqua (50%) bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [479 brown (100%) bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [479 brown (100%) bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [479 brown (100%) bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [479 brown (100%) bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [506 burgundy (75%) bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [527 purple (100%) bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 072 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 296 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 296 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 296 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [blue 296 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [brown 464 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 3405 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [green 349 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [mauve 4655 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 495 bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 495 bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 495 bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\PANTONE(R) Duotones\ [red 495 bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [cyan bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [magenta bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Duotones\Process Duotones\ [yellow bl 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl CG10 CG4 WmG3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl CG10 WmG3 CG1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl CG10 WmG4 CG3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Gray Quadtones\ [Bl WmG9 CG6 CG3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 430 493 557.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 431 492 556.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 541 513 5773.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\PANTONE(R) Quadtones\ [Bl 75% 50% 25%.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK blue.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK brown.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK cool.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK ext wm.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK neutral.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\Quadtones\Process Quadtones\ [CMYK wm.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl 404 WmGray 401 WmGray.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl 409 WmGray 407 WmGray.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl Cool Gray 10 WmGray 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [Bl WmGray 7 WmGray 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-1.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-2.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-3.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Gray Tritones\ [CG9CG2-4.ADO]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 165 red orange 457 brown.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 172 orange 423 gray.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 313 aqua 127 gold.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 334 green 437 mauve.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 340 green 423 gray.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 437 burgundy 127 gold.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\PANTONE(R) Tritones\ [Bl 50% 25%.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BCY green 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMC blue 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY brown 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY red 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 1.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 2.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 3.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Duotones\TRITONE\Process Tritones\ [BMY sepia 4.ado]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Color Harmonies 1.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Color Harmonies 2.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Metals.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Noise Samples.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Pastels.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Simple.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Special Effects.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Gradients\ [Spectrums.grd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [1stFiveBySevens.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [EightByTen.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndSmaller.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndThreeByFive.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndThreeByThreeH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndThreeH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndTwoByTwoH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndTwoH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FiveBySevenAndTwoHByThreeH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FourByFives.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FourByFivesAndSmaller.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FourByFivesAndTwoByTwoH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [FourByFivesAndTwoHByThreeH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [ReadMe.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [TenByThirteen.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [ThreeHByFive.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [TwoByTwo.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [TwoByTwoH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [TwoHByThreeH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [TwoHByThreeHAndTwoByTwoH.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Layouts\ [TwoHByThreeQ.txt]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Colors\ [Black &amp; White.act]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Colors\ [Grayscale.act]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Colors\ [Mac OS.act]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Colors\ [Windows.act]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Output Settings\ [Background Image.iros]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Output Settings\ [Default Settings.iros]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Output Settings\ [XHTML.iros]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF 129 Dithered.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF 129 No Dither.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF 32 Dithered.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF 32 No Dither.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF 64 Dithered.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF 64 No Dither.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [GIF Restrictive.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [JPEG High.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [JPEG Low.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [JPEG Medium.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [PNG-24.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Optimized Settings\ [PNG-8 128 Dithered.irs]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Artist Surfaces.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Color Paper.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Grayscale Paper.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Nature Patterns.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Patterns 2.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Patterns.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Rock Patterns.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Texture Fill 2.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\ [Texture Fill.pat]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal Copper.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal Strong Copper.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal Strong.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Brushed Metal.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Bubbles.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Carpet.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Coarse Weave.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Crystals.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Denim.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Purples.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Rough.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Slate.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Stone.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Streaks.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Stucco.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Water.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Wood.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Woven.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\Adobe ImageReady Only\ [Zebra.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [60's flowers.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Arrowheads.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Blossoms.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Borneo.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Deco.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Diamonds-cubes.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Drunkard's path.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Flowers 1.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Flowers 2.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Fractures.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Herringbone 1.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Herringbone 2.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [India.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Intricate surface.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Laguna.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Mali primitive.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Mayan bricks.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Mexican tile.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Mezzotint-shape.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Optical checkerboard.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Optical Squares.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Oriental fans.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Oriental flowers.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Pinwheel.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Plaid.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Quilt.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Random V's.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Rough diamonds.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Scales.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Scallops.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Snake diamonds.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Spiked.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Submerged stones.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Triangles grid.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Undulating lines gradation.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Waffle Illusion.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Waffle.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Water droplets.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Waves.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Weave-Y.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Patterns\PostScript Patterns\ [Wrinkle.ai]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Photoshop Actions\ [Commands.atn]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Photoshop Actions\ [Frames.atn]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Photoshop Actions\ [Image Effects.atn]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Photoshop Actions\ [Production.atn]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Photoshop Actions\ [Text Effects.atn]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Photoshop Actions\ [Textures.atn]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Scripts\ [Export Layers To Files.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Scripts\ [Layer Comps To Files.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Scripts\ [Layer Comps to PDF.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Scripts\ [Layer Comps to WPG.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Abstract Styles.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Buttons.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Dotted Strokes.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Glass Button Rollovers.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Glass Buttons.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Image Effects.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Photographic Effects.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Rollover Buttons.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Text Effects 2.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Text Effects.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Textures.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Web Rollover Styles.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Styles\ [Web Styles.asl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Blue Pastels.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Burnt Red Pastel Paper.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Charcoal on Paper.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Dirt.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Feathers.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Footprints.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Frosted Glass.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Granite.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Grass.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Lambswool.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Leafy Bush.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Linen.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Lines.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Mountains 1.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Purple Daisies.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Purple Pastels.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Puzzle.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Rust Flakes.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Sepia Marble Paper.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Snake Skin.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Spiky Bush.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Strands 1.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Stucco 2.psd]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Stucco Color.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Wild Red Flowers.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Wrinkle Wood Paper.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Yellow Green Chalk.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Textures\ [Yellow Tan Dry Brush.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Tools\ [Art History.tpl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Tools\ [Brushes.tpl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Tools\ [Crop and Marquee.tpl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Tools\ [Text.tpl]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Simple\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [bgtile01.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [lineBoxW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Basic\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\  [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [CSScriptLib.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownBar.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownFeedButton.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownFeedButton_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownInfoButton.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedDownInfoButton_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpBar.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpClose.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpClose_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpFeedAt.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpFeedButton.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpFeedButton_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpImageAt.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpImageButton.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [feedUpImageButton_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [infoEdgeW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [lineBoxW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [saved.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Feedback\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [bgtile01.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [CSScriptLib.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoDownBar.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoDownInfoButton.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoDownInfoButton_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoEdgeW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoUpBar.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoUpClose.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [infoUpClose_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [lineBoxW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 1 - Info Only\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [CSScriptLib.js]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navB.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navT.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [navTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [outerTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [photoTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [photoTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [point.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosed.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedFeed-over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedFeed.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedImage-over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popClosedImage.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenClose-over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenClose.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenFeed-over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenFeed.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenFeedOn.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenImage-over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenImage.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenImageOn.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [popOpenT.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [saved.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titT.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Centered Frame 2 - Feedback\images\ [titTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [3dEdgeW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [innerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [innerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [nextArrow.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [nextArrowover.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [pattern01.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [previousArrow.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [previousArrowover.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [roundTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [saved.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [shadowBottom.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [shadowTop.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal - Feedback\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [innerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [innerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [nextArrow.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [nextArrowover.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [pattern01.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [previousArrow.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [previousArrowover.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [roundTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [shadowBottom.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [shadowTop.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Gray\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [camicon02.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [nextArrow.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [previousArrow.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [shadowBottom.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [shadowTop.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Neutral\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [FrameSet.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [doubleroundW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [innerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [innerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [next.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [next_disabled.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [pause.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [pause_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [play.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [play_over.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [previous.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [previous_disabled.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundotW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [roundTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Horizontal Slideshow\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Simple\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Simple\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Simple\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Simple\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [background.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [home.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [innerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [innerBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [innerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [innerTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [next.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [outerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [outerBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [outerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [outerTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [previous.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [slideEdgeW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 1\images\ [spacer.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\ [Caption.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [*]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\ [IndexPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\ [SubPage.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\ [Thumbnail.htm]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [background.jpg]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [galleryStyle.css]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [home.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerB.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerT.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [innerTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [next.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerB.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerBL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerBR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerCorner.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerT.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerTL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [outerTR.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [previous.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeL.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeN.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeNE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeNW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeS.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeSE.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeSW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [slideEdgeW.gif]</pattern>
            <pattern type="File">%PhotoshopSuite9Path%\Presets\Web Photo Gallery\Table 2\images\ [spacer.gif]</pattern>
          </objectSet>
        </exclude>
        <locationModify script="MigXmlHelper.RelativeMove('%HklmWowSoftware%','%HklmWowSoftware%')">
          <objectSet>
            <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\9.0\Registration [COMPAN]</pattern>
            <pattern type="Registry">%HklmWowSoftware%\Adobe\Photoshop\9.0\Registration [NAME]</pattern>
          </objectSet>
        </locationModify>
      </rules>
    </role>
  </component>

  <!-- Lotus SmartSuite -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.lotussmartsuit">Lotus SmartSuite</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="Lotus123Exe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\123w.exe []")</script>
      </variable>
    </environment>
    <environment>
      <variable name="LotusApproachExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\Approach.exe []")</script>
      </variable>
    </environment>
    <environment>
      <variable name="LotusFastSiteExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\FastSite.exe []")</script>
      </variable>
    </environment>
    <environment>
      <variable name="LotusFreelanceExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\f32main.exe []")</script>
      </variable>
    </environment>
    <environment>
      <variable name="LotusOrganizerExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\org5.exe []")</script>
      </variable>
    </environment>
    <environment>
      <variable name="LotusWordProExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\WordPro.exe []")</script>
      </variable>
    </environment>
    <environment>
      <variable name="LotusSmartCenterExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\smartctr.exe []")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%Lotus123Exe%","ProductVersion","9.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusApproachExe%","ProductVersion","9.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusFastSiteExe%","ProductVersion","2.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusFreelanceExe%","ProductVersion","9.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusOrganizerExe%","ProductVersion","5.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusWordProExe%","ProductVersion","99.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusSmartCenterExe%","ProductVersion","99.*")</condition>
        </detect>
      </detects>

      <!-- 1-2-3 -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%Lotus123Exe%","ProductVersion","9.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\DDE Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Find Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Formats\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Infobox\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Smart Labels\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Spell Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\View Preferences\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0 [CompanyName]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0 [UserName]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\DDE Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Find Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Formats\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Infobox\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\SmartLabels\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Spell Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\User Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\View Preferences\* [*]</pattern>
            <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Lotus\123\99.0\Spell Preferences [SpellUserDictionary]</pattern>
              </objectSet>
            </content>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\123\99.0\User Preferences [Addins]</pattern>
          </objectSet>
        </exclude>
      </rules>

      <!-- Approach -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusApproachExe%","ProductVersion","N9.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\General\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\HideTypes\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\InfoBox\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\Notes\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\ShowTypes\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\SmartIcons\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\SQL\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0 [CompanyName]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0 [UserName]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\General\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\HideTypes\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\InfoBox\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\Lotus Approach\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\Notes\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\ODBC [TurnTraceOn]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\OLE Custom Controls\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\QMF\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\ShowTypes\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\SmartIcons\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\SQL\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\General [RegInfoPath]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\QMF [DssDir]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Approach\99.0\QMF [DssPath]</pattern>
          </objectSet>
        </exclude>
      </rules>

      <!-- FastSite -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusFastSiteExe%","ProductVersion","2.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\FastSite\2.0\Positions\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\FastSite\2.0\Settings\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\FastSite\2.0\Positions\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\FastSite\2.0\Settings\* [*]</pattern>
          </objectSet>
        </include>
      </rules>

      <!-- Freelance -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusFreelanceExe%","ProductVersion","9.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\InfoBox\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Publish to Web\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Freelance Graphics\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\InfoBox\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 10 Apps\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 10 Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 10 Movies\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 10 Sounds\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 10 Urls\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 Add Bitmap Directories\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 Add Movie Directories\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 Add Sound Directories\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 Create Named Chart Directories\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 ODMA Doc ID's\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Last 5 ODMA Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Publish\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Publish to Web\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Freelance Graphics [Backup Directory]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Freelance Graphics [Media Directory]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Freelance\99.0\Freelance Graphics [Working Directory]</pattern>
          </objectSet>
        </exclude>
      </rules>

      <!-- Organizer -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusOrganizerExe%","ProductVersion","5.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Calls\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Favoured Reports\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\International\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Ldap\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Mail\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Scheduling\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Sections\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Telephony\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\UserSetup\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0 [CompanyName]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0 [UserName]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Calls\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Favoured Reports\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\International\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Ldap\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Mail\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Scheduling\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Sections\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Settings\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Telephony\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\URLs\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\UserSetup\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Organizer\99.0\Settings [OrgHomeDir]</pattern>
          </objectSet>
        </exclude>
      </rules>

      <!-- WordPro -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusWordProExe%","ProductVersion","99.*")</condition>
        </conditions>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwp4lp.ini\Layout\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwp4lp.ini\Options\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwphtml.ini\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwpimage.ini\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwptools.ini\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwpuser.ini\SmartIcons\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwpuser.ini\WordProUser\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\WordPro\99.0\lwpuser.ini\WordProUser [LastSmartMaster*]</pattern>
          </objectSet>
        </exclude>
      </rules>

      <!-- SmartCenter and others -->
      <rules context="User">
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%LotusSmartCenterExe%","ProductVersion","99.*")</condition>
        </conditions>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\SmartCenter\99.0 [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\SuiteStart\99.0 [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Components\Chart\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Components\Expert\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\Components\Internet\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\SmartCenter\99.0 [*]</pattern>
            <pattern type="Registry">HKCU\Software\Lotus\SuiteStart\99.0 [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Lotus\Components\Chart\2.3 [Style Directory]</pattern>
          </objectSet>
        </exclude>
      </rules>
    </role>
  </component>

  <!-- Yahoo! Messenger -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.yahoomessenger">Yahoo! Messenger</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64"/>
    <environment context="User">
      <variable name="YahooSkinPath">
        <objectSet>
          <content filter='MigXmlHelper.ExtractDirectory (NULL, "1")'>
            <objectSet>
              <pattern type="Registry">HKCU\Software\Yahoo\Pager\skins [Default_SkinDir]</pattern>
            </objectSet>
          </content>
        </objectSet>
      </variable>
    </environment>
    <environment context="System">
      <variable name="YahooMainDir">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Yahoo\Essentials [MainDir]")</script>
      </variable>
    </environment>
    <environment>
      <variable name="YahooLocalServer">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Classes\CLSID\{E5D12C4E-7B4F-11D3-B5C9-0050045C3C96}\LocalServer32 []")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Yahoo\Pager")</condition>
        </detect>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","3,*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","4,*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","5,*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","6,*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","7,*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","8,*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%YahooLocalServer%","ProductVersion","9,*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Run [Yahoo! Pager]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Companion\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\YFriendsBar\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\YServer\* [*]</pattern>
            <pattern type="File">%YahooSkinPath%\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\Alerts [*Sound Name]</pattern>
            <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Yahoo\Pager\Alerts [*Sound Name]</pattern>
              </objectSet>
            </content>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [EOptions string]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [Http Server]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [IPLookup]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [PreLogin]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [socket server]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [LatestSocketServerUrl]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager [EOptions string]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\* [Default_SkinDir]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\File Transfer\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\Old Entries\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\list\Messenger\ [Click Count]</pattern>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\Update\ [LastUpdaterRunTime]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%YahooSkinPath%\* [*]</pattern>
          </objectSet>
        </merge>
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Windows\CurrentVersion\Run [Yahoo! Pager]</pattern>
          </objectSet>
        </destinationCleanup>
        <merge script="MigXmlHelper.DestinationPriority()">
          <objectSet>
            <pattern type="Registry">HKCU\Software\Yahoo\Pager\View\* [*]</pattern>
          </objectSet>
        </merge>
        <locationModify script="MigXmlHelper.RelativeMove('%YahooSkinPath%','%YahooSkinPath%')">
          <objectSet>
            <pattern type="File">%YahooSkinPath%\* [*]</pattern>
          </objectSet>
        </locationModify>
      </rules>
      <rules context="System">
        <!-- Yahoo Messenger LocalFiles.CopyFiles Yahoo Messenger LocalFiles.CopyFiles -->
        <include>
          <objectSet>
            <pattern type="File">%YahooMainDir%\Messenger\local [*]</pattern>
          </objectSet>
        </include>
      </rules>
    </role>
  </component>

  <!-- Microsoft Works 9.0 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.msworks9">Microsoft Works 9.0</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="WorksTemplatesDir">
        <script>MigXmlHelper.GetStringContent("Registry","HKCU\Software\Microsoft\Works\9.0\Common\Templates [TemplateDirectory]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Works\9.0 [INSTALLDIR]")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Works\9.0\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Works\9.0\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof [CUSTOM.DIC]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\Works\2057 [WkAcCust.bin]</pattern>
            <pattern type="File">%WorksTemplatesDir%\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Works\9.0 [PrjLnch]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\UProof [CUSTOM.DIC]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Microsoft\Works\2057 [WkAcCust.bin]</pattern>
            <pattern type="File">%WorksTemplatesDir%\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
      <rules context="System">
        <include>
          <objectSet>
            <pattern type="File">%CSIDL_COMMON_APPDATA%\Microsoft\Works [mswkscal.wcd]</pattern>
            <pattern type="File">%CSIDL_COMMON_APPDATA%\Microsoft\Works [wkcalcat.dat]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_COMMON_APPDATA%\Microsoft\Works [mswkscal.wcd]</pattern>
            <pattern type="File">%CSIDL_COMMON_APPDATA%\Microsoft\Works [wkcalcat.dat]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Microsoft Money Plus Home & Business 2008 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.money2008">Microsoft Money 2008</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="MoneyInstallDir">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Money\17.0\Setup [InstallDir]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Microsoft\Money\17.0\Setup [InstallDir]")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Money\17.0\Webcache\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Investor\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Money\17.0\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Works Suite\2008\Mny17\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\VB and VBA Program Settings\Money Invoice Designer\Settings\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Money\17.0\* [*]</pattern>
            <pattern type="File">%MoneyInstallDir%\* [*.mar]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Money\17.0 [au.ini]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Money\17.0\Webcache\* [*]</pattern>
          </objectSet>
        </exclude>
        <locationModify script="MigXmlHelper.RelativeMove('%MoneyInstallDir%', '%MoneyInstallDir%')">
          <objectSet>
            <pattern type="File">%MoneyInstallDir%\* [*.mar]</pattern>
          </objectSet>
        </locationModify>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Money\17.0\* [*]</pattern>
            <pattern type="File">%MoneyInstallDir%\* [*.mar]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Zune Software 3 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.zune3">Zune Software</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="ZuneInstallDir">
        <script>MigXmlHelper.GetStringContent("Registry","HKLM\Software\Microsoft\Zune [Installation Directory]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detection>
        <conditions>
          <conditions>
            <condition>MigXmlHelper.DoesObjectExist("Registry","HKLM\Software\Microsoft\Zune [Installation Directory]")</condition>
          </conditions>
          <conditions operation="OR">
            <condition>MigXmlHelper.DoesFileVersionMatch("%ZuneInstallDir%\Zune.exe","ProductVersion","3.*")</condition>
            <condition>MigXmlHelper.DoesFileVersionMatch("%ZuneInstallDir%\Zune.exe","ProductVersion","4.*")</condition>
          </conditions>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Zune\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Zune\Art Cache\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Zune\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Zune\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Windows Phone Update\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Microsoft\Zune\FUE\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Microsoft\Zune\MediaStore\CachedResults\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Zune\Art Cache\* [*]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Microsoft\Zune\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Quicken Deluxe 2009 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.quicken2009">Quicken 2009</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Intuit\Quicken\2009 [ExePath]")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Ini">%CSIDL_APPDATA%\Intuit\Quicken\Config\QUSER.ini|RecentFiles[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Intuit\Quicken\Config\QUSER.ini|Quicken[NewCatPrompt]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Quicken[*]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Reconcile[Instruct]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Internet[*]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|QPS[*]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|MarketingMessages[*]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Business[*]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|WebConnect[*]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Registration[*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Quicken[ExePath]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Quicken[Platform]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Quicken[Version]</pattern>
            <pattern type="Ini">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config\quicken.ini|Quicken[QuickPayrollPath]</pattern>
            <pattern type="File">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config [quicken.ini]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Intuit\Quicken\Config [QUSER.ini]</pattern>
            <pattern type="File">%CSIDL_COMMON_APPDATA%\Intuit\Quicken\Config [quicken.ini]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Peachtree 2009 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.peachtree2009">Peachtree 2009</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="PeachtreeInstallDir">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Peachtree\Applications\PPAAT 16 [Product Path]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Peachtree\Applications\PPAAT 16 [Product Path]")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Peachtree\Peachtree*\16\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Peachtree\SpellCheck\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Peachtree\Peachtree*\16\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Peachtree\SpellCheck\* [*]</pattern>
            <pattern type="File">%PeachtreeInstallDir%\Lex\* [*]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%PeachtreeInstallDir%', '%PeachtreeInstallDir%')">
          <objectSet>
            <pattern type="File">%PeachtreeInstallDir%\Lex\* [*]</pattern>
          </objectSet>
        </locationModify>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%PeachtreeInstallDir%\Lex\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!--WordPerfect Office X3  -->
  <component context="User" type="Application">
    <displayName _locID="migapp.wpofficeX3">WordPerfect Office X3</displayName>
    <environment>
      <variable name="CorelQProX3ConfPath">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\SOFTWARE\Corel\QuattroPro\13\Configuration\ConfigDir []")
        </script>
      </variable>
      <variable name="WpX3Toolbars">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\Corel Presentations\13\EN\Location of Files [Tool Bars]")
        </script>
      </variable>
      <variable name="CorelQProX3Profiles">
        <text>%CorelQProX3ConfPath%\WordPerfect Office 13</text>
      </variable>
      <variable name="CorelQProX3Profiles2">
        <text>%CorelQProX3ConfPath%\QuattroPro13</text>
      </variable>
      <variable name="CorelX3PrimarySRBFile">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\ScrapBook\13\SRB files\primary [Filename]")
        </script>
      </variable>
      <variable name="WpX3Templates">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\13\EN\Location of Files [Template Folder]")
        </script>
      </variable>
      <variable name="WpX3Templates2">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\13\EN\Location of Files [Additional Templates Folder]")
        </script>
      </variable>
      <variable name="WpX3Macros">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\13\EN\Location of Files [Macro Folder]")
        </script>
      </variable>
      <variable name="WpX3Macros2">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\13\EN\Location of Files [Macro Supplemental Folder]")
        </script>
      </variable>
      <variable name="CorelNonLocalizedProfile">
        <text>%USERPROFILE%\Application Data\Corel</text>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry", "HKCU\Software\Corel\WordPerfect\13\EN\Location of Files")</condition>
        </detect>
      </detects>
      <rules>
        <include>
          <objectSet>
            <pattern type="File">%WpX3Templates%\ [*.wpt]</pattern>
            <pattern type="File">%WpX3Templates2%\ [*.wpt]</pattern>
            <pattern type="File">%WpX3Macros%\* [*]</pattern>
            <pattern type="File">%WpX3Macros2%\* [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%WpX3Templates%\ [*.wpt]</pattern>
            <pattern type="File">%WpX3Templates2%\ [*.wpt]</pattern>
            <pattern type="File">%WpX3Macros%\* [*]</pattern>
            <pattern type="File">%WpX3Macros2%\* [*]</pattern>
          </objectSet>
        </merge>
        <!-- AddReg  -->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\QuickFinder\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\ClipBook\Clipbook.INI\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\CSP Pleading Expert\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Conversions\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\13\Presentation [Default Master]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Graphics\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\13.0\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\PerfectFit\13\Settings\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\PerfectScript\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\ScrapBook\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Shared Settings\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Default save file format]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Default save file format index]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Use ODMA Integration]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Update Quick List with Changes]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Use Default Document Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [On Save, keep documents original file format]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Default Document Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Additional Objects Template]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Update Default Template From Additional]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Spreadsheet Supplemental Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Database Supplemental Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Labels to Display]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Use Default Form File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Default Merge Form File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Use Default Data File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [Default Merge Data File Extension]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\Dad\13\Preferences [ProgramsDir]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\13\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\13\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\13\Presentation\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Graphics\13\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\13\Location of Help Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\13.0\AddIns\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\13.0\Experts\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\13\ChartTool [FillPath]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\13\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\13\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuickFinder\13\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Java\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\SGML [Open Dialog Default Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\SGML [Template Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\SGML\Catalog Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\SGML\DTD to LGC\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\13\SGML\Layout Designer\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Grammatik\* [Advice File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Grammatik\* [Help File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Grammatik\* [History File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Grammatik\* [Mor Dictionary]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Grammatik\* [Rule File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Thesaurus\* [Data File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\Main Word Lists\* [*]</pattern>
          </objectSet>
        </exclude>
        <!--  regfile -->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\User Word Lists\* [Name]</pattern>
            <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Corel\WritingTools\13\User Word Lists\* [Name]</pattern>
              </objectSet>
            </content>
          </objectSet>
        </include>
        <!--Forcesrcfiles -->
        <include>
          <objectSet>
            <pattern type="File">%CorelQProX3ConfPath%\QuattroPro13\ [*.cfg]</pattern>
            <pattern type="File">%CorelQProX3Profiles%\* [*]</pattern>
            <pattern type="File">%CorelQProX3Profiles2%\* [*]</pattern>
            <pattern type="File">%wpX3toolbars%\* [*]</pattern>
            <pattern type="File">%CorelX3PrimarySRBFile% [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CorelQProX3ConfPath%\QuattroPro13\ [*.cfg]</pattern>
            <pattern type="File">%CorelQProX3Profiles%\* [*]</pattern>
            <pattern type="File">%CorelQProX3Profiles2%\* [*]</pattern>
            <pattern type="File">%wpX3toolbars%\* [*]</pattern>
            <pattern type="File">%CorelX3PrimarySRBFile% [*]</pattern>
          </objectSet>
        </merge>
        <!-- copy files -->
        <include>
          <objectSet>
            <pattern type="File">%CorelNonLocalizedProfile%\* [*]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%CorelNonLocalizedProfile%','%appdata%\Corel')">
          <objectSet>
            <pattern type="File">%CorelNonLocalizedProfile%\* [*]</pattern>
          </objectSet>
        </locationModify>
      </rules>
    </role>
  </component>

  <!--WordPerfect Office 12  -->
  <component context="User" type="Application">
    <displayName _locID="migapp.wpoffice12">WordPerfect Office 12</displayName>
    <environment>
      <variable name="WpOffice12Dad">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\Dad\12\Preferences [DAD]")
        </script>
      </variable>
      <variable name="CorelQPro12ConfPath">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\SOFTWARE\Corel\QuattroPro\12\Configuration\ConfigDir []")
        </script>
      </variable>
      <variable name="Wp12Toolbars">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\Corel Presentations\12\Location of Files [Tool Bars]")
        </script>
      </variable>
      <variable name="CorelQPro12Profiles">
        <text>%CorelQPro12ConfPath%\WordPerfect Office 12</text>
      </variable>
      <variable name="CorelQPro12Profiles2">
        <text>%CorelQPro12ConfPath%\QuattroPro12</text>
      </variable>
      <variable name="Corel12PrimarySRBFile">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\ScrapBook\12\SRB files\primary [Filename]")
        </script>
      </variable>
      <variable name="Wp12Templates">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\12\Location of Files\EN [Template Folder]")
        </script>
      </variable>
      <variable name="Wp12Templates2">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\12\Location of Files\EN [Additional Templates Folder]")
        </script>
      </variable>
      <variable name="Wp12Macros">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\12\Location of Files\EN [Macro Folder]")
        </script>
      </variable>
      <variable name="Wp12Macros2">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\12\Location of Files\EN [Macro Supplemental Folder]")
        </script>
      </variable>
      <variable name="CorelNonLocalizedProfile">
        <text>%USERPROFILE%\Application Data\Corel</text>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry", "HKCU\Software\Corel\WordPerfect\12\Location of Files\EN")</condition>
        </detect>
      </detects>
      <rules>
        <include>
          <objectSet>
            <pattern type="File">%Wp12Templates%\ [*.wpt]</pattern>
            <pattern type="File">%Wp12Templates2%\ [*.wpt]</pattern>
            <pattern type="File">%Wp12Macros%\* [*]</pattern>
            <pattern type="File">%Wp12Macros2%\* [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%Wp12Templates%\ [*.wpt]</pattern>
            <pattern type="File">%Wp12Templates2%\ [*.wpt]</pattern>
            <pattern type="File">%Wp12Macros%\* [*]</pattern>
            <pattern type="File">%Wp12Macros2%\* [*]</pattern>
          </objectSet>
        </merge>
        <!-- AddReg  -->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\QuickFinder\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\ClipBook\Clipbook.INI\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\CSP Pleading Expert\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Conversions\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\12\Presentation [Default Master]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Graphics\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\12.0\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\PerfectFit\12\Settings\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\PerfectScript\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\ScrapBook\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Shared Settings\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Default save file format]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Default save file format index]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Use ODMA Integration]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Update Quick List with Changes]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Use Default Document Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [On Save, keep documents original file format]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Default Document Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Additional Objects Template]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Update Default Template From Additional]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Spreadsheet Supplemental Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Database Supplemental Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Labels to Display]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Use Default Form File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Default Merge Form File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Use Default Data File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [Default Merge Data File Extension]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\Dad\12\Preferences [ProgramsDir]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\12\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\12\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\12\Presentation\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Graphics\12\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\12\Location of Help Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\12.0\AddIns\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\12.0\Experts\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\12\ChartTool [FillPath]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\12\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\12\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuickFinder\12\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Java\ [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\SGML [Open Dialog Default Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\SGML [Template Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\SGML\Catalog Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\SGML\DTD to LGC\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\12\SGML\Layout Designer\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Grammatik\* [Advice File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Grammatik\* [Help File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Grammatik\* [History File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Grammatik\* [Mor Dictionary]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Grammatik\* [Rule File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Thesaurus\* [Data File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\Main Word Lists\* [*]</pattern>
          </objectSet>
        </exclude>
        <!--  regfile -->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\User Word Lists\* [Name]</pattern>
            <content filter="MigXmlHelper.ExtractSingleFile(NULL, NULL)">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Corel\WritingTools\12\User Word Lists\* [Name]</pattern>
              </objectSet>
            </content>
          </objectSet>
        </include>
        <!-- copyfiles-->
        <include>
          <objectSet>
            <pattern type="File">%WpOffice12Dad%\* [*]</pattern>
          </objectSet>
        </include>
        <!--Forcesrcfiles -->
        <include>
          <objectSet>
            <pattern type="File">%CorelQPro12ConfPath%\QuattroPro12\ [*.cfg]</pattern>
            <pattern type="File">%CorelQPro12Profiles%\* [*]</pattern>
            <pattern type="File">%CorelQPro12Profiles2%\* [*]</pattern>
            <pattern type="File">%wp12toolbars%\* [*]</pattern>
            <pattern type="File">%Corel12PrimarySRBFile% [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CorelQPro12ConfPath%\QuattroPro12\ [*.cfg]</pattern>
            <pattern type="File">%CorelQPro12Profiles%\* [*]</pattern>
            <pattern type="File">%CorelQPro12Profiles2%\* [*]</pattern>
            <pattern type="File">%wp12toolbars%\* [*]</pattern>
            <pattern type="File">%Corel12PrimarySRBFile% [*]</pattern>
          </objectSet>
        </merge>
        <!-- copy files -->
        <include>
          <objectSet>
            <pattern type="File">%CorelNonLocalizedProfile%\* [*]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%CorelNonLocalizedProfile%','%appdata%\Corel')">
          <objectSet>
            <pattern type="File">%CorelNonLocalizedProfile%\* [*]</pattern>
          </objectSet>
        </locationModify>
      </rules>
    </role>
  </component>

  <!--word perfectoffice11  -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.wpoffice11">WordPerfect Office 11</displayName>
    <environment context="User">
      <variable name="WpOffice11Dad ">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\Dad\11\Preferences [DAD]")
        </script>
      </variable>
      <variable name="CorelQPro11ConfPath">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\SOFTWARE\Corel\QuattroPro\11\Configuration\ConfigDir []")
        </script>
      </variable>
      <variable name="Wp11Toolbars">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\Corel Presentations\11\Location of Files [Tool Bars]")
        </script>
      </variable>
      <variable name="CorelQPro11Profiles">
        <text>%CorelQPro11ConfPath%\WordPerfect Office 11</text>
      </variable>
      <variable name="CorelQPro11Profiles2">
        <text>%CorelQPro11ConfPath%\QuattroPro11</text>
      </variable>
      <variable name="Wp11Templates">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\11\Location of Files\EN [Template Folder]")
        </script>
      </variable>
      <variable name="Wp11Templates2">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\11\Location of Files\EN [Additional Templates Folder]")
        </script>
      </variable>
      <variable name="Wp11Macros">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\11\Location of Files\EN [Macro Folder]")
        </script>
      </variable>
      <variable name="Wp11Macros2">
        <script>
          MigXmlHelper.GetStringContent ("Registry","HKCU\Software\Corel\WordPerfect\11\Location of Files\EN [Macro Supplemental Folder]")
        </script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Corel\WordPerfect\11\Location of Files\EN")</condition>
        </detect>
      </detects>
      <rules context="User">
        <!--WordPerfect Office 11 EN ForceSrcFile-->
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%Wp11Templates%\ [*.wpt]</pattern>
            <pattern type="File">%Wp11Templates2%\ [*.wpt]</pattern>
            <pattern type="File">%Wp11Macros%\* [*]</pattern>
            <pattern type="File">%Wp11Macros2%\* [*]</pattern>
          </objectSet>
        </merge>
        <!--WordPerfect Office 11 EN CopyFiles-->
        <include>
          <objectSet>
            <pattern type="File">%Wp11Templates%\ [*.wpt]</pattern>
            <pattern type="File">%Wp11Templates2%\ [*.wpt]</pattern>
            <pattern type="File">%Wp11Macros%\* [*]</pattern>
            <pattern type="File">%Wp11Macros2%\* [*]</pattern>
          </objectSet>
        </include>
        <!--WordPerfectOffice11 Addreg-->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\CSP Pleading Expert\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\11\Presentation [Default Master]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Graphics\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\11.0\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\PerfectScript\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Shared Settings\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Default save file format]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Default save file format index]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Use ODMA Integration]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Update Quick List with Changes]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Use Default Document Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [On Save, keep documents original file format]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Default Document Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Additional Objects Template]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Update Default Template From Additional]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Spreadsheet Supplemental Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Database Supplemental Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Labels to Display]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Use Default Form File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Default Merge Form File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Use Default Data File Extension]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [Default Merge Data File Extension]</pattern>
          </objectSet>
        </include>
        <!--WordPerfectOffice11 Delreg -->
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\Dad\11\Preferences [ProgramsDir]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\11\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\11\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Corel Presentations\11\Presentation\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Graphics\11\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\11\Location of Help Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\11.0\AddIns\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\Paradox\11.0\Experts\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\11\ChartTool [FillPath]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\11\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuattroPro\11\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\QuickFinder\11\Preferences\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Java\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\Location of Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\MRULists\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\SGML [Open Dialog Default Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\SGML [Template Folder]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\SGML\Catalog Files\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\SGML\DTD to LGC\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WordPerfect\11\SGML\Layout Designer\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Grammatik\* [Advice File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Grammatik\* [Help File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Grammatik\* [History File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Grammatik\* [Mor Dictionary]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Grammatik\* [Rule File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Thesaurus\* [Data File]</pattern>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\Main Word Lists\* [*]</pattern>
          </objectSet>
        </exclude>
        <!--WordPerfectOffice11 Regfile-->
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\User Word Lists\* [Name]</pattern>
            <content filter="MigXmlHelper.ExtractSingleFile(NULL,NULL)">
              <objectSet>
                <pattern type="Registry">HKCU\Software\Corel\WritingTools\11\User Word Lists\* [Name]</pattern>
              </objectSet>
            </content>
          </objectSet>
        </include>
        <!--WordPerfectOffice11 Copyfiles-->
        <include>
          <objectSet>
            <pattern type="File">%WpOffice11Dad%\* [*]</pattern>
            <pattern type="File">%CorelQPro11ConfPath%\QuattroPro11\ [*.cfg]</pattern>
            <pattern type="File">%CorelQPro11Profiles%\* [*]</pattern>
            <pattern type="File">%CorelQPro11Profiles2%\* [*]</pattern>
            <pattern type="File">%wp11toolbars%\* [*]</pattern>
          </objectSet>
        </include>
        <!--WordPerfectOffice11 ForceSrcFile -->
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CorelQPro11ConfPath%\QuattroPro11\ [*.cfg]</pattern>
            <pattern type="File">%CorelQPro11Profiles%\* [*]</pattern>
            <pattern type="File">%CorelQPro11Profiles2%\* [*]</pattern>
            <pattern type="File">%wp11toolbars%\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
      <rules context="System">
        <!--WordPerfectOffice11 Addreg-->
        <include>
          <objectSet>
            <pattern type="Registry">HKLM\Software\Corel\WritingTools\11 [DefaultTextDialect]</pattern>
          </objectSet>
        </include>
      </rules>
    </role>
  </component>

  <!--AOL Instant messenger 5 and 6 -->
  <component type="Application" context="UserAndSystem">
    <displayName _locID="migapp.AOLInstantmessenger">AOL Instant Messenger</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="AOLInstallPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\App Paths\aim.exe [Path]")</script>
      </variable>
      <variable name="AOLInstallPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\AOL\AIM\6 [Island]")</script>
      </variable>
    </environment>
    <environment context="User">
      <conditions>
        <condition>MigXmlHelper.DoesFileVersionMatch("%AOLInstallPath%\aim.exe","ProductVersion","5.*")</condition>
      </conditions>
      <variable name="AOLRegPath">
        <text>HKCU\Software\America Online\AOL Instant Messenger (TM)\CurrentVersion</text>
      </variable>
    </environment>
    <environment context="User">
      <conditions>
        <condition>MigXmlHelper.DoesFileVersionMatch("%AOLInstallPath%\aim6.exe","ProductVersion","1.*")</condition>
      </conditions>
      <variable name="AOLRegPath">
        <text>HKCU\Software\America Online\AIM6</text>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%AOLRegPath%")</condition>
        </detect>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%AOLInstallPath%\aim.exe","ProductVersion","5.*")</condition>
          <condition>MigXmlHelper.DoesFileVersionMatch("%AOLInstallPath%\aim6.exe","ProductVersion","1.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">%AOLRegPath%\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">%AOLRegPath%\Misc\ [BaseDataPath]</pattern>
            <pattern type="Registry">%AOLRegPath%\Misc\ [DataPath]</pattern>
            <pattern type="Registry">%AOLRegPath%\Login\* [*]</pattern>
            <pattern type="Registry">%AOLRegPath%\AppPath\* [*]</pattern>
            <pattern type="Registry">%AOLRegPath%\Buddy\* [*]</pattern>
            <pattern type="Registry">%AOLRegPath%\AutoUpgrade\* [*]</pattern>
            <pattern type="Registry">%AOLRegPath%\WindowPos\* [*]</pattern>
            <pattern type="Registry">%AOLRegPath%\Location\* [*]</pattern>
          </objectSet>
        </exclude>
      </rules>
    </role>
  </component>

  <!-- Corel Paintshop Pro 9 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.CorelPaintShop">Corel PaintShop</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="PaintShopInstPath">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Jasc\Paint Shop Pro 9\Installer\ [InstallDirectory]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Jasc\Paint Shop Pro 9")</condition>
        </detect>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%PaintShopInstPath%\Paint Shop Pro 9.exe","ProductVersion","9.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Jasc Software Inc\Paint Shop Pro 9\Cache\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Jasc\Paint Shop Pro 9\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Jasc\Paint Shop Pro 9\FileLocations\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Jasc\Paint Shop Pro 9\General\ [Default Workspace]</pattern>
            <pattern type="Registry">HKCU\Software\Jasc\Paint Shop Pro 9\General\PhotoSharing [Service]</pattern>
            <pattern type="Registry">HKCU\Software\Jasc\Paint Shop Pro 9\Installer\ [CacheFolder]</pattern>
          </objectSet>
        </exclude>
      </rules>
    </role>
  </component>

   <!-- Mozilla Firefox -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.firefox">Mozilla Firefox</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Mozilla\Mozilla Firefox *.*\bin [PathToExe]")</condition>
	  <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Mozilla\Mozilla Firefox\*.*\Main [PathToExe]")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Mozilla\Firefox\Profiles\*\Cache\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Mozilla\Firefox\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Mozilla\Firefox\Profiles\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Mozilla\Firefox\Crash Reports\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Mozilla\Firefox\Profiles\*\ [pluginreg.dat]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Mozilla\Firefox\Profiles\*\Cache\* [*]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Mozilla\Firefox\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Mozilla\Firefox\Profiles\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

    <!-- Mozilla Thunderbird -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.thunderbird">Mozilla Thunderbird</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","%HklmWowSoftware%\Mozilla\Mozilla Thunderbird *.*\bin [PathToExe]")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Thunderbird\Profiles\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Thunderbird\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Thunderbird\Crash Reports\* [*]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Thunderbird\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>
  
  <!-- Safari 4 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.safari4">Safari</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="SafariInstallDir">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Apple Computer, Inc.\Safari [InstallDir]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%SafariInstallDir%\Safari.exe","ProductVersion","4*")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Apple Computer\Safari [Cache.db]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\Safari\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\Preferences [com.apple.Safari.plist]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\Preferences [PubSub.plist]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Apple Computer\Safari\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Apple Computer\Safari [Cache.db]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\Safari\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\Preferences [com.apple.Safari.plist]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Apple Computer\Preferences [PubSub.plist]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Apple Computer\Safari\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Opera 9 -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.opera9">Opera</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="OperaInstallDir">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Netscape\Netscape Navigator\Opera\main [Install Directory]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesFileVersionMatch("%OperaInstallDir%\opera.exe","ProductVersion","9.*")</condition>
        </conditions>
      </detection>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|User Prefs[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|HotListWindow[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Security Prefs[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Windows[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Colors[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Proxy[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Performance[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Saved Settings[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Network[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Sounds[*]</pattern>
            <pattern type="Ini">%CSIDL_APPDATA%\Opera\Opera\profile\opera6.ini|Multimedia[*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Opera\Opera\profile\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Opera\Opera\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Opera\Opera\profile [opera6.ini]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Opera\Opera\profile\cache4\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Opera\Opera\profile\opcache\* [*]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Opera\Opera\profile\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Opera\Opera\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!--Ad-aware 6 Professional  -->
  <component context="UserAndSystem" type="Application">
    <displayName _locID="migapp.adaware">Ad-aware 6 Professional</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="AdawareInstPath">
        <objectSet>
          <content filter='MigXmlHelper.ExtractDirectory (",", "1")'>
            <objectSet>
              <pattern type="Registry">%HklmWowSoftware%\Microsoft\Windows\CurrentVersion\Uninstall\Ad-aware 6 Professional [DisplayIcon]</pattern>
            </objectSet>
          </content>
        </objectSet>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%AdawareInstPath%\Ad-aware.exe","ProductVersion","6.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <destinationCleanup>
          <objectSet>
            <pattern type="File">%AdawareInstPath%\Cache\ [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\VirtualStore\Program Files\Lavasoft\Ad-aware 6\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\VirtualStore\Program Files (X86)\Lavasoft\Ad-aware 6\* [*]</pattern>
          </objectSet>
        </destinationCleanup>
        <include>
          <objectSet>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|Custom[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|UserPrefChain[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|UserPrefChainEx[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|StartupPrefs[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|WebUpdate[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|WindowMetrics[*]</pattern>
          </objectSet>
        </include>
        <locationModify script="MigXmlHelper.RelativeMove('%AdawareInstPath%','%AdawareInstPath%')">
          <objectSet>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|Custom[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|UserPrefChain[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|UserPrefChainEx[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|StartupPrefs[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|WebUpdate[*]</pattern>
            <pattern type="Ini">%AdawareInstPath%\prefs.ini|WindowMetrics[*]</pattern>
          </objectSet>
        </locationModify>
      </rules>
    </role>
  </component>

  <!-- Skype 3 -->
  <component type="Application" context="UserAndSystem">
    <displayName _locID="migapp.Skype">Skype</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64"/>
    <environment>
      <variable name="SkypeExe">
        <script>MigXmlHelper.GetStringContent("Registry","%HklmWowSoftware%\Skype\Phone [SkypePath]")</script>
      </variable>
    </environment>
    <role role="Settings">
      <detects>
        <detect>
          <condition>MigXmlHelper.DoesFileVersionMatch("%SkypeExe%","ProductVersion","3.*")</condition>
        </detect>
      </detects>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Skype\Installer\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Skype\Phone\UI\General\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Skype\PluginManager\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Skype\ProtectedStorage\* [*]</pattern>
            <pattern type="File">%CSIDL_APPDATA%\Skype\* [*]</pattern>
          </objectSet>
        </include>
        <exclude>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Skype\PluginManager [Plugins Root]</pattern>
          </objectSet>
        </exclude>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_APPDATA%\Skype\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Google Talk 1 -->
  <component type="Application" context="UserAndSystem">
    <displayName _locID="migapp.GoogleTalk">Google Talk</displayName>
    <environment name="GlobalEnv" />
    <environment name="GlobalEnvX64"/>
    <role role="Settings">
      <detection>
        <conditions>
          <condition>MigXmlHelper.DoesObjectExist("Registry","HKCU\Software\Google\Google Talk")</condition>
          <conditions operation="OR">
            <!-- For XP, Vista and Win7 Compat Mode -->
            <condition>MigXmlHelper.DoesFileVersionMatch("%ProgramFiles32bit%\Google\Google Talk\googletalk.exe","ProductVersion","1,*")</condition>
            <!-- For Win7 -->
            <condition>MigXmlHelper.DoesFileVersionMatch("%CSIDL_APPDATA%\Google\Google Talk\googletalk.exe","ProductVersion","1,*")</condition>
          </conditions>
        </conditions>
      </detection>
      <rules context="User">
        <include>
          <objectSet>
            <pattern type="Registry">HKCU\Software\Google\Google Talk\Accounts\* [*]</pattern>
            <pattern type="Registry">HKCU\Software\Google\Google Talk\Options\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Google\Google Talk\avatars\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Google\Google Talk\chatlogs\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Google\Google Talk\themes\user\* [*]</pattern>
          </objectSet>
        </include>
        <merge script="MigXmlHelper.SourcePriority()">
          <objectSet>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Google\Google Talk\avatars\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Google\Google Talk\chatlogs\* [*]</pattern>
            <pattern type="File">%CSIDL_LOCAL_APPDATA%\Google\Google Talk\themes\user\* [*]</pattern>
          </objectSet>
        </merge>
      </rules>
    </role>
  </component>

  <!-- Microsoft Office 2010 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.office14">Microsoft Office 2010</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
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
            <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
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
      <component  context="UserAndSystem" type="Application">
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
              <detection name="Word_x32_64OS"/>
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
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.office15">Microsoft Office 15</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
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
            <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
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
      <component  context="UserAndSystem" type="Application">
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
          <detection name="Word_x64"/>
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
          <rules name="Office15to15SettingsMigrate_x64"/>
        </role>
      </component>
    </role>
  </component>

  <!-- Microsoft Office 16 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.office16">Microsoft Office 16</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
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
            <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
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
      <component  context="UserAndSystem" type="Application">
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
          <detection name="Word_x64"/>
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
          <rules name="Office16to16SettingsMigrate_x64"/>
        </role>
      </component>
    </role>
  </component>

  <!-- Microsoft Office 17 -->
  <component context="UserAndSystem"  type="Application">
    <displayName _locID="migapp.office17">Microsoft Office 17</displayName>
    <environment name="GlobalEnv"/>
    <environment name="GlobalEnvX64"/>
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
            <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
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
      <component  context="UserAndSystem" type="Application">
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
          <detection name="Word_x64"/>
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
          <rules name="Office17to17SettingsMigrate_x64"/>
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

    <!-- This component migrates Shared Video files -->
    <component type="Documents" context="System">
        <displayName _locID="miguser.sharedvideo">Shared Video</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_VIDEO%</path>
        </paths>
        <role role="Data">
            <detects>
                 <detect>
                     <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_VIDEO%")</condition>
                 </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_VIDEO%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_VIDEO% [desktop.ini]</pattern>
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

    <!-- This component migrates Shared Music files -->
    <component type="Documents" context="System">
        <displayName _locID="miguser.sharedmusic">Shared Music</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_MUSIC%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_MUSIC%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_MUSIC%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_MUSIC%\ [desktop.ini]</pattern>
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

    <!-- This component migrates Shared Desktop files -->
    <component type="Documents" context="System">
        <displayName _locID="miguser.shareddesktop">Shared Desktop</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_DESKTOPDIRECTORY%</path>
        </paths>
        <role role="Settings">
            <detects>
                 <detect>
                     <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_DESKTOPDIRECTORY%")</condition>
                 </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_DESKTOPDIRECTORY%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_DESKTOPDIRECTORY% [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_COMMON_DESKTOPDIRECTORY%\* [*]</pattern>
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

    <!-- This component migrates Shared Start Menu files -->
    <component type ="System" context="System">
        <displayName _locID="miguser.sharedstartmenu">Shared Start Menu</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_STARTMENU%</path>
        </paths>
        <role role="Settings">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_STARTMENU%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_STARTMENU%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_STARTMENU% [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_COMMON_STARTMENU%\* [*]</pattern>
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

    <!-- This component migrates Shared My Documents files -->
    <component type="Documents" context="System">
        <displayName _locID="miguser.shareddocs">Shared Documents</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_DOCUMENTS%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_DOCUMENTS%")</condition>
                </detect>
                <detect>
                    <condition negation="Yes">MigXmlHelper.IsSameObject("File","%CSIDL_PERSONAL%", "%CSIDL_COMMON_DOCUMENTS%")</condition>
                </detect>
            </detects>
            <rules>
                <exclude>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_PICTURES%\* [*]</pattern>
                        <pattern type="File">%CSIDL_COMMON_MUSIC%\* [*]</pattern>
                        <pattern type="File">%CSIDL_COMMON_VIDEO%\* [*]</pattern>
                    </objectSet>
                </exclude>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_DOCUMENTS%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_DOCUMENTS% [desktop.ini]</pattern>
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

    <!-- This component migrates Shared Pictures files -->
    <component type="Documents" context="System">
        <displayName _locID="miguser.sharedpics">Shared Pictures</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_PICTURES%</path>
        </paths>
        <role role="Data">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_PICTURES%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_PICTURES%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_PICTURES% [desktop.ini]</pattern>
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

    <!-- This component migrates Shared Favorites -->
    <component type="System" context="System">
        <displayName _locID="miguser.sharedfavs">Shared Favorites</displayName>
        <paths>
            <path type="File">%CSIDL_COMMON_FAVORITES%</path>
        </paths>
        <role role="Settings">
            <detects>
                <detect>
                    <condition>MigXmlHelper.DoesObjectExist("File","%CSIDL_COMMON_FAVORITES%")</condition>
                </detect>
            </detects>
            <rules>
                <include filter='MigXmlHelper.IgnoreIrrelevantLinks()'>
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_FAVORITES%\* [*]</pattern>
                    </objectSet>
                </include>
                <merge script="MigXmlHelper.DestinationPriority()">
                    <objectSet>
                        <pattern type="File">%CSIDL_COMMON_FAVORITES% [desktop.ini]</pattern>
                        <pattern type="File">%CSIDL_COMMON_FAVORITES%\* [*]</pattern>
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

    <!-- This component migrates user files with known extension-->
    <component type="Documents" context="System">
        <displayName _locID="miguser.userdata">User Data</displayName>
        <role role="Data">
            <rules>
                <include>
                    <objectSet>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.enl*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.frm*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.MYD*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.MYI*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.opt*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.ppt*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qdf]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qsd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qel]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qph]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.doc*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.dot*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.rtf]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.mcw]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wps]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.scd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wri]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wpd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.xl*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.csv]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.iqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.dqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.oqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.rqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wk*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wq1]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.slk]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.dif]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.pdf*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pps*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pot*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.sh3]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.ch3]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pre]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.ppa]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.txt]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pst]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.one*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.vl*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.vsd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.mpp]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.or6]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.accdb]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.mdb]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pub]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.sql]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.msg]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.js]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.gif]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.jpg]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.jpeg]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.png]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.bmp]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.tif]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.tiff]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.zip]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.rar]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.wmv]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.mp4]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.mp3]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.mov]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.odt]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.tsv]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.xml]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.eml]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.htm*]", "Fixed")</script>
                    </objectSet>
                </include>
<!-- Uncomment the following if you want all the files collected from the above rules to move to <systemDrive>:\data -->
<!--            
                <locationModify script="MigXmlHelper.Move('%SYSTEMDRIVE%\Data')">
                    <objectSet>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.enl*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.frm*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.MYD*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.MYI*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.opt*]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.ppt*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qdf]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qsd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qel]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.qph]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.doc*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.dot*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.rtf]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.mcw]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wps]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.scd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wri]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wpd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.xl*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.csv]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.iqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.dqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.oqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.rqy]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wk*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.wq1]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.slk]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.dif]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.pdf*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pps*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pot*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.sh3]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.ch3]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pre]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.ppa]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.txt]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pst]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.one*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.vl*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.vsd]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.mpp]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.or6]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.accdb]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.mdb]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("* [*.pub]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.sql]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.msg]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.js]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.gif]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.jpg]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.jpeg]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.png]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.bmp]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.tif]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.tiff]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.zip]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.rar]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.wmv]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.mp4]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.mp3]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.mov]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.odt]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.tsv]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.xml]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.eml]", "Fixed")</script>
						<script>MigXmlHelper.GenerateDrivePatterns ("* [*.htm*]", "Fixed")</script>
                    </objectSet>
                </locationModify>
-->
                <exclude>
                    <objectSet>
                        <pattern type="File">%PROFILESFOLDER%\* [*]</pattern>
                        <pattern type="File">%CSIDL_WINDOWS%\* [*]</pattern>
                        <pattern type="File">%CSIDL_PROGRAM_FILES%\* [*]</pattern>
                        <!--We are trying to remove system files from other windows installation on the same machine-->
                        <!--This is the best guess we can come up with, in case of these folder name localized, we might not be
                         to do whatever we have intended here-->
                        <script>MigXmlHelper.GenerateDrivePatterns ("\Program Files\* [*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("\Winnt\* [*]", "Fixed")</script>
                        <script>MigXmlHelper.GenerateDrivePatterns ("\Windows\* [*]", "Fixed")</script>
                    </objectSet>
                </exclude>
            </rules>
        </role>
    </component>

</migration>
"@

#endregion miguser xml
