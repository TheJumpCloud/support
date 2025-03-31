function Confirm-JCRConfigFile {
    [CmdletBinding()]
    param (
    )
    begin {
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline -force | Out-Null
        }

        $ModuleRoot = (Get-Item -Path:($PSScriptRoot)).Parent.Parent.Parent.FullName
        $configFilePath = Join-Path -Path $ModuleRoot -ChildPath 'Config.json'
        $rawConfig = Get-Content -Path $configFilePath | ConvertFrom-Json

        $requiredAttributesNotSet = @{}
    }

    process {
        # validate config settings
        foreach ($item in $rawConfig.globalVars) {
            foreach ($property in $item.PSObject.Properties) {
                # check to see if the key is required and if the value is null
                if ($property.Value.required -eq $true -and $property.Value.value -eq $null) {
                    $requiredAttributesNotSet += @{ $property.Name = $property.value.placeholder }
                }
            }
        }
    }
    end {
        if ($requiredAttributesNotSet.count -gt 0) {
            $requiredAttributesNotSet = $requiredAttributesNotSet | Sort-Object
            $requiredAttributesNotSetString = $requiredAttributesNotSet.Keys -join ","
            Write-Warning @"
There are required settings for this module that have not yet been set with the Set-JCRConfigFile function.
The module requires you set: $requiredAttributesNotSetString
To set these run the following command (changing the default settings for your own organization):

`$settings = @{
$($requiredAttributesNotSet.GetEnumerator() | ForEach-Object {
"`t$($_.Key) = $($_.Value)" + [System.Environment]::NewLine
})}

Set-JCRConfigFile @settings
"@
            Write-Error "Please set the following variables with Set-JCConfigFile: $requiredAttributesNotSetString"
        }
    }
}