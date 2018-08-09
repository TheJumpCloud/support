Function Invoke-JCDeployment () 
{
    [CmdletBinding(DefaultParameterSetName = 'NoVariables')]

    param
    (
        
        
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$CommandID,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.csv$' )]
        [string]$CSVFilePath
        

    )


    begin

    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Accept'    = 'application/json'
            'X-API-KEY' = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initializing resultsArray'
        $resultsArray = @()

        try
        {

            $DeploymentCommand = Get-JCCommand -ByID $CommandID

            if ( -not $DeploymentCommand)
            {
                Write-Error "$CommandID is not a valid CommandID. Run command 'Get-JCCommand | Select name, _id' to see a list of your commands"
                Break
            }
        }

        catch
        {
            Write-Error "$CommandID is not a valid CommandID. Run command 'Get-JCCommand | Select name, _id' to see a list of your commands"
    
            Write-Error $_.ErrorDetails 
            Break   
        }

        $Targets = Get-JCCommandTarget -CommandID $CommandID

        if ($Targets.count -gt 0)
        {

            Write-Host "`nDeployment command: '$($DeploymentCommand.name)' has $($Targets.count) existing system associations.`n" -ForegroundColor Red

            Write-Host "Deployment commands CAN NOT have any systems associated with them.`n" 

            Write-Host "During the deployment systems in the DEPLOYMENT CSV will be targeted and then removed from the deployment command.`n"

            Write-Host "Would you like to remove the $($Targets.count) systems from the Deployment command: '$($DeploymentCommand.name)' to continue?`n" -ForegroundColor Yellow

            $ConfirmPrompt = $false
        
            while ($ConfirmPrompt -eq $false)
            {
                $ConfirmRemoval = Read-Host "Enter 'Y' to remove systems and continue enter 'N' to exit"

                switch ($ConfirmRemoval)
                {
                    y {$ConfirmPrompt = $True}
                    n
                    {
                        Return 
                    } 
                    default
                    {
                        write-warning "$ConfirmPrompt is not a valid choice"
                        Start-Sleep -Seconds 1
                        $ConfirmPrompt = $false
                    }
                }
            }

            if ($ConfirmPrompt -eq $True)
            {
                    
                $GroupTargets = Get-JCCommandTarget -CommandID $CommandID -Groups

                if ($GroupTargets.GroupID.count -gt 0)
                {

                    $GroupsRemove = $GroupTargets | % {Remove-JCCommandTarget -CommandID  $CommandID -GroupID $_.GroupID}  
                        
                }

                $SystemTargets = Get-JCCommandTarget -CommandID $CommandID 

                if ($SystemTargets.count -gt 0)
                {
                    $SystemRemove = $SystemTargets   | Remove-JCCommandTarget -CommandID $CommandID          
                }

            }

            $NoTargets = Get-JCCommandTarget -CommandID $CommandID

            if ($NoTargets.count -gt 0)
            {

                Write-Error "`nDeployment command: '$($DeploymentCommand.name)' has $($NoTargets.count) existing system associations. Exiting`n" 

                Break
                    
            }

            Write-Verbose "Deploy command has zero targets"
                
        }

        
    }

    process

    {
        $trigger = Get-Date -Format MMddyyTHHmmss

        $Command = Set-JCCommand -CommandID $CommandID -launchType trigger -trigger $trigger

        $DeploymentInfo = Import-Csv $CSVFilePath

        $Variables = $DeploymentInfo[0].psobject.Properties.Name | Where-Object {$_ -ne "SystemID"}

        [int]$NumberOfVariables = $Variables.Count

        [int]$ProgressCounter = 0

        [int]$SystemCount = $DeploymentInfo.SystemID.Count

        foreach ($Target in $DeploymentInfo)
        {
            $DeploymentParams = @{
                trigger           = "$trigger"
                NumberOfVariables = "$numberofVariables"            
            }
            
            Write-Verbose "Adding SYSTEM: $($Target.SystemID) to DEPLOY COMMAND: $($CommandID)"
            
            $TargetAdd = Add-JCCommandTarget -CommandID $CommandID -SystemID $Target.SystemID

            [int]$Counter = 1


            foreach ($Var in $Variables)
            {
                Write-Verbose "Adding PARAMETER: $Var to DEPLOY COMMAND"

                $DeploymentParams.Add("Variable" + $($Counter) + "_name", "$Var")
                $DeploymentParams.Add("Variable" + $($Counter) + "_value", "$($Target | Select-Object -ExpandProperty $var)")
                $Counter++
            }
            
            $null = Invoke-JCCommand @DeploymentParams

            $TargetRemove = Remove-JCCommandTarget -CommandID $CommandID -SystemID $Target.SystemID

            $ProgressCounter++

            $GroupAddProgressParams = @{

                Activity        = "Deploying $($Command.name)"
                Status          = "Command Deployment $Counter of $SystemCount "
                PercentComplete = ($ProgressCounter / $SystemCount) * 100

            }

            Write-Progress @GroupAddProgressParams

            
        }
         
        $null = Set-JCCommand -CommandID $CommandID -launchType manual


    }

    end

    {
        return $resultsArray
    }
}
