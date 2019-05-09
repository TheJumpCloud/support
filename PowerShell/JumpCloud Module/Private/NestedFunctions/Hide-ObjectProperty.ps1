Function Hide-ObjectProperty
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][Object]$Object,
        [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()][Array]$HiddenProperties
    )
    # Set some properties to be hidden in the results
    $Object | ForEach-Object {
        $Record = $_
        # Get current object's properties
        $ObjectAllProperties = $_.PSObject.Properties.Name
        Write-Debug ('ObjectAllProperties:' + ($ObjectAllProperties -join ', '))
        # If current object has PSStandardMembers then get it's default set and add its hidden properties to PropertiesToHide
        If ($_.PSStandardMembers)
        {
            $ObjectShowProperties = $_.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames
            $PropertiesToHide = @($ObjectAllProperties | Where-Object {$_ -notin $ObjectShowProperties -or $_ -in $HiddenProperties})
            Write-Debug ('ObjectShowProperties:' + ($ObjectShowProperties -join ', '))
        }
        Else
        {
            $PropertiesToHide = @($HiddenProperties)
        }
        # Get list of properties to show
        $PropertiesToShow = $ObjectAllProperties | Where-Object {$_ -notin $PropertiesToHide}
        Write-Debug ('PropertiesToHide:' + ($PropertiesToHide -join ', '))
        Write-Debug ('PropertiesToShow:' + ($PropertiesToShow -join ', '))
        # Create the default property display set
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [System.String[]]$PropertiesToShow)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
        # Add the list of standard members
        Add-Member -InputObject:($_) -MemberType:('MemberSet') -Name:('PSStandardMembers') -Value:($PSStandardMembers) -Force
        ForEach ($HiddenProperty In $PropertiesToHide)
        {
            Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($HiddenProperty) -Value:($Record.$HiddenProperty) -Force
        }
    }
    Return $Object
}