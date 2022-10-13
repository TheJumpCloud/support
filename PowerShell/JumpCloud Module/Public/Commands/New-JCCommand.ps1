Function New-JCCommand {
    [CmdletBinding()]

    param (

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The name of the new JumpCloud command.')]
        [string]$name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The type of JumpCloud command. Options are windows, mac, or linux.')]
        [ValidateSet('windows', 'mac', 'linux')]
        [string]$commandType,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName = $True, HelpMessage = 'The script or command to run using the command.')]
        [string]$command,

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The launch type for the new command. The default is manual.')]
        [ValidateSet('trigger', 'manual')]
        [string]$launchType = 'manual',

        [Parameter(ValueFromPipelineByPropertyName = $True, HelpMessage = 'The time the command will run before it times out. The default is 120 seconds.')]
        [string]$timeout = '120'

    )

    DynamicParam {
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $commandType = 'windows'
        }
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        If ($commandType -eq "windows") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter shell type"
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $attrColl.Add((New-Object System.Management.Automation.ValidateSetAttribute('powershell', 'cmd')))
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('shell', [string], $attrColl)
            $dict.Add('shell', $param)

        }
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $commandType = 'mac'
        }
        If ($commandType -ne "windows") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Only needed for Mac and Linux commands. If not entered Mac and Linux commands will default to the root users. If entering a user a UserID must be entered."
            $attr.ValueFromPipelineByPropertyName = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('user', [string], $attrColl)
            $dict.Add('user', $param)

        }
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $launchType = 'trigger'
        }
        If ($launchType -eq "trigger") {
            $attr = New-Object System.Management.Automation.ParameterAttribute
            $attr.HelpMessage = "Enter a trigger name. Triggers must be unique"
            $attr.ValueFromPipelineByPropertyName = $true
            $attr.Mandatory = $true
            $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attrColl.Add($attr)
            $param = New-Object System.Management.Automation.RuntimeDefinedParameter('trigger', [string], $attrColl)
            $dict.Add('trigger', $param)

        }

        return $dict

    }

    begin {

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JConline }

        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        $URL = "$JCUrlBasePath/api/commands/"

        Write-Verbose 'Initilizing NewCommandsArray'
        $NewCommandsArray = @()

    }

    process {

        Write-Verbose "commandType is $CommandType"

        switch ($commandType) {
            mac {

                if ($PSBoundParameters["user"] -eq $null) {
                    $PSBoundParameters["user"] = "000000000000000000000000"
                }

                $body = @{

                    name        = $name
                    command     = $command
                    commandType = "mac"
                    launchType  = $launchType
                    timeout     = $timeout
                    user        = $PSBoundParameters["user"]
                }

            }

            windows {

                if ($PSBoundParameters["shell"] -eq $null) {
                    $PSBoundParameters["shell"] = "powershell"`

                }

                $body = @{

                    command     = $command
                    commandType = "windows"
                    launchType  = $launchType
                    name        = $name
                    timeout     = $timeout
                    shell       = $PSBoundParameters["shell"]
                }

            }

            linux {

                if ($PSBoundParameters["user"] -eq $null) {
                    $PSBoundParameters["user"] = "000000000000000000000000"
                }

                $body = @{

                    command     = $command
                    commandType = "linux"
                    launchType  = $launchType
                    name        = $name
                    timeout     = $timeout
                    user        = $PSBoundParameters["user"]
                }

            }

            Default {
                Write-Host 'No Command Type'
                break
            }
        }


        if ($PSBoundParameters['launchType'] -eq 'trigger') {

            $body.Add('trigger', $PSBoundParameters['trigger'])

        }

        $jsonbody = $body | ConvertTo-Json

        $NewCommand = Invoke-RestMethod -Uri $URL -Method POST -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        $NewCommandsArray += $NewCommand

    }

    end {

        Return $NewCommandsArray

    }
}