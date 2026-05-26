function Unlock-Platform() {
    if([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
        $plat = "Windows"
        $Definition = @"
        using System;
        using System.Runtime.InteropServices;
        using System.Collections.Generic;

        public class CredManager {
            [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
            public static extern bool CredRead(string target, int type, int reservedFlag, out IntPtr credentialPtr);

            [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
            public static extern bool CredEnumerate(string filter, int flag, out int count, out IntPtr pCredentials);

            [DllImport("advapi32.dll", SetLastError = true)]
            public static extern void CredFree(IntPtr pBuffer);

            [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
            public struct PCREDENTIAL {
                public int flags;
                public int type;
                public string targetName;
                public string comment;
                public long lastWritten;
                public int credentialBlobSize;
                public IntPtr credentialBlob;
                public int persist;
                public int attributeCount;
                public IntPtr attributes;
                public string targetAlias;
                public string userName;
            }

            public static string[] GetTargetList() {
                int count;
                IntPtr pCredentials;
                List<string> targets = new List<string>();

                // Filtro null traz todas as credenciais genéricas (type 1)
                if (CredEnumerate(null, 0, out count, out pCredentials)) {
                    for (int i = 0; i < count; i++) {
                        // Calcula o endereço de cada item no array de ponteiros
                        IntPtr pCurrent = Marshal.ReadIntPtr(pCredentials, i * IntPtr.Size);
                        PCREDENTIAL cred = (PCREDENTIAL)Marshal.PtrToStructure(pCurrent, typeof(PCREDENTIAL));
                        targets.Add(cred.targetName);
                    }
                    CredFree(pCredentials);
                }
                return targets.ToArray();
            }

            public static string GetCreds(string target) {
                IntPtr credPtr;
                if (CredRead(target, 1, 0, out credPtr)) {
                    PCREDENTIAL cred = (PCREDENTIAL)Marshal.PtrToStructure(credPtr, typeof(PCREDENTIAL));
                    string password = Marshal.PtrToStringUni(cred.credentialBlob, cred.credentialBlobSize / 2);
                    return password;
                }
                return null;
            }
        }
"@
        if (-not ("CredManager" -as [type])) { Add-Type -TypeDefinition $Definition -Language CSharp }
    } elseif([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)) {
        $plat = "MacOS"
        # Will be asked all times, sadly too
        # try {
        #     security unlock-keychain
        # } catch {
        #     throw "Error unlocking keychain: $_"
        # }
    } elseif([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)) {
        $plat = "Linux"
    } else {
        $plat = "Unknown"
    }

    $env:CONSOLE_PLATFORM = $plat
}