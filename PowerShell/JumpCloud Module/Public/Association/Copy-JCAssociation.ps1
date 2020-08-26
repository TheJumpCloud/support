Function Copy-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365', 'active_directory')][Alias('TypeNameSingular')][System.String]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    DynamicParam
    {
        $Action = 'copy'
        $RuntimeParameterDictionary = If ($Type)
        {
            Get-DynamicParamAssociation -Action:($Action) -Force:($Force) -Type:($Type)
        }
        Else
        {
            Get-DynamicParamAssociation -Action:($Action) -Force:($Force)
        }
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        Connect-JCOnline -force | Out-Null
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        $SearchBy = $PSCmdlet.ParameterSetName
        # Get the associations from the source and target
        Switch ($SearchBy)
        {
            'ById'
            {
                $SourceAssociations = Get-JCAssociation -Type:($Type) -Id:($Id)
                $TargetAssociations = Get-JCAssociation -Type:($Type) -Id:($TargetId)
                $Target = Get-JCObject -Type:($Type) -Id:($TargetId)
            }
            'ByName'
            {
                $SourceAssociations = Get-JCAssociation -Type:($Type) -Name:($Name)
                $TargetAssociations = Get-JCAssociation -Type:($Type) -Name:($TargetName)
                $Target = Get-JCObject -Type:($Type) -Name:($TargetName)
            }
        }
        # Compare the associations
        $CompareResults = Compare-Object -ReferenceObject:(@($SourceAssociations)) -DifferenceObject:(@($TargetAssociations)) -Property:('targetType', 'targetId') -IncludeEqual -PassThru
        # | ForEach-Object {
        #     If ($_.SideIndicator -eq '=>')
        #     {
        #         Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('SideIndicatorName') -Value:($Target.($Target.ByName))
        #     }
        #     ElseIf ($_.SideIndicator -eq '<=')
        #     {
        #         Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('SideIndicatorName') -Value:($Source.($Source.ByName))
        #     }
        #     ElseIf ($_.SideIndicator -eq '==')
        #     {
        #         Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('SideIndicatorName') -Value:('NoDiff')
        #     }
        #     $_
        # }
        $AssociationsToSame = $CompareResults | Where-Object { $_.SideIndicator -eq '==' }
        $AssociationsToRemove = $CompareResults | Where-Object { $_.SideIndicator -eq '=>' -and $_.associationType -eq 'Direct' -and $_.TargetId -notin ($AssociationsToSame.targetId) }
        $AssociationsToAdd = $CompareResults | Where-Object { $_.SideIndicator -eq '<=' -and $_.associationType -eq 'Direct' -and $_.TargetId -notin ($AssociationsToSame.targetId) }
        If (-not [string]::IsNullOrEmpty($IncludeType) -or -not [string]::IsNullOrEmpty($ExcludeType))
        {
            $AssociationsToAdd = $AssociationsToAdd | Where-Object { $_.targetType -in ($IncludeType | Where-Object { $_ -notin $ExcludeType }) }
        }
        # Send the results of the ones that are the same to the output
        $Results += $TargetAssociations | Where-Object { $_.TargetId -in ($AssociationsToSame.targetId) }
        If ($RemoveExisting)
        {
            # Remove exist associations from target
            $TargetAssociationsRemoved = If ($Force)
            {
                $AssociationsToRemove | Remove-JCAssociation -Force
            }
            Else
            {
                $AssociationsToRemove | Remove-JCAssociation
            }
            # Send the results of the removal to the output
            $Results += $TargetAssociationsRemoved
        }
        Else
        {
            # Send the existing association results to the output
            $Results += $TargetAssociations | Where-Object { $_.TargetId -in ($AssociationsToRemove.targetId) }
        }
        # Add the associations to the target
        $TargetAssociationsAdded = If ($Force)
        {
            $AssociationsToAdd | Add-JCAssociation -Id:($Target.($Target.ById)) -Force
        }
        Else
        {
            $AssociationsToAdd | Add-JCAssociation -Id:($Target.($Target.ById))
        }
        # Send the results of the addition to the output
        $Results += $TargetAssociationsAdded
        If (!($Results))
        {
            $Results += $CompareResults
        }
    }
    End
    {
        Return $Results
    }
}