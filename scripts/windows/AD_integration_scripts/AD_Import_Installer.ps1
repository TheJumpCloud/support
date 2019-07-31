<#
.SYNOPSIS
    Can be used to update or install the JumpCloud AD Import agent
.DESCRIPTION
    Downloads the AD Import agent and launches the installer
.NOTES
    Name: AD_Import_Installer.ps1
    Author: Scott Reed
    Date created: 2019-07-29
.LINK
    http://support.jumpcloud.com
.EXAMPLE
    AD_Import_Installer.ps1
#>


[CmdletBinding()]

Param (

    $AGENT_INSTALLER_URL = "https://s3.amazonaws.com/jumpcloud-windows-agent/production/adbridge/versions/v1.4.1/JumpCloud%20AD%20Bridge%20Setup.exe",

    $AGENT_INSTALLER_PATH = "$env:TEMP\JumpCloud AD Bridge Setup.exe"

)


#-------------------------------------------------------------------------------
# Script Functions                                                             -
#-------------------------------------------------------------------------------

function Get-JCAgentInstallationMedia ($AGENT_INSTALLER_URL, $AGENT_INSTALLER_PATH)
{
    (New-Object System.Net.WebClient).DownloadFile("$AGENT_INSTALLER_URL", "$AGENT_INSTALLER_PATH")
}

function Open-JCAgentInstallationMedia ($AGENT_INSTALLER_PATH)
{
    & $AGENT_INSTALLER_PATH
}

#*******************************************************************************
# Script payload and logic                                                     *
#*******************************************************************************

Get-JCAgentInstallationMedia $AGENT_INSTALLER_URL $AGENT_INSTALLER_PATH

Open-JCAgentInstallationMedia $AGENT_INSTALLER_PATH