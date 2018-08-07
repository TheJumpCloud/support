Function Invoke-JCCommandDeployment () 
{
    [CmdletBinding(DefaultParameterSetName = 'NoVariables')]

    param
    (
        
        
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [Alias('_id', 'id')]
        [String]$DeploymentCommandID,

        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf})]
        [ValidatePattern( '\.csv$' )]
        [string]$DeploymentCSVFilePath
        

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

            $DeploymentCommand = Get-JCCommand -ByID $DeploymentCommandID

            if ( -not $DeploymentCommand)
            {
                Write-Error "$DeploymentCommandID is not a valid CommandID. Run command 'Get-JCCommand | Select name, _id' to see a list of your commands"
                Break
            }
        }

        catch
        {
            Write-Error "$DeploymentCommandID is not a valid CommandID. Run command 'Get-JCCommand | Select name, _id' to see a list of your commands"
    
            Write-Error $_.ErrorDetails 
            Break   
        }

        $Targets = Get-JCCommandTarget -CommandID $DeploymentCommandID

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
                    
                $GroupTargets = Get-JCCommandTarget -CommandID $DeploymentCommandID -Groups

                if ($GroupTargets.GroupID.count -gt 0)
                {

                    $GroupsRemove = $GroupTargets | % {Remove-JCCommandTarget -CommandID  $DeploymentCommandID -GroupID $_.GroupID}  
                        
                }

                $SystemTargets = Get-JCCommandTarget -CommandID $DeploymentCommandID 

                if ($SystemTargets.count -gt 0)
                {
                    $SystemRemove = $SystemTargets   | Remove-JCCommandTarget -CommandID $DeploymentCommandID          
                }

            }

            $NoTargets = Get-JCCommandTarget -CommandID $DeploymentCommandID

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

        Set-JCCommand -CommandID $DeploymentCommandID -launchType trigger -trigger $trigger

        $DeploymentInfo = Import-Csv $DeploymentCSVFilePath

        $Variables = $DeploymentInfo[0].psobject.Properties.Name | Where-Object {$_ -ne "SystemID"}

        [int]$NumberOfVariables = $Variables.Count


        foreach ($Target in $DeploymentInfo)
        {
            $DeploymentParams = @{
                trigger           = "$trigger"
                NumberOfVariables = "$numberofVariables"            
            }
            
            Write-Verbose "Adding SYSTEM: $($Target.SystemID) to DEPLOY COMMAND: $($DeploymentCommandID)"
            
            $TargetAdd = Add-JCCommandTarget -CommandID $DeploymentCommandID -SystemID $Target.SystemID

            $Counter = 1

            foreach ($Var in $Variables)
            {
                Write-Verbose "Adding PARAMETER: $Var to DEPLOY COMMAND"

                $DeploymentParams.Add("Variable" + $($Counter) + "_name", "$Var")
                $DeploymentParams.Add("Variable" + $($Counter) + "_value", "$($Target | Select-Object -ExpandProperty $var)")
                $Counter++
            }
            
            Write-Host $DeploymentParams


            #Invoke-JCCommand @DeploymentParams

            $TargetRemove = Remove-JCCommandTarget -CommandID $DeploymentCommandID -SystemID $Target.SystemID


            
        }
         
        Set-JCCommand -CommandID $DeploymentCommandID -launchType manual


    }

    end

    {
        return $resultsArray
    }
}

Invoke-JCCommandDeployment -DeploymentCommandID 5b69b3d5218978234805006d -DeploymentCSVFilePath /Users/sreed/Desktop/JCDeployment_080718T133743.csv