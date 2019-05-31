Function Format-JCAssociation
{
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Uri
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$Method
        , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][object]$Source
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3)][ValidateNotNullOrEmpty()][string]$TargetId
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateNotNullOrEmpty()][bool]$IncludeInfo = $false
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][bool]$IncludeNames = $false
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 6)][ValidateNotNullOrEmpty()][bool]$IncludeVisualPath = $false
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 7)][ValidateNotNullOrEmpty()][bool]$Raw = $false
    )
    Write-Debug ('[UrlTemplate]:' + $Uri)
    $AssociationsOut = @()
    $Associations = Invoke-JCApi -Method:($Method) -Paginate:($true) -Url:($Uri)
    If ($TargetId)
    {
        $Associations = $Associations | Where-Object {$_.id -eq $TargetId}
    }
    If ($Associations -and $Associations.PSObject.Properties.name -notcontains 'NoContent')
    {
        $Associations | ForEach-Object {
            #Region Determine if association is 'direct', 'indirect', or "direct`/indirect" and apply label
            $_.paths | ForEach-Object {
                $PathCount = ($_.to | Measure-Object).Count
                $associationType = If ($PathCount -eq 0 -or $PathCount -eq 1)
                {
                    'direct'
                }
                ElseIf ($PathCount -gt 1)
                {
                    'indirect'
                }
                Else
                {
                    'associationType unknown;The count of paths is:' + [string]$PathCount
                }
                Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('associationType') -Value:($associationType)
            }
            $associationType = ($_.paths.associationType | Select-Object -Unique) -join '/'
            #EndRegion Determine if association is 'direct', 'indirect', or "direct`/indirect" and apply label
            #Region Build record for each association
            If ($Raw)
            {
                # Raw switch allows for the user to return an unformatted version of what the api endpoint returns
                Add-Member -InputObject:($_) -NotePropertyName:('associationType') -NotePropertyValue:($associationType);
                $_.paths | ForEach-Object {$_.PSObject.Properties.Remove('associationType')}
                $AssociationsOut += $_
            }
            Else
            {
                $AssociationHash = [ordered]@{
                    'associationType'  = $associationType;
                    'id'               = $Source.($Source.ById);
                    'type'             = $Source.TypeNameSingular;
                    'name'             = $null;
                    'info'             = $null;
                    'targetId'         = $null;
                    'targetType'       = $null;
                    'targetName'       = $null;
                    'targetInfo'       = $null;
                    'visualPathById'   = $null;
                    'visualPathByName' = $null;
                    'visualPathByType' = $null;
                };
                # Dynamically get the rest of the properties and add them to the hash
                $AssociationProperties = $_ |
                    ForEach-Object {$_.PSObject.Properties.name} |
                    Select-Object -Unique
                If ($AssociationProperties)
                {
                    ForEach ($AssociationProperty In $AssociationProperties | Where-Object {$_ -notin ('id', 'type')})
                    {
                        $AssociationHash.Add($AssociationProperty, $_.($AssociationProperty)) | Out-Null
                    }
                }
                Else
                {
                    Write-Error ('No object properties found for association record.')
                }
                # If any "Include*" switch is provided get the target object
                If ($IncludeInfo -or $IncludeNames -or $IncludeVisualPath)
                {
                    $Target = Get-JCObject -Type:($_.type) -Id:($_.id)
                }
                # If target is populated
                If ($Target)
                {
                    $AssociationHash.targetId = $Target.($Target.ById)
                    $AssociationHash.targetType = $Target.TypeNameSingular
                }
                Else
                {
                    $AssociationHash.targetId = $_.id
                    $AssociationHash.targetType = $_.type
                }
                # Show source and target info
                If ($IncludeInfo)
                {
                    $AssociationHash.info = $Source
                    $AssociationHash.targetInfo = $Target
                }
                # Show names of source and target
                If ($IncludeNames)
                {
                    $AssociationHash.name = $Source.($Source.ByName)
                    $AssociationHash.targetName = $Target.($Target.ByName)
                }
                # Map out the associations path and show
                If ($IncludeVisualPath)
                {
                    class AssociationMap
                    {
                        [string]$Id; [string]$Name; [string]$Type;
                        AssociationMap([string]$i, [string]$n, [string]$t) {$this.Id = $i; $this.Name = $n; $this.Type = $t; }
                    }
                    $_.paths | ForEach-Object {
                        $AssociationVisualPath = @()
                        [AssociationMap]$AssociationVisualPathRecord = [AssociationMap]::new($Source.($Source.ById), $Source.($Source.ByName), $Source.TypeNameSingular)
                        $AssociationVisualPath += $AssociationVisualPathRecord
                        $_.to | ForEach-Object {
                            $AssociationPathToItemInfo = Get-JCObject -Type:($_.type) -Id:($_.id)
                            $AssociationVisualPath += [AssociationMap]::new($_.id, $AssociationPathToItemInfo.($AssociationPathToItemInfo.ByName), $_.type)
                        }
                        ($AssociationVisualPath | ForEach-Object {$_.PSObject.Properties.name} |
                                Select-Object -Unique) |
                            ForEach-Object {
                            $KeyName_visualPath = 'visualPathBy' + $_
                            $AssociationHash.($KeyName_visualPath) = ('"' + ($AssociationVisualPath.($_) -join '" -> "') + '"')
                        }
                    }
                }
                # Convert the hashtable to an object where the Value has been populated
                $AssociationsUpdated = [PSCustomObject]@{}
                $AssociationHash.GetEnumerator() |
                    ForEach-Object {If ($_.Value -or $_.key -in ($AssociationProperties) -or $_.key -in ('targetId', 'targetType')) {Add-Member -InputObject:($AssociationsUpdated) -NotePropertyName:($_.Key) -NotePropertyValue:($_.Value)}}
                $AssociationsOut += $AssociationsUpdated
            }
        }
        #EndRegion Build record for each association
        Return $AssociationsOut
    }
}