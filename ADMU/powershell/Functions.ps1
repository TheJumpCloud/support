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
#Check if program is installed on system
function Check_Program_Installed($programName) {
    $installed = $null
    $installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where {$_.DisplayName -match $programName})
    if ($installed -ne $null) {
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
Function Validate-IsNotEmpty ([System.String] $field)
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
Function Validate-Is40chars ([System.String] $field)
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
Function Validate-HasNoSpaces ([System.String] $field)
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
#endregion Functions
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