Function Set-JCCommand {
    [CmdletBinding()]

    param (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $True, HelpMessage = 'The _id of the JumpCloud command you wish to update.
To find a JumpCloud CommandID run the command:
PS C:\> Get-JCCommand | Select name, _id
The CommandID will be the 24 character string populated for the _id field.')]
        [string]
        $CommandID,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, HelpMessage = 'The name of the new JumpCloud command.')]
        [string]
        $name,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, HelpMessage = 'The actual script or command.')]
        [string]
        $command,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, HelpMessage = 'The launch type of the command options are: trigger, manual, repeated, one-time.')]
        [string]
        [ValidateSet('trigger', 'manual')]
        $launchType,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, HelpMessage = 'The time the command will run before it times out.')]
        [string]
        $timeout

    )

    DynamicParam {
        If ((Get-PSCallStack).Command -like '*MarkdownHelp') {
            $launchType = 'trigger'
        }
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary


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

        $URL = "$JCUrlBasePath/api/commands/$($CommandID)"

        Write-Verbose 'Initilizing NewCommandsArray'
        $NewCommandsArray = @()
    }

    process
    {

        $body = @{}

        $getCommand = Get-JCCommand -commandId $CommandId

        foreach ($param in $PSBoundParameters.GetEnumerator())
        {

            if ([System.Management.Automation.PSCmdlet]::CommonParameters -contains $param.key) { continue }

            if ($param.key -eq 'CommandID', 'JCAPIKey') { continue }
            
            
            $body.add($param.Key, $param.Value)
        }

        if (!$PSBoundParameters.ContainsKey('timeout')) {
            $body.Add("timeout", $getCommand.timeout)        
        }

        if (!$PSBoundParameters.ContainsKey('launchType')) {
            $body.Add("launchType",$getCommand.launchType)
            $body.Add("trigger",$getCommand.trigger)
        }
        $body.add("commandType", $getCommand.commandType)
        # Include commandType to body

        $jsonbody = $body | ConvertTo-Json
        Write-Debug "Json  = $($jsonbody)"
        $NewCommand = Invoke-RestMethod -Uri $URL -Method PUT -Body $jsonbody -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        $NewCommandsArray += $NewCommand
    }

    end {

        Return $NewCommandsArray

    }
}