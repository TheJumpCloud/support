function Unlock-Platform() {
    if([System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
        $plat = "Windows"
        $Definition = @"
        using System;
        using System.ComponentModel;
        using System.Runtime.InteropServices;
        using System.Collections.Generic;

        public class CredManager {
            private const int CRED_TYPE_GENERIC = 1;
            private const int CRED_PERSIST_ENTERPRISE = 3;

            [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
            public static extern bool CredRead(string target, int type, int reservedFlag, out IntPtr credentialPtr);

            [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
            public static extern bool CredWrite(ref PCREDENTIAL userCredential, uint flags);

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

                // CredEnumerate with a null filter returns all credential types.
                if (CredEnumerate(null, 0, out count, out pCredentials)) {
                    for (int i = 0; i < count; i++) {
                        IntPtr pCurrent = Marshal.ReadIntPtr(pCredentials, i * IntPtr.Size);
                        PCREDENTIAL cred = (PCREDENTIAL)Marshal.PtrToStructure(pCurrent, typeof(PCREDENTIAL));
                        if (cred.type == CRED_TYPE_GENERIC) {
                            targets.Add(cred.targetName);
                        }
                    }
                    CredFree(pCredentials);
                }
                return targets.ToArray();
            }

            public static string GetCreds(string target) {
                IntPtr credPtr;
                if (CredRead(target, CRED_TYPE_GENERIC, 0, out credPtr)) {
                    try {
                        PCREDENTIAL cred = (PCREDENTIAL)Marshal.PtrToStructure(credPtr, typeof(PCREDENTIAL));
                        int charLen = cred.credentialBlobSize / 2;
                        if (charLen > 0 && Marshal.ReadInt16(cred.credentialBlob, (charLen - 1) * 2) == 0) {
                            charLen--;
                        }
                        return Marshal.PtrToStringUni(cred.credentialBlob, charLen);
                    } finally {
                        CredFree(credPtr);
                    }
                }
                return null;
            }

            public static void SetCreds(string target, string userName, string secret) {
                byte[] secretBytes = System.Text.Encoding.Unicode.GetBytes(secret);
                int byteCount = secretBytes.Length;
                IntPtr blobPtr = Marshal.AllocCoTaskMem(byteCount);
                try {
                    Marshal.Copy(secretBytes, 0, blobPtr, byteCount);
                    PCREDENTIAL cred = new PCREDENTIAL();
                    cred.flags = 0;
                    cred.type = CRED_TYPE_GENERIC;
                    cred.targetName = target;
                    cred.comment = null;
                    cred.lastWritten = 0;
                    cred.credentialBlobSize = byteCount;
                    cred.credentialBlob = blobPtr;
                    cred.persist = CRED_PERSIST_ENTERPRISE;
                    cred.attributeCount = 0;
                    cred.attributes = IntPtr.Zero;
                    cred.targetAlias = null;
                    cred.userName = userName;

                    if (!CredWrite(ref cred, 0)) {
                        throw new Win32Exception(Marshal.GetLastWin32Error());
                    }
                } finally {
                    Marshal.FreeCoTaskMem(blobPtr);
                }
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

    $config = if ($global:JCConfig) { $global:JCConfig } else { Get-JCSettingsFile }
    $script:sufix = if ($config.vault.Suffix) { $config.vault.Suffix } else { '.api.jc' }
}