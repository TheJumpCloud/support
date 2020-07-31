function Get-JCSystemInsightsWrapped{
    [CmdletBinding(DefaultParameterSetName = 'List', PositionalBinding = $false)]
    param(
        [string[]]
        ${Filter},
        [string[]]
        ${Sort},
        [bool]
        ${Paginate})
    DynamicParam{
        $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $attr = New-Object System.Management.Automation.ParameterAttribute
        $attr.HelpMessage = "System Insights Table"
        $attr.ValueFromPipelineByPropertyName = $true
        $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attrColl.Add($attr)
        # $attrColl.Add((New-Object System.Management.Automation.ValidateSetAttribute(Get-ChildItem -Path '/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Public/Systems/Get-JCSystemInsight*' | Select-Object -ExpandProperty BaseName)))
        # $attrColl.Add((New-Object System.Management.Automation.ValidateSetAttribute(Get-Command -Module JumpCloud.SDK.V2 | Where-Object Name -Match "Get-JcSdkSystemInsight*" | Select-Object -ExpandProperty Name)))
        $attrColl.Add((New-Object System.Management.Automation.ValidateSetAttribute(Get-Command -Module JumpCloud.SDK.V2 | Where-Object Name -Match "Get-JcSdkSystemInsight*" | ForEach-Object { $_ -replace "Get-JcSdkSystemInsight*", "" })))
        $param = New-Object System.Management.Automation.RuntimeDefinedParameter('Table', [string], $attrColl)
        $dict.Add('Table', $param)
        # Write-Host($dict)
        return $dict
    }
    begin {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }
            if ($PSBoundParameters["Table"]){
                $Table = $PSBoundParameters["Table"]
            }
            $InsightsCommandFull = "Get-JcSdkSystemInsight" + "$Table"
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand($InsightsCommandFull, [System.Management.Automation.CommandTypes]::Function)
            # Write-Host ($wrappedCmd)
            $pass = @()
            foreach ($param in $PSBoundParameters){
                if ($param.key -eq $wrappedCmd.Parameters.Keys){
                    $pass += $param
                }
            }
            $scriptCmd = { & $wrappedCmd @pass }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            throw
        }
    }
    process {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            throw
        }
    }
    end {
        try {
            $steppablePipeline.End()
        }
        catch {
            throw
        }
    }
    <#
    .ForwardHelpTargetName $InsightsCommandFull
    .ForwardHelpCategory Function
    #>
}
# $scriptBlock = { Get-ChildItem -Path 'C:\Program Files' | Select-Object -ExpandProperty Name2 }
# # Get-ChildItem -Path '/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Public/Systems/Get-JCSystemInsight*' | Select-Object -ExpandProperty Name
# $scriptblock = {
#     param($commandName, $parameterName, $stringMatch)
#     Get-ChildItem -Path '/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Public/Systems/Get-JCSystemInsight*' | Select-Object -ExpandProperty BaseName

# }

