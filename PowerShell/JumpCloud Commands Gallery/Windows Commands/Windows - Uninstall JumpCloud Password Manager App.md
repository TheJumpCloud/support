#### Name

Windows - Uninstall JumpCloud Password Manager App | v1.1.0 JCCG

#### commandType

windows

#### Command

```

# This command completely removes the JumpCloud Password Manager app and all related
# files for the currently logged on JumpCloud managed user (same scope as the install command).

# Get the current logged on User
$loggedUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
$loggedUser = $loggedUser -replace '.*\\'

# Get managed users list
$managedUsers = Get-Content -Path "$env:ProgramFiles\JumpCloud\Plugins\Contrib\managedUsers.json" | ConvertFrom-Json
if ($managedUsers.username -notcontains $loggedUser) {
    Write-Output "User $loggedUser is not a managed user, exiting."
    exit 1
}

# Construct the Registry path using the user's SID
$userSID = (New-Object System.Security.Principal.NTAccount($loggedUser)).Translate([System.Security.Principal.SecurityIdentifier]).Value
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSID"

# Get the ProfileImagePath value from the Registry
$loggedOnUserProfileImagePath = Get-ItemPropertyValue -Path $registryPath -Name 'ProfileImagePath'
Write-Output "Logged On User Profile Path: $loggedOnUserProfileImagePath"

if (-not (Test-Path "$loggedOnUserProfileImagePath\AppData\Local\Temp")) {
    Write-Output "Unable to determine user profile folder"
    exit 1
}

Write-Output "Checking if JumpCloud Password Manager is running."
$process = Get-Process | Where-Object { $_.ProcessName -like "*JumpCloud Password Manager*" }
if ($process) {
    Write-Output "JumpCloud Password Manager is running. Terminating process before uninstall."
    Stop-Process -Name $process.ProcessName -Force
    Start-Sleep -Seconds 5
}

Write-Output 'Uninstalling Password Manager now.'

$Command = {
    $loggedUser = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
    $loggedUser = $loggedUser -replace '.*\\'

    $userSID = (New-Object System.Security.Principal.NTAccount($loggedUser)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$userSID"
    $loggedOnUserProfileImagePath = Get-ItemPropertyValue -Path $registryPath -Name 'ProfileImagePath'

    Write-Output "Removing JumpCloud Password Manager for profile: $loggedOnUserProfileImagePath"

    $appInstallPath = "$loggedOnUserProfileImagePath\AppData\Local\jcpwm"
    if (Test-Path -Path $appInstallPath) {
        Write-Output "Removing application install: $appInstallPath"
        Remove-Item -Path $appInstallPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    $userDataPath = "$loggedOnUserProfileImagePath\AppData\Roaming\JumpCloud Password Manager"
    if (Test-Path -Path $userDataPath) {
        Write-Output "Removing user data: $userDataPath"
        Remove-Item -Path $userDataPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    $tempDir = "$loggedOnUserProfileImagePath\AppData\Local\Temp"
    $tempPatterns = @(
        "JumpCloud-Password-Manager*",
        "jcpwm*"
    )
    if (Test-Path -Path $tempDir) {
        foreach ($pattern in $tempPatterns) {
            Get-ChildItem -Path $tempDir -Filter $pattern -Force -ErrorAction SilentlyContinue | ForEach-Object {
                Write-Output "Removing temp artifact: $($_.FullName)"
                Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    $desktopShortcut = "$loggedOnUserProfileImagePath\Desktop\JumpCloud Password Manager.lnk"
    if (Test-Path -Path $desktopShortcut) {
        Write-Output "Removing desktop shortcut: $desktopShortcut"
        Remove-Item -Path $desktopShortcut -Force -ErrorAction SilentlyContinue
    }

    $startMenuDirectory = "$loggedOnUserProfileImagePath\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\JumpCloud Inc"
    $startMenuShortcut = "$startMenuDirectory\JumpCloud Password Manager.lnk"
    if (Test-Path -Path $startMenuShortcut) {
        Write-Output "Removing Start Menu shortcut: $startMenuShortcut"
        Remove-Item -Path $startMenuShortcut -Force -ErrorAction SilentlyContinue
    }
    if ((Test-Path -Path $startMenuDirectory) -and -not (Get-ChildItem -Path $startMenuDirectory -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $startMenuDirectory -Force -ErrorAction SilentlyContinue
    }

    Write-Output "JumpCloud Password Manager uninstall complete for $loggedUser."
}

$Source = @'
using System;
using System.Runtime.InteropServices;

namespace murrayju.ProcessExtensions
{
   public static class ProcessExtensions
   {
       #region Win32 Constants

       private const int CREATE_UNICODE_ENVIRONMENT = 0x00000400;
       private const int CREATE_NO_WINDOW = 0x08000000;

       private const int CREATE_NEW_CONSOLE = 0x00000010;

       private const uint INVALID_SESSION_ID = 0xFFFFFFFF;
       private static readonly IntPtr WTS_CURRENT_SERVER_HANDLE = IntPtr.Zero;

       #endregion

       #region DllImports

       [DllImport("advapi32.dll", EntryPoint = "CreateProcessAsUser", SetLastError = true, CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
       private static extern bool CreateProcessAsUser(
           IntPtr hToken,
           String lpApplicationName,
           String lpCommandLine,
           IntPtr lpProcessAttributes,
           IntPtr lpThreadAttributes,
           bool bInheritHandle,
           uint dwCreationFlags,
           IntPtr lpEnvironment,
           String lpCurrentDirectory,
           ref STARTUPINFO lpStartupInfo,
           out PROCESS_INFORMATION lpProcessInformation);

       [DllImport("advapi32.dll", EntryPoint = "DuplicateTokenEx")]
       private static extern bool DuplicateTokenEx(
           IntPtr ExistingTokenHandle,
           uint dwDesiredAccess,
           IntPtr lpThreadAttributes,
           int TokenType,
           int ImpersonationLevel,
           ref IntPtr DuplicateTokenHandle);

       [DllImport("userenv.dll", SetLastError = true)]
       private static extern bool CreateEnvironmentBlock(ref IntPtr lpEnvironment, IntPtr hToken, bool bInherit);

       [DllImport("userenv.dll", SetLastError = true)]
       [return: MarshalAs(UnmanagedType.Bool)]
       private static extern bool DestroyEnvironmentBlock(IntPtr lpEnvironment);

       [DllImport("kernel32.dll", SetLastError = true)]
       private static extern bool CloseHandle(IntPtr hSnapshot);

       [DllImport("kernel32.dll")]
       private static extern uint WTSGetActiveConsoleSessionId();

       [DllImport("Wtsapi32.dll")]
       private static extern uint WTSQueryUserToken(uint SessionId, ref IntPtr phToken);

       [DllImport("wtsapi32.dll", SetLastError = true)]
       private static extern int WTSEnumerateSessions(
           IntPtr hServer,
           int Reserved,
           int Version,
           ref IntPtr ppSessionInfo,
           ref int pCount);

       #endregion

       #region Win32 Structs

       private enum SW
       {
           SW_HIDE = 0,
           SW_SHOWNORMAL = 1,
           SW_NORMAL = 1,
           SW_SHOWMINIMIZED = 2,
           SW_SHOWMAXIMIZED = 3,
           SW_MAXIMIZE = 3,
           SW_SHOWNOACTIVATE = 4,
           SW_SHOW = 5,
           SW_MINIMIZE = 6,
           SW_SHOWMINNOACTIVE = 7,
           SW_SHOWNA = 8,
           SW_RESTORE = 9,
           SW_SHOWDEFAULT = 10,
           SW_MAX = 10
       }

       private enum WTS_CONNECTSTATE_CLASS
       {
           WTSActive,
           WTSConnected,
           WTSConnectQuery,
           WTSShadow,
           WTSDisconnected,
           WTSIdle,
           WTSListen,
           WTSReset,
           WTSDown,
           WTSInit
       }

       [StructLayout(LayoutKind.Sequential)]
       private struct PROCESS_INFORMATION
       {
           public IntPtr hProcess;
           public IntPtr hThread;
           public uint dwProcessId;
           public uint dwThreadId;
       }

       private enum SECURITY_IMPERSONATION_LEVEL
       {
           SecurityAnonymous = 0,
           SecurityIdentification = 1,
           SecurityImpersonation = 2,
           SecurityDelegation = 3,
       }

       [StructLayout(LayoutKind.Sequential)]
       private struct STARTUPINFO
       {
           public int cb;
           public String lpReserved;
           public String lpDesktop;
           public String lpTitle;
           public uint dwX;
           public uint dwY;
           public uint dwXSize;
           public uint dwYSize;
           public uint dwXCountChars;
           public uint dwYCountChars;
           public uint dwFillAttribute;
           public uint dwFlags;
           public short wShowWindow;
           public short cbReserved2;
           public IntPtr lpReserved2;
           public IntPtr hStdInput;
           public IntPtr hStdOutput;
           public IntPtr hStdError;
       }

       private enum TOKEN_TYPE
       {
           TokenPrimary = 1,
           TokenImpersonation = 2
       }

       [StructLayout(LayoutKind.Sequential)]
       private struct WTS_SESSION_INFO
       {
           public readonly UInt32 SessionID;

           [MarshalAs(UnmanagedType.LPStr)]
           public readonly String pWinStationName;

           public readonly WTS_CONNECTSTATE_CLASS State;
       }

       #endregion

       // Gets the user token from the currently active session
       private static bool GetSessionUserToken(ref IntPtr phUserToken)
       {
           var bResult = false;
           var hImpersonationToken = IntPtr.Zero;
           var activeSessionId = INVALID_SESSION_ID;
           var pSessionInfo = IntPtr.Zero;
           var sessionCount = 0;

           // Get a handle to the user access token for the current active session.
           if (WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, ref pSessionInfo, ref sessionCount) != 0)
           {
               var arrayElementSize = Marshal.SizeOf(typeof(WTS_SESSION_INFO));
               var current = pSessionInfo;

               for (var i = 0; i < sessionCount; i++)
               {
                   var si = (WTS_SESSION_INFO)Marshal.PtrToStructure((IntPtr)current, typeof(WTS_SESSION_INFO));
                   current += arrayElementSize;

                   if (si.State == WTS_CONNECTSTATE_CLASS.WTSActive)
                   {
                       activeSessionId = si.SessionID;
                   }
               }
           }

           // If enumerating did not work, fall back to the old method
           if (activeSessionId == INVALID_SESSION_ID)
           {
               activeSessionId = WTSGetActiveConsoleSessionId();
           }

           if (WTSQueryUserToken(activeSessionId, ref hImpersonationToken) != 0)
           {
               // Convert the impersonation token to a primary token
               bResult = DuplicateTokenEx(hImpersonationToken, 0, IntPtr.Zero,
                   (int)SECURITY_IMPERSONATION_LEVEL.SecurityImpersonation, (int)TOKEN_TYPE.TokenPrimary,
                   ref phUserToken);

               CloseHandle(hImpersonationToken);
           }

           return bResult;
       }

       public static bool StartProcessAsCurrentUser(string appPath, string cmdLine = null, string workDir = null, bool visible = true)
       {
           var hUserToken = IntPtr.Zero;
           var startInfo = new STARTUPINFO();
           var procInfo = new PROCESS_INFORMATION();
           var pEnv = IntPtr.Zero;
           int iResultOfCreateProcessAsUser;

           startInfo.cb = Marshal.SizeOf(typeof(STARTUPINFO));

           try
           {
               if (!GetSessionUserToken(ref hUserToken))
               {
                   throw new Exception("StartProcessAsCurrentUser: GetSessionUserToken failed.");
               }

               uint dwCreationFlags = CREATE_UNICODE_ENVIRONMENT | (uint)(visible ? CREATE_NEW_CONSOLE : CREATE_NO_WINDOW);
               startInfo.wShowWindow = (short)(visible ? SW.SW_SHOW : SW.SW_HIDE);
               startInfo.lpDesktop = "winsta0\\default";

               if (!CreateEnvironmentBlock(ref pEnv, hUserToken, false))
               {
                   throw new Exception("StartProcessAsCurrentUser: CreateEnvironmentBlock failed.");
               }

               if (!CreateProcessAsUser(hUserToken,
                   appPath, // Application Name
                   cmdLine, // Command Line
                   IntPtr.Zero,
                   IntPtr.Zero,
                   false,
                   dwCreationFlags,
                   pEnv,
                   workDir, // Working directory
                   ref startInfo,
                   out procInfo))
               {
                   throw new Exception("StartProcessAsCurrentUser: CreateProcessAsUser failed.\n");
               }

               iResultOfCreateProcessAsUser = Marshal.GetLastWin32Error();
           }
           finally
           {
               CloseHandle(hUserToken);
               if (pEnv != IntPtr.Zero)
               {
                   DestroyEnvironmentBlock(pEnv);
               }
               CloseHandle(procInfo.hThread);
               CloseHandle(procInfo.hProcess);
           }
           return true;
       }
   }
}


'@

Add-Type -ReferencedAssemblies 'System', 'System.Runtime.InteropServices' -TypeDefinition $Source -Language CSharp
$ApplicationPath = 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe'

$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encodedCommand = [Convert]::ToBase64String($bytes)
$Arguments = '-NoLogo -NonInteractive -ExecutionPolicy ByPass -WindowStyle Hidden -encodedCommand ' + $encodedCommand
[murrayju.ProcessExtensions.ProcessExtensions]::StartProcessAsCurrentUser($ApplicationPath, $Arguments)
```

#### Description

This command completely uninstalls the JumpCloud Password Manager app for the currently logged on JumpCloud managed user—the same scope as the install command. It terminates running Password Manager processes, removes the application install directory (`AppData\Local\jcpwm`), shortcuts, temporary installer files, and all user data under `AppData\Roaming\JumpCloud Password Manager`. On slower networks or while the user session is busy, timeouts with exit code 127 can occur. Manually setting the default timeout limit to 600 seconds may be advisable.

#### _Import This Command_

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
$command = Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Uninstall%20JumpCloud%20Password%20Manager%20App.md"
Set-JCCommand -CommandID $command.id -timeout 600
```
