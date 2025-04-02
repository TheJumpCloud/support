function Confirm-JCRConfigFile {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to pass into the function when first loading the module, the function will not write an error if this parameter is true'
        )]
        [switch]$loadModule
    )
    begin {
        if ($JCAPIKEY.length -ne 40) {
            Connect-JCOnline -force | Out-Null
        }
        $config = $module.privateData.config
        $requiredAttributesNotSet = @{}
    }

    process {
        # validate config settings
        foreach ($item in $config.keys) {
            $setting = $config[$item]

            # check to see if the key is required and if the value is null
            if ($setting.required -eq $true -and $setting.value -eq $null) {
                $requiredAttributesNotSet += @{ $item = $setting.placeholder }
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
            if (-not $loadModule) {
                Write-Error "Please set these variables with the Set-JCRConfigFile cmdlet"
            } else {
                Write-Warning "Please set these variables with the Set-JCRConfigFile cmdlet"
            }
        }
    }
}