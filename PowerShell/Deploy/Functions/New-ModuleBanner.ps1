Function New-ModuleBanner
{
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$LatestVersion
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$BannerCurrent
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][System.String]$BannerOld
    )
    $Content = "#### Latest Version

``````
{0}
``````

#### Banner Current

``````
{1}
``````

#### Banner Old

``````
{2}
``````"
    Return ($Content -f $LatestVersion, $BannerCurrent, $BannerOld)
}