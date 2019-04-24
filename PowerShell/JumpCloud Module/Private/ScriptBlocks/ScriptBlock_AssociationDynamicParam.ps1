$ScriptBlock_AssociationDynamicParam = {
    Param(
        [string]$Action
        , [string]$Type
    )
    # Build parameter array
    $Params = @()
    # Get type list
    $JCTypes = Get-JCType | Where-Object { $_.Category -eq 'JumpCloud' };
    If ($Action -and $Type)
    {
        # Determine if help files are being built
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $JCObjectCount = 999999
        }
        Else
        {
            # Get targets list
            $JCTypes = $JCTypes | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
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
                $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); 'DefaultValue' = $JCObject.($JCObject.ById) }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); 'DefaultValue' = $JCObject.($JCObject.ByName) }
            }
            Else
            {
                # Do populate validate set with list of items
                $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); 'ParameterSets' = @('ById'); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); 'ParameterSets' = @('ByName'); }
            }
        }
        Else
        {
            # Don't populate validate set
            $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
        }
        $Params += @{'Name' = 'TargetType'; 'Type' = [System.String[]]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ('TargetSingular'); 'ValidateSet' = $JCTypes.Targets.TargetSingular; }
    }
    Else
    {
        $Params += @{'Name' = 'Id'; 'Type' = [System.String[]]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ById).Where( { $_ -ne 'Id' }) | Select-Object -Unique; 'ParameterSets' = @('ById'); }
        $Params += @{'Name' = 'Name'; 'Type' = [System.String[]]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = ($JCTypes.ByName).Where( { $_ -ne 'Name' }) | Select-Object -Unique; 'ParameterSets' = @('ByName'); }
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
    $NewParams = $Params | ForEach-Object { New-Object PSObject -Property:($_) } | New-DynamicParameter
    # Return parameters
    Return $NewParams
}