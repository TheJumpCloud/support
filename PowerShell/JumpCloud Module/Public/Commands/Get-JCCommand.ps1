
Function Get-JCCommand ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'ByID',
            Position = 0, HelpMessage = 'The _id of the JumpCloud command you wish to query.
To find a JumpCloud CommandID run the command:
PS C:\> Get-JCCommand | Select name, _id
The CommandID will be the 24 character string populated for the _id field.
CommandID has an Alias of _id. This means you can leverage the PowerShell pipeline to populate this field automatically using a function that returns the JumpCloud CommandID. This is shown in EXAMPLES  3 and 4.')]
        [Alias('_id', 'id')]
        [String[]]$CommandID,

        [Parameter(
            ParameterSetName = 'ByID', HelpMessage = 'Use the -ByID parameter when you want to query the contents of a specific command or if the -CommandID is being passed over the pipeline to return the full contents of a JumpCloud command. The -ByID SwitchParameter will set the ParameterSet to ''ByID'' which queries one JumpCloud command at a time.')]
        [Switch]
        $ByID
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

        [int]$limit = '100'
        Write-Debug "Setting limit to $limit"

        Write-Debug 'Initilizing resultsArray and resultsArrayByID'
        $resultsArray = @()
    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'ReturnAll')

        {

            Write-Debug 'Setting skip to zero'
            [int]$skip = 0 #Do not change!

            while (($resultsArray).Count -ge $skip)
            {
                $limitURL = "$JCUrlBasePath/api/commands?sort=type,_id&limit=$limit&skip=$skip"
                Write-Debug $limitURL

                $results = Invoke-RestMethod -Method GET -Uri $limitURL -Headers $hdrs -UserAgent:(Get-JCUserAgent)

                $skip += $limit
                Write-Debug "Setting skip to $skip"

                $resultsArray += $results.results
                $count = ($resultsArray).Count
                Write-Debug "Results count equals $count"
            }
        }

        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')

        {
            foreach ($uid in $CommandID)
            {
                $URL = "$JCUrlBasePath/api/commands/$uid"
                Write-Debug $URL
                $CommandResults = Invoke-RestMethod -Method GET -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent)
                $resultsArray += $CommandResults

            }
        }

    }

    end

    {
        return $resultsArray
    }
}