Function Add-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('active_directory', 'command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][string]$Type
    )
    DynamicParam
    {
        $Action = 'add'
        # Build parameter array
        $Params = @()
        # Get type list
        $JCTypes = Get-JCType | Where-Object {$_.Category -eq 'JumpCloud'};
        If ($Type)
        {
            # Determine if help files are being built
            If ((Get-PSCallStack).Command -like '*MarkdownHelp')
            {
                $JCObjectCount = 999999
            }
            Else
            {
                # Get targets list
                $JCTypes = $JCTypes | Where-Object {$_.TypeName.TypeNameSingular -eq $Type};
                # Get count of JCObject to determine if script should load dynamic parameters
                $JCObjectCount = (Get-JCObject -Type:($Type) -ReturnCount).totalCount
            }
            # Define the new parameters
            If ($JCObjectCount -ge 1 -and $JCObjectCount -le 300)
            {
                $JCObject = Get-JCObject -Type:($Type);
                If ($JCObjectCount -eq 1)
                {
                    # Don't require Id and Name to be passed through and set a default value
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( {$_ -ne 'Id'}) | Select-Object -Unique; 'ParameterSets' = @('ById'); 'DefaultValue' = $JCObject.($JCObject.ById)}
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( {$_ -ne 'Name'}) | Select-Object -Unique; 'ParameterSets' = @('ByName'); 'DefaultValue' = $JCObject.($JCObject.ByName)}
                }
                Else
                {
                    # Do populate validate set with list of items
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( {$_ -ne 'Id'}) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); 'ParameterSets' = @('ById'); }
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( {$_ -ne 'Name'}) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); 'ParameterSets' = @('ByName'); }
                }
            }
            Else
            {
                # Don't populate validate set
                $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( {$_ -ne 'Id'}) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( {$_ -ne 'Name'}) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
            }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
        }
        Else
        {
            $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( {$_ -ne 'Id'}) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( {$_ -ne 'Name'}) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
        }
        If ($Action -eq 'get')
        {
            $Params += @{'Name' = 'Direct'; 'Type' = [Switch]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
            $Params += @{'Name' = 'Indirect'; 'Type' = [Switch]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
        }
        If ($Action -in ('add', 'remove'))
        {
            $Params += @{'Name' = 'TargetId'; 'Type' = [System.String]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'TargetName'; 'Type' = [System.String]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }
            $Params += @{'Name' = 'Force'; 'Type' = [Switch]; 'Position' = 8; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
        }
        If ($Action -eq 'add')
        {
            $Params += @{'Name' = 'Attributes'; 'Type' = [System.Management.Automation.PSObject]; 'Position' = 7; 'ValueFromPipelineByPropertyName' = $true; 'Alias' = 'compiledAttributes'; }
        }
        # Create new parameters
        $NewParams = $Params | ForEach-Object {New-Object PSObject -Property:($_)} | New-DynamicParameter
        # Return new parameters
        Return $NewParams
    }
    Begin
    {
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        $Results = @()
    }
    Process
    {
        # For parameters with a default value set that value
        $NewParams.Values | Where-Object {$_.IsSet -and $_.Attributes.ParameterSetName -eq $PSCmdlet.ParameterSetName} | ForEach-Object {$PSBoundParameters[$_.Name] = $_.Value}
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{}
        # Add input parameters from function in to hash table and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
        # Add parameters from the script to the FunctionParameters hashtable
        $FunctionParameters.Add('Action', $Action) | Out-Null
        # Run the command
        $Results += Invoke-JCAssociation @FunctionParameters
    }
    End
    {
        Return $Results
    }
}