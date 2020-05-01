Function New-JCModuleManifest
{
    [cmdletbinding(SupportsShouldProcess = $True)]
    Param()
    DynamicParam
    {
        $Params = @()
        $NewModuleManifestParameterSets = (Get-Command -Name:('New-ModuleManifest')).ParameterSets
        ForEach ($NewModuleManifestParameterSet In $NewModuleManifestParameterSets)
        {
            ForEach ($NewModuleManifestParam In $NewModuleManifestParameterSet.Parameters)
            {
                If ($NewModuleManifestParam.Name -notin @([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters))
                {
                    $Params += @{
                        'ParameterSets'                   = $NewModuleManifestParameterSet.Name;
                        'Name'                            = $NewModuleManifestParam.Name;
                        'Type'                            = $NewModuleManifestParam.ParameterType.FullName;
                        'Mandatory'                       = $NewModuleManifestParam.IsMandatory;
                        'Position'                        = $NewModuleManifestParam.Position;
                        'ValueFromPipeline'               = $NewModuleManifestParam.ValueFromPipeline;
                        'ValueFromPipelineByPropertyName' = $NewModuleManifestParam.ValueFromPipelineByPropertyName;
                        'ValueFromRemainingArguments'     = $NewModuleManifestParam.ValueFromRemainingArguments;
                        # 'HelpMessage'                     = $NewModuleManifestParam.HelpMessage;
                        'Alias'                           = $NewModuleManifestParam.Aliases;
                        # 'DontShow'                        = '';
                        # 'ValidateNotNull'                 = '';
                        # 'ValidateNotNullOrEmpty'          = '';
                        # 'AllowEmptyString'                = '';
                        # 'AllowNull'                       = '';
                        # 'AllowEmptyCollection'            = '';
                        # 'ValidateScript'                  = '';
                        # 'ValidateSet'                     = '';
                        # 'ValidateRange'                   = '';
                        # 'ValidateCount'                   = '';
                        # 'ValidateLength'                  = '';
                        # 'ValidatePattern'                 = '';
                        # 'RuntimeParameterDictionary'      = '';
                    }
                }
            }
        }
        $Params | ForEach-Object {
            New-Object PSObject -Property $_
        } | New-DynamicParameter
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force }
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False') }) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName) }
        $CurrentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }
    Process
    {
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{ }
        If (Test-Path -Path:($Path))
        {
            $FilePath_psd1 = Get-Item -Path:($Path)
            $CurrentModuleManifest = Import-LocalizedData -BaseDirectory:($FilePath_psd1.DirectoryName) -FileName:($FilePath_psd1.BaseName)
            # Add input parameters from function in to hash table and filter out unnecessary parameters
            $CurrentModuleManifest.GetEnumerator() | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
            $PrivateDataPSData = $CurrentModuleManifest['PrivateData']['PSData']
            # New-ModuleManifest parameters that come from previous ModuleManifest PrivateData
            $PrivateDataPSData.GetEnumerator() | ForEach-Object {
                If ($FunctionParameters.Contains($_.Key))
                {
                    $FunctionParameters[$_.Key] = $_.Value
                }
                Else
                {
                    $FunctionParameters.Add($_.Key, $_.Value) | Out-Null
                }
            }
            # Remove previous ModuleManifest PrivateData
            $FunctionParameters.Remove('PrivateData') | Out-Null
            # Update values with values passed in from function
            $PsBoundParameters.GetEnumerator() | ForEach-Object {
                If ($FunctionParameters.Contains($_.Key))
                {
                    $FunctionParameters[$_.Key] = $_.Value
                }
                Else
                {
                    $FunctionParameters.Add($_.Key, $_.Value) | Out-Null
                }
            }
            If ($FunctionParameters.RequiredModules)
            {
                $FunctionParameters.RequiredModules | ForEach-Object {
                    If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $_ })))
                    {
                        Write-Host ('Installing: ' + $_)
                        Install-Module -Name:($_) -Force
                    }
                    If (!(Get-Module -Name:($_)))
                    {
                        Write-Host ('Importing: ' + $_)
                        Import-Module -Name:($_) -Force
                    }
                }
            }
        }
        Else
        {
            Write-Warning ('Creating new module manifest. Please populate empty fields: ' + $Path)
            New-ModuleManifest -Path:($Path)
        }
        Write-Debug ('Splatting Parameters');
        If ($DebugPreference -ne 'SilentlyContinue') { $FunctionParameters }
        New-ModuleManifest @FunctionParameters
    }
    End
    {
        # Validate that the module manifest is valid
        $ModuleValid = Test-ModuleManifest -Path:($FilePath_psd1.FullName)
        If ($ModuleValid)
        {
            $ModuleValid
        }
        Else
        {
            $ModuleValid
            Write-Error ('ModuleManifest is invalid!')
        }
    }
}