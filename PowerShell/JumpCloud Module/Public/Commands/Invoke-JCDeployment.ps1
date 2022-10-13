Function Invoke-JCDeployment () {
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'The _id of the JumpCloud command you wish to deploy. To find a JumpCloud CommandID run the command: PS C:\> Get-JCCommand | Select name, _id
The CommandID will be the 24 character string populated for the _id field.')]
        [Alias('_id', 'id')]
        [String]$CommandID,

        [Parameter(Mandatory, HelpMessage = 'The full path to the CSV deployment file. You can use tab complete to search for .csv files.')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [ValidatePattern( '\.csv$' )]
        [string]$CSVFilePath
    )


    begin {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JConline }

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Accept'    = 'application/json'
            'X-API-KEY' = $JCAPIKEY

        }

        if ($JCOrgID) {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initializing resultsArray'
        $resultsArray = @()

        try {

            $DeploymentCommand = Get-JCCommand -ByID $CommandID

            if ( -not $DeploymentCommand) {
                Write-Error "$CommandID is not a valid CommandID. Run command 'Get-JCCommand | Select name, _id' to see a list of your commands"

                Exit

            }
        }

        catch {
            Write-Error "$CommandID is not a valid CommandID. Run command 'Get-JCCommand | Select name, _id' to see a list of your commands"

            Write-Error $_.ErrorDetails

            Exit

        }

        $Targets = Get-JCCommandTarget -CommandID $CommandID

        if ($Targets.SystemID.count -gt 0) {

            Write-Host "`nDeployment command: '$($DeploymentCommand.name)' has $($Targets.SystemID.count) existing system associations.`n" -ForegroundColor Red

            Write-Host "Deployment commands CAN NOT have any systems associated with them.`n"

            Write-Host "During the deployment systems in the DEPLOYMENT CSV will be targeted and then removed from the deployment command.`n"

            Write-Host "Would you like to remove the $($Targets.SystemID.count) systems from the Deployment command: '$($DeploymentCommand.name)' to continue?`n" -ForegroundColor Yellow

            $ConfirmPrompt = $false

            while ($ConfirmPrompt -eq $false) {
                $ConfirmRemoval = Read-Host "Enter 'Y' to remove systems and continue enter 'N' to exit"

                switch ($ConfirmRemoval) {
                    y { $ConfirmPrompt = $True }
                    n {

                        Write-Output "Exited due to system associations"
                        Exit

                    }
                    default {
                        write-warning "$ConfirmPrompt is not a valid choice"
                        Start-Sleep -Seconds 1
                        $ConfirmPrompt = $false
                    }
                }
            }

            if ($ConfirmPrompt -eq $True) {

                $GroupTargets = Get-JCCommandTarget -CommandID $CommandID -Groups

                if ($GroupTargets.GroupID.count -gt 0) {

                    $GroupsRemove = $GroupTargets | % { Remove-JCCommandTarget -CommandID  $CommandID -GroupID $_.GroupID }

                }

                $SystemTargets = Get-JCCommandTarget -CommandID $CommandID

                if ($SystemTargets.SystemID.count -gt 0) {
                    $SystemRemove = $SystemTargets   | Remove-JCCommandTarget -CommandID $CommandID
                }

            }

            $NoTargets = Get-JCCommandTarget -CommandID $CommandID

            if ($NoTargets.SystemID.count -gt 0) {

                Write-Error "`nDeployment command: '$($DeploymentCommand.name)' has $($NoTargets.SystemID.count) existing system associations. Exiting`n"

                Write-Output "Exited due to system associations"
                Exit

            }

            Write-Verbose "Deploy command has zero targets"

        }


    }

    process {
        $trigger = Get-Date -Format MMddyyTHHmmss

        # Get existing data, type, Shell from command
        $ExistingCommand = Get-JCSDKCommand -Id $CommandID

        # set command w/ origional type and new trigger
        $Command = Set-JCSDKCommand -ID $CommandID -launchType trigger -trigger $trigger -Command $ExistingCommand.Command1 -CommandType $ExistingCommand.CommandType -Shell $ExistingCommand.Shell -Name $ExistingCommand.Name

        $DeploymentInfo = Import-Csv $CSVFilePath

        $Variables = $DeploymentInfo[0].psobject.Properties.Name | Where-Object { $_ -ne "SystemID" }

        [int]$NumberOfVariables = $Variables.Count
        [int]$ProgressCounter = 0
        [int]$SystemCount = $DeploymentInfo.SystemID.Count

        foreach ($Target in $DeploymentInfo) {
            $SingleResult = $Null

            $DeploymentParams = @{
                trigger           = "$trigger"
                NumberOfVariables = "$numberofVariables"
            }

            Write-Verbose "Adding SYSTEM: $($Target.SystemID) to DEPLOY COMMAND: $($CommandID)"

            $TargetAdd = Add-JCCommandTarget -CommandID $CommandID -SystemID $Target.SystemID

            [int]$Counter = 1

            foreach ($Var in $Variables) {
                Write-Verbose "Adding PARAMETER: $Var with value $($Target | Select-Object -ExpandProperty $var) to DEPLOY COMMAND"

                $DeploymentParams.Add("Variable" + $($Counter) + "_name", "$Var")
                $DeploymentParams.Add("Variable" + $($Counter) + "_value", "$($Target | Select-Object -ExpandProperty $var)")
                $Counter++
            }

            $null = Invoke-JCCommand @DeploymentParams

            $TargetRemove = Remove-JCCommandTarget -CommandID $CommandID -SystemID $Target.SystemID

            $ProgressCounter++

            $GroupAddProgressParams = @{

                Activity        = "Deploying $($Command.name)"
                Status          = "Command Deployment $ProgressCounter of $SystemCount "
                PercentComplete = ($ProgressCounter / $SystemCount) * 100

            }

            Write-Progress @GroupAddProgressParams

            $SingleResult = [PSCustomObject]@{
                SystemID  = $Target.SystemID
                CommandID = $CommandID
                Status    = "Deployed"
            }

            $resultsArray += $SingleResult

        }
        $null = Set-JCSDKCommand -ID $CommandID -launchType manual -Command $ExistingCommand.Command1 -CommandType $ExistingCommand.CommandType -Shell $ExistingCommand.Shell -Name $ExistingCommand.Name
    }

    end {
        return $resultsArray
    }
}
