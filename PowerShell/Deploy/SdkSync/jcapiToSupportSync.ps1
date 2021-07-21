[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $RequiredModulesRepo
)
. "$PSScriptRoot/../Get-Config.ps1" -RequiredModulesRepo:($RequiredModulesRepo)

# . ((Get-Item -Path:($PSScriptRoot)).Parent.FullName + '/' + 'Get-Config.ps1') -RequiredModulesRepo:($RequiredModulesRepo)
###########################################################################
$ApprovedFunctions = [Ordered]@{
    'JumpCloud.SDK.DirectoryInsights' = @(
        [PSCustomObject]@{
            Name        = 'Get-JcSdkEvent';
            Destination = '/Public/DirectoryInsights';
        },
        [PSCustomObject]@{
            Name        = 'Get-JcSdkEventCount';
            Destination = '/Public/DirectoryInsights';
        }
    );
    # 'JumpCloud.SDK.V2'                = @(
    #     [PSCustomObject]@{
    #         Name        = 'Get-JcSdkAppleMdm';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Remove-JcSdkAppleMdm';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Set-JcSdkAppleMdm';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Get-JcSdkAppleMdmCsr';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Get-JcSdkAppleMdmDepKey';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Clear-JcSdkAppleMdmDevice';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Get-JcSdkAppleMdmDevice';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Lock-JcSdkAppleMdmDevice';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Restart-JcSdkAppleMdmDevice';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Stop-JcSdkAppleMdmDevice';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Sync-JcSdkAppleMdmDevice';
    #         Destination = '/Public/AppleMdm';
    #     },
    #     [PSCustomObject]@{
    #         Name        = 'Get-JcSdkAppleMdmEnrollmentProfile';
    #         Destination = '/Public/AppleMdm';
    #     }
    # )
}
$SdkPrefix = 'JcSdk'
$JumpCloudModulePrefix = 'JC'
$IndentChar = '    '
$MSCopyrightHeader = "`n# ----------------------------------------------------------------------------------`n#`n# Copyright Microsoft Corporation`n# Licensed under the Apache License, Version 2.0 (the ""License"");`n# you may not use this file except in compliance with the License.`n# You may obtain a copy of the License at`n# http://www.apache.org/licenses/LICENSE-2.0`n# Unless required by applicable law or agreed to in writing, software`n# distributed under the License is distributed on an ""AS IS"" BASIS,`n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.`n# See the License for the specific language governing permissions and`n# limitations under the License.`n# ----------------------------------------------------------------------------------`n"
$Divider = '|#|#|#|#|#|#|#|#|#|#|#|#|#|#|#|'
$FunctionTemplate = "{0}`nFunction {1}`n{{`n$($IndentChar){2}`n$($IndentChar)Param(`n{3}`n$($IndentChar))`n$($IndentChar)Begin`n$($IndentChar){{`n{4}`n$($IndentChar)}}`n$($IndentChar)Process`n$($IndentChar){{`n{5}`n$($IndentChar)}}`n$($IndentChar)End`n$($IndentChar){{`n{6}`n$($IndentChar)}}`n}}"
$ScriptAnalyzerResults = @()
# $JumpCloudModulePath = ((Get-Item -Path:($PSScriptRoot)).Parent.Parent.FullName + '/JumpCloud Module')
$JumpCloudModulePath = "$PSScriptRoot/../../JumpCloud Module"
Get-Module -Refresh -ListAvailable -All | Out-Null
$Modules = Get-Module -Name:($Psd1.RequiredModules | Where-Object { $_ -in $ApprovedFunctions.Keys })
If (-not [System.String]::IsNullOrEmpty($Modules))
{
    ForEach ($Module In $Modules)
    {
        $ModuleName = $Module.Name
        ForEach ($Function In $ApprovedFunctions.$ModuleName)
        {
            $FunctionName = $Function.Name
            $FunctionDestination = $Function.Destination
            $OutputPath = "$JumpCloudModulePath/$FunctionDestination"
            $Command = Get-Command -Name:($FunctionName)
            foreach ($individualCommand in $Command)
            {
                $CommandName = $individualCommand.Name
                $NewCommandName = $CommandName.Replace($SdkPrefix, $JumpCloudModulePrefix)
                Write-Host ("[STATUS] Building: $NewCommandName") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
                # Get content from sdk function
                $CommandFilePath = $individualCommand.ScriptBlock.File
                $CommandFilePathContent = Get-Content -Path:($CommandFilePath) -Raw
                $FunctionContent = If ($CommandFilePath -like '*ProxyCmdletDefinitions.ps1')
                {
                    <# When the autorest generated module has been installed and imported from the PSGallery all the
                    cmdlets will exist in a single ProxyCmdletDefinitions.ps1 file. We need to parse
                    out the specific function in order to gather the parts we need to copy over. #>
                    $CommandFilePathContent.Replace($MSCopyrightHeader, $Divider).Split($Divider) | Where-Object { $_ -like ('*' + "function $CommandName {" + '*') }
                }
                Else
                {
                    <# When the autorest generated module has been imported from a local psd1 module the function will
                    remain in their individual files. #>
                    $CommandFilePathContent
                }
                # Extract the sections we want to copy over to our new function.
                $PSScriptInfo = ($FunctionContent | Select-String -Pattern:([regex]'(?s)(<#)(.*?)(#>)')).Matches.Value
                $Params = $FunctionContent | Select-String -Pattern:([regex]'(?s)(    \[Parameter)(.*?)(\})') -AllMatches
                $ParameterContent = ($Params.Matches.Value | Where-Object { $_ -notlike '*DontShow*' -and $_ -notlike '${Limit}' -and $_ -notlike '*${Skip}*' })
                $OutputType = (($FunctionContent | Select-String -Pattern:([regex]'(\[OutputType)(.*?)(\]\s+)')).Matches.Value).TrimEnd()
                $CmdletBinding = (($FunctionContent | Select-String -Pattern:([regex]'(\[CmdletBinding)(.*?)(\]\s+)')).Matches.Value).TrimEnd()
                If (-not [System.String]::IsNullOrEmpty($PSScriptInfo))
                {
                    $PSScriptInfo = $PSScriptInfo.Replace($SdkPrefix, $JumpCloudModulePrefix)
                    $PSScriptInfo = $PSScriptInfo.Replace("$NewCommandName.md", "$FunctionName.md")
                }
                # Build CmdletBinding
                If (-not [System.String]::IsNullOrEmpty($OutputType)) { $CmdletBinding = "$($OutputType)`n$($IndentChar)$($CmdletBinding)" }
                # Build $BeginContent, $ProcessContent, and $EndContent
                $BeginContent = @()
                $ProcessContent = @()
                $EndContent = @()
                # Build "Begin" block
                $BeginContent += "$($IndentChar)$($IndentChar)Connect-JCOnline -force | Out-Null"
                $BeginContent += "$($IndentChar)$($IndentChar)`$Results = @()"
                # Build "Process" block
                $ProcessContent += "$($IndentChar)$($IndentChar)`$Results = $($ModuleName)\$($CommandName) @PSBoundParameters"
                # Build "End" block
                $EndContent += "$($IndentChar)$($IndentChar)Return `$Results"
                If (-not [System.String]::IsNullOrEmpty($BeginContent) -and -not [System.String]::IsNullOrEmpty($ProcessContent) -and -not [System.String]::IsNullOrEmpty($EndContent))
                {
                    # Build "Function"
                    $NewScript = $FunctionTemplate -f $PSScriptInfo, $NewCommandName, $CmdletBinding, ($ParameterContent -join ",`n`n"), ($BeginContent -join "`n"), ($ProcessContent -join "`n"), ($EndContent -join "`n")
                    # Fix line endings
                    $NewScript = $NewScript.Replace("`r`n", "`n").Trim()
                    # Export the function
                    Write-Host ("[STATUS] Writing File: $OutputPath/$NewCommandName") -BackgroundColor:('Black') -ForegroundColor:('Magenta')
                    $OutputFilePath = "$OutputPath/$NewCommandName.ps1"
                    New-FolderRecursive -Path:($OutputFilePath) -Force
                    $NewScript | Out-File -FilePath:($OutputFilePath) -Force
                    # Validate script syntax
                    $ScriptAnalyzerResult = Invoke-ScriptAnalyzer -Path:($OutputFilePath) -Recurse -ExcludeRule PSShouldProcess, PSAvoidTrailingWhitespace, PSAvoidUsingWMICmdlet, PSAvoidUsingPlainTextForPassword, PSAvoidUsingUsernameAndPasswordParams, PSAvoidUsingInvokeExpression, PSUseDeclaredVarsMoreThanAssignments, PSUseSingularNouns, PSAvoidGlobalVars, PSUseShouldProcessForStateChangingFunctions, PSAvoidUsingWriteHost, PSAvoidUsingPositionalParameters
                    If ($ScriptAnalyzerResult)
                    {
                        $ScriptAnalyzerResults += $ScriptAnalyzerResult
                    }
                }
                # Copy tests?
                # Copy-Item -Path:($AutoRest_Tests) -Destination:($JCModule_Tests) -Force
                # Update .Psd1 file
                $Psd1.FunctionsToExport += $NewCommandName
                Update-ModuleManifest -Path:($FilePath_psd1) -FunctionsToExport:($Psd1.FunctionsToExport)
            }
        }
    }
}
Else
{
    Write-Error ('No modules found!')
}