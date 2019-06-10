Function Add-JCAssociation
{
    <#
.SYNOPSIS

Create an association between two object within the JumpCloud console.

.DESCRIPTION

The Add-JCAssociation function allows you to create associations of a specific object to a target object.

.EXAMPLE
PS C:\> Add-JCAssociation -Type:('radiusservers') -Id:('5c5c371704c4b477964ab4fa') -TargetType:('user_group') -TargetId:('59f20255c9118021fa01b80f')

Create an association between the radius server "5c5c371704c4b477964ab4fa" and the user group "59f20255c9118021fa01b80f".

.EXAMPLE
PS C:\> Add-JCAssociation -Type:('radiusservers') -Name:('RadiusServer1') -TargetType:('user_group') -TargetName:('All Users')

Create an association between the radius server "RadiusServer1" and the user group "All Users".

#>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][string]$Type
        , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2, HelpMessage = 'Bypass user confirmation and ValidateSet when adding or removing associations.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    DynamicParam
    {
        # Add Action
        ($PsBoundParameters).Add('Action', 'add') | Out-Null
        # Build dynamic parameters
        $RuntimeParameterDictionary = Get-DynamicParamAssociation @PsBoundParameters
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Debug message for parameter call
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDebugMessageBegin) -ArgumentList:($MyInvocation, $PsBoundParameters, $PSCmdlet) -NoNewScope
        $Results = @()
    }
    Process
    {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{}
        # Add input parameters from function in to hash table and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | Where-Object {$_.Value} | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
        # Run the command
        $Results += Invoke-JCAssociation @FunctionParameters
    }
    End
    {
        Return $Results
    }
}