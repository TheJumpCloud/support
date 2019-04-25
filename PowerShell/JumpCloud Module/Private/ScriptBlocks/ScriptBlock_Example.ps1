<#
.EXAMPLE
& $ScriptBlock_Name -Param1:('SomeValue') -Param1:(1234)
.EXAMPLE
Invoke-Command -ScriptBlock:($ScriptBlock_Name) -ArgumentList:('SomeValue',1234) -NoNewScope

# Building the ScriptBlock. Make sure that all ScriptBlocks are prefixed with "ScriptBlock_".
    $ScriptBlock_Name = {
        Param(
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Param1
            , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][int]$Param2
        )
        # Do stuff
        Write-Host ($Param1)
        Write-Host ($Param2)
    }
#>