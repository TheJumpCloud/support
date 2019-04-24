<#
Building the ScriptBlock. Make sure that all ScriptBlocks are prefixed with "ScriptBlock_".
    $ScriptBlock_Name = {
        Param(
            [string]$Param1
            , [int]$Param2
        )
        # Do stuff
        Write-Host ($Param1)
        Write-Host ($Param2)
    }

Calling the ScriptBlock.
    & $ScriptBlock_Name -Param1:('SomeValue') -Param1:(1234)
    Invoke-Command -ScriptBlock:($ScriptBlock_Name) -ArgumentList:('SomeValue',1234)
#>