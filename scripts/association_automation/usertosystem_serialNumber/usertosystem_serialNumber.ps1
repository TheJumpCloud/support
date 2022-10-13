#region Variables
#*******************************************************************************
#
#       See the ReadMe file for detailed usage notes.
#
#       The "usertosystem_serialNumber.ps1" is a ps1 file designed to be used
#       in tandem with the "usertosystem_serialNumbe.csv" file to automate the
#       associations of JumpCloud users to systems.
#
#       Once configured the "usertosystem_serialNumber.ps1" can be scheduled to
#       run or be run on demand to assocaite users to systems.
#
#       USAGE NOTES:
#
#       Populate the "usertosystem_serialNumber.csv"
#       Populate the $AssociationCSVPath = "" variable will the full file path
#
#       Questions or feedback on the usertosystem_serialNumber.ps1? Please
#       contact support@jumpcloud.com
#
#       Author: Scott Reed | scott.reed@jumpcloud.com
#
#*******************************************************************************

$AssociationCSVPath = ""
$JCAPIKey = ""

#endRegion Variables

#region DataValidation
if (! (Test-Path $AssociationCSVPath)) {
    Write-Error "AssociationCSVPath value is not a correct please input full file path"

}

$ModuleCheck = Get-InstalledModule -Name JumpCloud

if (!$ModuleCheck) {
    Write-Error "The JumpCloud PowerShell module is not installed run the command: 'Install-Module JumpCloud -Scope CurrentUser -Force' to intsall the module and try again."

}

Connect-JCOnline -JumpCloudAPIKey $JCAPIKey -force

$SystemAssociations = Import-Csv $AssociationCSVPath

#endRegion DataValidation

#region Functions

function Associate-JCUsertoJCSystem {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [String]$Username,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [String]$serialNumber,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [Bool]$Administrator

    )

    begin {
        $resultsArray = @()
    }

    process {
        $UserSystemBindInfo = @{
            "Username"      = $Username
            "serialNumber"  = $serialNumber
            "Administrator" = $Administrator
            "Status"        = $null
            "Log"           = $null
        }

        $JCSystemCheck = Get-JCSystem -serialNumber $serialNumber #Change here to search on something besides serialNumber

        switch ($JCSystemCheck._id.count) {
            { $_ -eq 0 } {
                $UserSystemBindInfo.Log = "No action taken no system found with serialNumber: $($serialNumber)"
                $UserSystemBindInfo.Status = "PENDING AGENT INSTALL"
            }
            { $_ -eq 1 } {
                $JCSystemID = $JCSystemCheck._id

                $User = Get-JCUser -username $Username

                if ($User._id.count -eq 1) {
                    if ($User.activated -eq $False) {
                        $UserSystemBindInfo.Log = "No action taken user: $username has not set a password and is in an inactive state."
                        $UserSystemBindInfo.Status = "PENDING USER ACTIVATION"
                        Continue
                    }
                }

                else {
                    $UserSystemBindInfo.Log = "No action taken no user found with username $username"
                    $UserSystemBindInfo.Status = "PENDING USER CREATION"

                    Continue
                }

                try {
                    $UserAdd = Add-JCSystemUser -SystemID $JCSystemID -UserID $User._id -Administrator $Administrator

                    switch ($UserAdd.Status) {
                        Added {
                            $UserSystemBindInfo.Log = "User bound at $(Get-DAte -Format u)"
                            $UserSystemBindInfo.Status = "SUCCESS"
                        }

                        '{"message":"Already Exists"}' {
                            $UserSystemBindInfo.Log = "User already bound"
                            $UserSystemBindInfo.Status = "SUCCESS"
                        }

                        Default {
                            $UserSystemBindInfo.Log = "$($UserAdd.Status)"
                            $UserSystemBindInfo.Status = "SEE LOG"
                        }
                    }


                } catch {
                    $UserSystemBindInfo.Log = $_.ErrorDetails
                    $UserSystemBindInfo.Status = "FAIL"

                }


            }
            { $_ -gt 1 } {
                $UserSystemBindInfo.Log = "No action taken $($JCSystemCheck._id.count) systems found with serialNumber: $($serialNumber)"
                $UserSystemBindInfo.Status = "PENDING DISPLYNAME RESOLUTION"
            }
            Default {
                $UserSystemBindInfo.Log = "Default error"
                $UserSystemBindInfo.Status = "FAIL"
            }
        }

        $formattedResults = [PSCustomObject]@{

            "Username"      = $Username
            "serialNumber"  = $serialNumber
            "Administrator" = $Administrator
            "Log"           = $UserSystemBindInfo.Log
            "Status"        = $UserSystemBindInfo.Status
        }

        $resultsArray += $formattedResults
    }

    end {
        return $resultsArray
    }
}

#endRegion Functions

#region Automation Script
$resultsArrayList = New-Object -TypeName System.Collections.ArrayList
[int]$Counter = 0
[int]$SystemCount = $SystemAssociations.serialNumber.Count

foreach ($Association in $SystemAssociations) {
    $Counter ++

    if ($Association.serialNumber -and $Association.Username -and $Association.Administrator) {

        if ($Association.Status -ne "Success") {
            try {
                $TargetAddProgressParams = @{

                    Activity        = "Attempting association between $($Association.Username) and $($Association.serialNumber)"
                    Status          = "Association: $Counter of $SystemCount"
                    PercentComplete = ($Counter / $SystemCount) * 100

                }


                Write-Progress @TargetAddProgressParams

                $Bind = Associate-JCUsertoJCSystem -Username $Association.Username -serialNumber $Association.serialNumber -Administrator $([System.Convert]::ToBoolean($Association.Administrator))

                $Association.Status = $($Bind.Status)

                $Association.Log = $($Bind.Log)

            } catch {
                $Association.Status = "Fail"
                $Association.Log = $_.ErrorDetails
            }
        }

    }

    $null = $resultsArrayList.Add($Association)

}

$resultsArrayList | ConvertTo-CSV -NoTypeInformation | ForEach-Object { $_ -replace '"', "" } | out-file -FilePath $AssociationCSVPath -Force -Encoding ascii
#endRegion Automation Script