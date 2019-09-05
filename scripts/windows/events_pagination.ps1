# USAGE: To run pass in the following parameters when calling this script:
#
#   -StartDate (Start date to pull events from) | Events within a 45 days range can be requested
#   -EndDate (End date to stop pulling events) | OPTIONAL if not specified the EndDate will be the current date
#   -IncrementType (Type of time increments to pull. Valid values: days, hours, minutes)
#   -IncrementAmount (Number of increments to pull.)
#   -FileType (Type of output file. Valid values: txt, JSON) | OPTIONAL default value is txt
#   -JumpCloudAPIKey Your JumpCloudAPIKey can be found in the admin portal.
#
# Example:
# ./events_pagination.ps1 -StartDate 8/1/2019 -EndDate 8/3/2019 -IncrementType hours -IncrementAmount 6 -JumpCloudAPIKey lu8792c9d4y2398is1tb6h0b83ebf0e92s97t382
#
# This example will pull all events from 8/1/2019 to 8/3/2019 in 6 hour increments and output them to a file named jcevents_20190801_20190803.txt

param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateSet("hours", "minutes", "days")]$IncrementType,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][Int]$IncrementAmount,
    [Parameter(
        Mandatory = $True,
        ValueFromPipelineByPropertyName,
        Position = 0)]
    [ValidateScript( {
            If (!($_ -ge ((Get-Date).Date).AddDays(-45)))
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
        Mandatory = $false,
        ValueFromPipelineByPropertyName,
        Position = 1)]
    [ValidateScript( {
            If (!($_ -ge ((Get-Date).Date).AddDays(-45)))
            {
                Throw 'Value must be within 45 days of current date.'
            }
            Else
            {
                $true
            }
        })]
    [datetime]$EndDate = (Get-Date),

    [Parameter(Mandatory = $false)]
    [ValidateSet("txt", "json")]
    [string]$FileType = 'txt',

    [Parameter(Mandatory = $true,
        Position = 0,
        HelpMessage = "Please enter your JumpCloud API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console.") ]
    [ValidateScript( {
            If (($_).Length -ne 40)
            {
                Throw "Please enter your API key. This can be found in the JumpCloud admin console within 'API Settings' accessible from the drop down icon next to the admin email address in the top right corner of the JumpCloud admin console."
            }

            Else { $true }
        })]
    [string]$JumpCloudAPIKey


)

if (($endDate -le $startDate))
{
    Write-Error "End date must be later than start date"
    Exit
}

$FileStartDate = Get-Date $StartDate -Format FileDate
$FileEndDate = Get-Date $EndDate -Format FileDate
$EventsArray = @()
$OutFileName = "jcevents_" + $FileStartDate + "_" + $FileEndDate + ".$FileType"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$TimeIncrements = Do
{
    $startDate = Switch ($IncrementType)
    {
        'hours' { (Get-Date -Date:($startDate)).AddHours($IncrementAmount) }
        'minutes' { (Get-Date -Date:($startDate)).AddMinutes($IncrementAmount) }
        'days' { (Get-Date -Date:($startDate)).AddDays($IncrementAmount) }
        Default { Write-Error ('Unknown increment value.') }
    }
    (Get-Date -Date:($startDate) -Format s)
}
Until ($startDate -ge $endDate)
For ($i = 1; $i -le $TimeIncrements.Length - 1; $i++)
{
    $startTime = ($TimeIncrements[$i - 1])
    $endTime = ($TimeIncrements[$i])
    Write-Host ('Pulling events from ' + $startTime + ' to ' + $endTime)
    $UrlTemplate = 'https://events.jumpcloud.com/events?startDate={0}Z&endDate={1}Z'
    $url = $UrlTemplate -f $startTime, $endTime
    $hdrs = @{"X-API-KEY" = "$JumpCloudAPIKey" }
    $events = Invoke-RestMethod -Method GET -Uri $url -Header $hdrs
    if ($events)
    {
        Write-Host ("$($events.count) " + 'events found in range ' + $startTime + ' to ' + $endTime )
        $EventsArray += $events
    }


}

$EventsArray | ConvertTo-Json | Out-File -append "$OutFileName"
