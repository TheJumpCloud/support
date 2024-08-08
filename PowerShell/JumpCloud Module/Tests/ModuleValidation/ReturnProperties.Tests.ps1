Describe -Tag:('ModuleValidation') 'Return Properties Checks' {
    It 'Validates that functions with "Return Properties" return up-to-date fields' {
        Import-Module powershell-yaml -force
        $validFunction = @('Get-JCSystem', 'Get-JCUser', 'Get-JCCommand')
        $functionHash = @{
            'Get-JCSystem'  = @{
                'modelDefinition'     = 'definitions.system.properties'
                'customDefinitionMap' = @{

                }
                'ignoreList'          = @('_id', 'tags')
            };
            'Get-JCUser'    = @{
                'modelDefinition'     = 'definitions.systemuserput.properties'
                'customDefinitionMap' = @{

                }
                'ignoreList'          = @('_id', 'tags')
            };
            'Get-JCCommand' = @{
                'modelDefinition'     = 'definitions.command.properties'
                'customDefinitionMap' = @{

                }
            };
        }
        $swaggerV1Url = "https://docs.jumpcloud.com/api/1.0/index.yaml"
        $swaggerContent = Invoke-WebRequest -Uri $swaggerV1Url -Method 'Get'
        $swagger = $swaggerContent.content | ConvertFrom-Yaml

        foreach ($item in $functionHash.keys) {
            Write-host "$($item.keys)"
            #get the command file:
            $command = Get-Command -name $item
            $commandRetAttributes = $command.Parameters.returnProperties.attributes.validValues
            $commandList = New-Object System.Collections.ArrayList
            foreach ($collection in $commandRetAttributes) {
                $commandList.Add($collection) | Out-Null
            }
            $swaggerRetAttributes = invoke-Expression ('$swagger.' + $functionHash[$item].modelDefinition)
            $swaggerList = New-Object System.Collections.ArrayList
            foreach ($collection in $swaggerRetAttributes.keys) {
                $swaggerList.Add($collection) | Out-Null
            }

            $diffList = compare-Object -ReferenceObject $commandList -DifferenceObject $swaggerList
            # items in swagger, not module
            $inSwaggerNotFunction = $diffList | where-object { $_.SideIndicator -eq "=>" }
            $missing = $inSwaggerNotFunction | where-object { $_.InputObject -notin $functionHash[$item].ignoreList }
            # there should not be any missing items
            if ($missing.InputObject) {
                Write-Warning "The folling properties are defined in swagger for the $item function but not the module, either add them to the function validate set or add them to the ignore list in this test"
                Write-host $missing.InputObject
            }
            $missing.InputObject | should -BeNullOrEmpty
        }
    }
}
