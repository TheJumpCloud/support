Function Get-JCEvent ()
{
    [CmdletBinding(DefaultParameterSetName = 'ReturnAll')]
    param
    (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'DateRange',
            Position = 0)]
        [ValidateScript( {
                If (!($_ -ge ((Get-Date).Date).AddDays(-45) -and $_ -lt ((Get-Date).Date)))
                {
                    Throw 'Value must be within 45 days of current date.'
                }
                Else
                {
                    $true
                }
            })]
        [datetime]$StartDate,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'DateRange',
            Position = 1)]
        [ValidateScript( {
                If (!($_ -ge ((Get-Date).Date).AddDays(-45) -and $_ -lt ((Get-Date).Date)))
                {
                    Throw 'Value must be within 45 days of current date.'
                }
                Else
                {
                    $true
                }
            })]
        [datetime]$EndDate = (Get-Date),


        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'TimeFrame',
            Position = 1)]
        [ValidateRange(0, 45)]
        [ValidateScript( {
                If (!(((Get-Date).Date).AddDays(-$_) -ge ((Get-Date).Date).AddDays(-45) -and ((Get-Date).Date).AddDays(-$_) -le ((Get-Date).Date)))
                {
                    Throw 'Value must be within 45 days of current date.'
                }
                Else
                {
                    $true
                }
            })]
        [int]$Days = 0,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'TimeFrame',
            Position = 2)]
        [ValidateRange(0, 1080)]
        [ValidateScript( {
                If (!(((Get-Date).Date).AddHours(-$_) -ge ((Get-Date).Date).AddDays(-45) -and ((Get-Date).Date).AddHours(-$_) -le ((Get-Date).Date)))
                {
                    Throw 'Value must be within 1080 hours of current date.'
                }
                Else
                {
                    $true
                }
            })]
        [int]$Hours = 0,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'TimeFrame', Position = 3)]
        [ValidateRange(0, 64800)]
        [ValidateScript( {
                If (!(((Get-Date).Date).AddMinutes(-$_) -ge ((Get-Date).Date).AddDays(-45) -and ((Get-Date).Date).AddMinutes(-$_) -le ((Get-Date).Date)))
                {
                    Throw 'Value must be within 64800 minutes of current date.'
                }
                Else
                {
                    $true
                }
            })]
        [int]$Minutes = 0,

        [Parameter(
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'TimeFrame',
            Position = 4)]
        [ValidateRange(0, 3888000)]
        [ValidateScript( {
                If (!( ((Get-Date).Date).AddSeconds(-$_) -ge ((Get-Date).Date).AddDays(-45) -and ((Get-Date).Date).AddSeconds(-$_) -le ((Get-Date).Date)))
                {
                    Throw 'Value must be within 3888000 seconds of current date.'
                }
                Else
                {
                    $true
                }
            })]
        [int]$Seconds = 0
    )
    Begin
    {
        Write-Verbose 'Verifying JCAPI Key'
        If ($JCAPIKEY.length -ne 40) {Connect-JCOnline}
        Write-Verbose 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }
        If ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }
        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"
        #####################################################################
        $DayLookBackLimit = 45
        $Url_Template = '{0}/events?startDate={1}&endDate={2}'
        $DateFormat = 'yyyy-MM-ddTHH:mm:ss.fffffffZ'
    }
    Process
    {
        $CurrentDate = Get-Date
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ReturnAll'
            {
                [datetime]$StartDate = $CurrentDate
                [datetime]$EndDate = $CurrentDate
            }
            'TimeFrame'
            {
                [datetime]$StartDate = $CurrentDate.AddDays(-$Days).AddHours(-$Hours).AddMinutes(-$Minutes).AddSeconds(-$Seconds)
                [datetime]$EndDate = $CurrentDate
            }
        }
        # Validate that the $EndDate is within the $DayLookBackLimit limit.
        $DateDiff = $EndDate - $StartDate
        If ($DateDiff.Days -gt $DayLookBackLimit)
        {
            Write-Error ('The total time frame can not be greater than ' + $DayLookBackLimit + ' days. Current time frame is: ' + $DateDiff.Days)
        }
        Else
        {
            # Format DateTime variables and convert into strings.
            $CurrentDateFormated = $CurrentDate.ToUniversalTime().ToString($DateFormat)
            $StartDateFormated = $StartDate.ToUniversalTime().ToString($DateFormat)
            $EndDateFormated = $EndDate.ToUniversalTime().ToString($DateFormat)
            # Build API URI.
            $Uri = $Url_Template -f $JCEventsUrlBasePath, $StartDateFormated, $EndDateFormated
            # Additional logging.
            Write-Verbose ('CurrentDate:   ' + $CurrentDateFormated)
            Write-Verbose ('StartDate:     ' + $StartDateFormated)
            Write-Verbose ('EndDate:       ' + $EndDateFormated)
            Write-Verbose ('Connecting to: ' + $Uri)
            # Make events API call.
            $Results = Invoke-RestMethod -Method GET -Uri:($Uri) -Header:($hdrs)
            # Check to see if API call returned results.
            If (!($Results))
            {
                Write-Warning -Message:('No events found within date range ' + $StartDateFormated + ' to ' + $EndDateFormated + '.')
            }
        }
    }
    End
    {
        Return $Results
    }
}
