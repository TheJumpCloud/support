Function Remove-JCCommandResult ()
{
    [CmdletBinding(DefaultParameterSetName = 'warn')]

    param
    (
        [Parameter(
            ParameterSetName = 'warn',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]

        [Parameter(
            ParameterSetName = 'force',
            Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0
        )]

        [Alias('_id', 'id')]
        [String] $CommandResultID,

        [Parameter(
            ParameterSetName = 'force')]
        [Switch]
        $force
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

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent $JCUserAgent

            $deleteArray += $delete
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $URI = "$JCUrlBasePath/api/commandresults/$CommandResultID"

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent $JCUserAgent

            $deleteArray += $delete
        }
    }

    end
    {

        return $deleteArray

    }


}