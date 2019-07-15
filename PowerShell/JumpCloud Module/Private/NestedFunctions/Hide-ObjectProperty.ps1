<#
.DESCRIPTION
This function will digest any object and set configure wether or not its properties will show by default when you call it.
.EXAMPLE
In this example you will need to replace the "$HiddenProperties" array and object name "$SomeObject".
$ObjectOutput += [PSCustomObject]@{
    'Var1' = 'Hello;
    'Var2' = 'World';
    'Var3' = '!';
}
# List values to add to results
$HiddenProperties = @('Var2','Var3')
# Append meta info to results
Get-Variable -Name:($HiddenProperties) |
    ForEach-Object {
    $Variable = $_
    $SomeObject |
        ForEach-Object {
        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($Variable.Name) -Value:($Variable.Value)
    }
}
# Set the meta info to be hidden by default
$Results += Hide-ObjectProperty -Object:($Result) -HiddenProperties:($HiddenProperties)
#>
Function Hide-ObjectProperty
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][Object]$Object,
        [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()][Array]$HiddenProperties
    )
    # Set some properties to be hidden in the results
    $Object | ForEach-Object {
        # Get current object's properties
        $ObjectAllProperties = $_.PSObject.Properties.Name
        # Write-Host ('ObjectAllProperties:' + ($ObjectAllProperties -join ', ')) -BackgroundColor Gray -ForegroundColor Black
        # If current object has PSStandardMembers then get it's default set and add its hidden properties to PropertiesToHide
        If ($_.PSStandardMembers)
        {
            $ObjectShowProperties = $_.PSStandardMembers.DefaultDisplayPropertySet.ReferencedPropertyNames
            $PropertiesToHide = @($HiddenProperties + ($ObjectAllProperties | Where-Object {$_ -notin $ObjectShowProperties -or $_ -in $HiddenProperties}) | Select-Object -Unique)
            # Write-Host ('ObjectShowProperties:' + ($ObjectShowProperties -join ', ')) -BackgroundColor Yellow -ForegroundColor Black
        }
        Else
        {
            $PropertiesToHide = @($HiddenProperties)
        }
        # Get list of properties to show
        $PropertiesToShow = $ObjectAllProperties | Where-Object {$_ -notin $PropertiesToHide}
        # Write-Host ('PropertiesToHide:' + ($PropertiesToHide -join ', ')) -BackgroundColor Yellow -ForegroundColor Black
        # Write-Host ('PropertiesToShow:' + ($PropertiesToShow -join ', ')) -BackgroundColor Green -ForegroundColor Black
        # Create the default property display set
        If ($PropertiesToShow)
        {
            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [System.String[]]$PropertiesToShow)
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
            # Add the list of standard members
            Add-Member -InputObject:($_) -MemberType:('MemberSet') -Name:('PSStandardMembers') -Value:($PSStandardMembers) -Force
        }
        Else
        {
            Throw ('By hiding "' + ($PropertiesToHide -join '", "') + '" there are no properties to show. At least one property must be visitable.')
        }
    }
    If ($Object)
    {
        Return $Object
    }
}