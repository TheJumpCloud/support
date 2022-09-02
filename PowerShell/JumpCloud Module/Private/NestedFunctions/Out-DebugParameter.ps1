<#
.Synopsis
    Helper function to format debug parameter output.
.Example
    $PSBoundParameters | Out-DebugParameter | Write-Debug
#>
function Out-DebugParameter {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [AllowEmptyCollection()]
        $InputObject
    )
    Begin {
        $CommonParameters = ([System.Management.Automation.PSCmdlet]::CommonParameters, [System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
    }
    Process {
        $MyName = $MyInvocation.MyCommand.Name
        $CallStack = Get-PSCallStack
        $ParentScript = $CallStack[$CallStack.Command.IndexOf($MyName) + 1]
        $ParentParentScript = $CallStack[$CallStack.Command.IndexOf($MyName) + 2]
        # Write-Debug (')
        $Output = $InputObject.GetEnumerator() | Where-Object {
            $CommonParameters -notcontains $_.Key
        } | Select-Object -Property:(
            @{
                Name       = 'Parameter'
                Expression = { $_.Key }
            },
            @{
                Name       = 'Value'
                Expression = { $_.Value }
            }
        )
        $Parameters = ($Output | ForEach-Object { "-$($_.Parameter):('$($_.Value -join ''',''')')" }) -join ' '
        Return ('[ScriptParameters]: ' + ($ParentScript.Command, $Parameters, '# Called by script/function: ' + ([System.String]$ParentParentScript.Command).Trim() + ';', 'Line: ' + ([System.String]$ParentParentScript.ScriptLineNumber).Trim()) -join ' ')
        # ' Line: ' + [System.String]$ParentScript.ScriptLineNumber
    }
}