Function Remove-JCCommandTarget
{
    [CmdletBinding(DefaultParameterSetName = 'SystemID')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SystemID', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GroupName', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GroupID', Position = 0, HelpMessage = 'The id value of the JumpCloud command. Use the command ''Get-JCCommand | Select-Object _id, name'' to find the "_id" value for all the JumpCloud commands in your tenant.')]
        [Alias('_id', 'id')]
        [String]$CommandID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'SystemID', Position = 1, HelpMessage = 'The _id of a JumpCloud system. To find the _id of all JumpCloud systems within your tenant run ''Get-JCSystem | select _id, hostname''')]
        $SystemID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GroupName', Position = 1, HelpMessage = 'The name of the JumpCloud system group. If the name includes a space enter the name within quotes. Example: -GroupName ''The Space''')]
        [Alias('name')]
        $GroupName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GroupID', Position = 1, HelpMessage = 'The id value of a JumpCloud system group')]
        $GroupID
    )

    begin
    {

        Write-Verbose "Paramter set: $($PSCmdlet.ParameterSetName)"

        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }


        if ($PSCmdlet.ParameterSetName -eq 'GroupName')
        {

            Write-Verbose 'Populating SystemGroupNameHash'
            $SystemGroupNameHash = Get-Hash_SystemGroupName_ID

        }

        Write-Verbose 'Populating CommandNameHash'
        $CommandNameHash = Get-Hash_CommandID_Name

        Write-Verbose 'Initilizing RawResults and resultsArrayList'
        $resultsArray = @()


    }

    process
    {


        switch ($PSCmdlet.ParameterSetName)
        {

            SystemID
            {

                $body = @{

                    type = "system"
                    op   = "remove"
                    id   = $SystemID

                }

            } # end SystemID switch

            GroupName
            {

                $GroupID = $SystemGroupNameHash.($GroupName)

                $body = @{

                    type = "system_group"
                    op   = "remove"
                    id   = $GroupID

                }

            } # end GroupName switch

            GroupID
            {

                $body = @{

                    type = "system_group"
                    op   = "remove"
                    id   = $GroupID

                }
            } # end GroupID switch
        } # end switch


        $jsonbody = $body | ConvertTo-Json
        $URL = "$JCUrlBasePath/api/v2/commands/$($CommandID)/associations"

        try
        {

            $APIresults = Invoke-RestMethod -Method Post -Uri  $URL  -Header $hdrs -Body $jsonbody -UserAgent:(Get-JCUserAgent)
            $Status = 'Removed'

        }
        catch
        {

            $Status = $_.ErrorDetails

        }

        $CommandName = $CommandNameHash.($CommandID)


        $FormattedResults = [PSCustomObject]@{

            'CommandID'   = $CommandID
            'CommandName' = $CommandName
            'Type'        = $body.type
            'id'          = $body.id
            'Status'      = $Status
        }

        $resultsArray += $FormattedResults



    } # end process

    end
    {

        Return $resultsArray
    }
}