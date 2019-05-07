Function Copy-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][string]$Type,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'ById')][ValidateNotNullOrEmpty()][string]$Id,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 3, ParameterSetName = 'ByName')][ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 4, ParameterSetName = 'ById')][ValidateNotNullOrEmpty()][string]$TargetId,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 5, ParameterSetName = 'ByName')][ValidateNotNullOrEmpty()][string]$TargetName,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][switch]$KeepExisting,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 6)][ValidateNotNullOrEmpty()][switch]$Force
    )
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
        $Results = @()
    }
    Process
    {
        $SearchBy = $PSCmdlet.ParameterSetName
        # Get the associations from the source and target
        Switch ($SearchBy)
        {
            'ById'
            {
                $SourceAssociations = Get-JCAssociation -Type:($Type) -Id:($Id)
                $TargetAssociations = Get-JCAssociation -Type:($Type) -Id:($TargetId)
                $Target = Get-JCObject -Type:($Type) -Id:($TargetName)
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
        $AssociationsToSame = $CompareResults | Where-Object {$_.SideIndicator -eq '=='}
        $AssociationsToAdd = $CompareResults | Where-Object {$_.SideIndicator -eq '<=' -and $_.associationType -eq 'Direct' -and $_.TargetId -notin ($AssociationsToSame.targetId) }
        $AssociationsToRemove = $CompareResults | Where-Object { $_.SideIndicator -eq '=>' -and $_.associationType -eq 'Direct' -and $_.TargetId -notin ($AssociationsToSame.targetId) }
        # Send the results of the ones that are the same to the output
        $Results += $TargetAssociations | Where-Object {$_.TargetId -in ($AssociationsToSame.targetId)}
        If ($KeepExisting)
        {
            # Send the existing association results to the output
            $Results += $TargetAssociations | Where-Object {$_.TargetId -in ($AssociationsToRemove.targetId)}
        }
        Else
        {
            # Remove exist associations from target
            $TargetAssociationsRemoved = If ($Force)
            {
                $AssociationsToRemove | Get-JCAssociation | Remove-JCAssociation -Force
            }
            Else
            {
                $AssociationsToRemove | Get-JCAssociation | Remove-JCAssociation
            }
            # Send the results of the removal to the output
            $Results += $TargetAssociationsRemoved
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