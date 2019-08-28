Function Remove-JCCommandResult ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(ParameterSetName = 'warn', Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the JumpCloud Command Result you wish to query. To find a JumpCloud Command Result run the command: PS C:\> Get-JCCommandResult | Select name, _id
The CommandResultID will be the 24 character string populated for the _id field. CommandResultID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandResultID. This is shown in EXAMPLES 3 and 4.')]
        [Parameter(ParameterSetName = 'force', Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the JumpCloud Command Result you wish to query. To find a JumpCloud Command Result run the command: PS C:\> Get-JCCommandResult | Select name, _id
The CommandResultID will be the 24 character string populated for the _id field. CommandResultID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandResultID. This is shown in EXAMPLES 3 and 4.')]
        [Alias('_id', 'id')]
        [String] $CommandResultID,

        [Parameter(ParameterSetName = 'force', HelpMessage = 'A SwitchParameter which removes the warning message when removing a JumpCloud Command Result.')]
        [Switch]$force
    )

    begin

    {
        Write-Debug 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Debug 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Debug 'Initilizing deleteArray'
        $deleteArray = @()
    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            $URI = "$JCUrlBasePath/api/commandresults/$CommandResultID"

            $result = Get-JCcommandresult -ByID $CommandResultID | Select-Object -ExpandProperty Name #may need to modify this

            Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction Inquire

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            $deleteArray += $delete
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $URI = "$JCUrlBasePath/api/commandresults/$CommandResultID"

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent:(Get-JCUserAgent)

            $deleteArray += $delete
        }
    }

    end
    {

        return $deleteArray

    }


}