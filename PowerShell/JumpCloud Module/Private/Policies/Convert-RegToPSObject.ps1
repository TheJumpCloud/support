function Convert-RegToPSObject {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-Not ($_ | Test-Path) ) {
                    throw "File or folder does not exist"
                }
                if (-Not ($_ | Test-Path -PathType Leaf) ) {
                    throw "The Path argument must be a file. Folder paths are not allowed."
                }
                if ($_ -notmatch "(\.reg)") {
                    throw "The file specified in the path argument must be of type reg"
                }
                return $true
            })]
        [System.IO.FileInfo]$regFilePath
    )
    begin {
        $regKeys = [System.Collections.ArrayList]@()
        [string]$text = $null
        $regContent = Get-Content $RegFilePath | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }
        $joinedlines = @()
        for ($i = 0; $i -lt $regContent.count; $i++) {
            if ($regContent[$i].EndsWith("\")) {
                $text = $text + ($regContent[$i] -replace "\\").trim()
            } else {
                $joinedlines += $text + $regContent[$i]
                [string]$text = $null
            }
        }
    }
    process {
        foreach ($line in $joinedlines) {
            # Extract the registry path
            if ($line.StartsWith("[")) {
                # Throw error if registry is no HKEY_LOCAL_MACHINE
                if ($line -notmatch "HKEY_LOCAL_MACHINE") {
                    throw "JumpCloud Policies only support HKEY_LOCAL_MACHINE/HKLM registry keys"
                } else {
                    $path = $line.TrimStart("[").TrimEnd("]").Replace("HKEY_LOCAL_MACHINE", "").Replace("\\\\", "\\").TrimStart('\')
                }
            } else {
                # Extract Values
                if ($line.Contains("=")) {
                    $valueObject = $($line.Split("=")).Trim("`"")
                    $valueName = $($valueObject[0]).Trim()
                    if ($valueObject[1].StartsWith("dword:")) {
                        #DWORD
                        $customRegType = "DWORD"
                        $customData = [int]"0x$(($valueObject[1]).Substring(6))"
                    } elseif ($valueObject[1].StartsWith("hex(b):")) {
                        #QWORD
                        $customRegType = "QWORD"
                        $value = ($valueObject[1]).Substring(7).split(",")
                        # Convert to value
                        $value = for ($i = $value.count - 1; $i -ge 0; $i--) {
                            $value[$i]
                        }
                        $hexValue = '0x' + ($value -join "").trimstart('0')
                        $customData = [int]$hexValue
                    } elseif ($valueObject[1].StartsWith("hex(7):")) {
                        #MULTI_SZ
                        $customRegType = "multiString"
                        $value = ($valueObject[1]).Replace("hex(7):", "").split(",")
                        $value = for ($i = 0; $i -lt $value.count; $i += 2) {
                            if ($value[$i] -ne '00') {
                                [string][char][int]('0x' + $value[$i])
                            } else {
                                "\0"
                            }
                        }
                        $customData = $value -join ""
                    } elseif ($valueObject[1].StartsWith("hex(2):")) {
                        #EXPAND_SZ
                        $customRegType = "expandString"
                        $value = ($valueObject[1]).Substring(7).split(",")
                        $value = for ($i = 0; $i -lt $value.count; $i += 2) {
                            if ($value[$i] -ne '00') {
                                [string][char][int]('0x' + $value[$i])
                            }
                        }
                        $customData = $value -join ""
                    } else {
                        #STRING
                        $customRegType = "String"
                        $customData = $($valueObject[1]).Trim("`"")
                    }

                    # Create PSCustomObject for endpoint
                    $regKey = [PSCustomObject]@{
                        'customLocation'  = $path
                        'customValueName' = $valueName
                        'customRegType'   = $customRegType
                        'customData'      = $customData
                    }

                    # Add object to ArrayList
                    $regKeys.Add($regKey) | Out-Null
                }
            }
        }
    }
    end {
        # Return objectarray containing keys
        return , $regKeys
    }
}