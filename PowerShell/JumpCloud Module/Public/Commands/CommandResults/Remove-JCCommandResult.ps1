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

        Write-Debug 'Initilizing deleteArray'
        $deleteArray = @()
    }
    process

    {
        if ($PSCmdlet.ParameterSetName -eq 'warn')

        {
            $URI = "https://console.jumpcloud.com/api/commandresults/$CommandResultID"

            $result = Get-JCcommandresult -ByID $CommandResultID | Select-Object -ExpandProperty Name #may need to modify this

            Write-Warning "Are you sure you wish to delete object: $result ?" -WarningAction Inquire

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.4.1'

            $deleteArray += $delete
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'force')
        {

            $URI = "https://console.jumpcloud.com/api/commandresults/$CommandResultID"

            $delete = Invoke-RestMethod -Method Delete -Uri $URI -Headers $hdrs -UserAgent 'Pwsh_1.4.1'

            $deleteArray += $delete
        }
    }

    end
    {

        return $deleteArray

    }


}