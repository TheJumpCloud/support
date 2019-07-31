[CmdletBinding()]

Param (

    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [String]
    [ValidateSet("unbind", "remove")]
    $UserDissociateAction,

    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [String]
    [ValidateSet("deactivate", "retain")]
    $UserTakeoverAction,

    [Parameter(ValueFromPipelineByPropertyName = $True)]
    [String]
    [ValidateSet("sAMAccountName", "userPrincipalName")]
    $UserFieldMapping,

    $JCADB_ConfigfileLocation = 'C:\Program Files\JumpCloud AD Bridge\adint.config.json'

)


#-------------------------------------------------------------------------------
# Script Functions                                                             -
#-------------------------------------------------------------------------------

function CheckMyService ($ServiceName)
{
    if (Get-Service $ServiceName -ErrorAction SilentlyContinue)
    {
        $ServiceStatus = (Get-Service -Name $ServiceName).Status
        Write-Output $ServiceName "-" $ServiceStatus
    }
    else
    {
        Write-Output "$ServiceName not found"
    }
}


#*******************************************************************************
# Script payload and logic                                                     *
#*******************************************************************************

$ServiceName = 'adint'


if (Get-Service $ServiceName -ErrorAction SilentlyContinue)
{
    if ((Get-Service -Name $ServiceName).Status -eq 'Running')
    {
        Write-Output $ServiceName "is running, preparing to stop..."
        Get-Service -Name $ServiceName | Stop-Service -ErrorAction SilentlyContinue
    }

    Write-Output "Correcting values in JCADB Config File..."
    $JCADB_Configfile = Get-Content -Raw -Path $JCADB_ConfigfileLocation | ConvertFrom-Json

    if ($UserDissociateAction)
    {
        $JCADB_Configfile.MainLoop.UserDissociateAction = "$UserDissociateAction"
    }

    if ($UserTakeoverAction)
    {
        $JCADB_Configfile.MainLoop.UserTakeoverAction = "$UserTakeoverAction"

    }
	
    if ($UserFieldMapping)
    {
        $JCADB_Configfile.MainLoop.UserFieldMapping.username = "$UserFieldMapping"

    }

    $JCADB_Configfile = $JCADB_Configfile | ConvertTo-Json
    Set-Content -value $JCADB_Configfile -Path $JCADB_ConfigfileLocation -Force
    ​
    Write-Output $ServiceName "is stopped, preparing to start..."
    Get-Service -Name $ServiceName | Start-Service -ErrorAction SilentlyContinue
    CheckMyService $ServiceName
}

else
{
    Write-Output $ServiceName "is not on this machine."
}