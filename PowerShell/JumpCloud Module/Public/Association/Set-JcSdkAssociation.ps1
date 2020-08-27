Function Get-SwaggerItem($FilePath, $JsonPath)
{
    # Brake up parts of path to iterate through
    If ($JsonPath -match '#')
    {
        $JsonPath = $JsonPath.Replace('#', '')
    }
    $JsonPathDotSource = $JsonPath.Split('/') | Where-Object { $_ }
    # Get contents of swagger file
    $SwaggerJson = Get-Content -Path:($FilePath) -Raw
    $Swagger = $SwaggerJson | ConvertFrom-Json -Depth 99
    $Definition = $Swagger
    # Iterate through parts of the path and return the requested model
    $JsonPathDotSource | ForEach-Object {
        $Definition = $Definition.$_
    }
    Return $Definition
}
# Load swagger file
$SwaggerFilePath = 'C:\Users\epanipinto\Documents\GitHub\jcapi-powershell\SwaggerSpecs\JumpCloud.SDK.V2.json'
$OutputObject = @()
$SwaggerJson = Get-Content -Path:($SwaggerFilePath) -Raw
$Swagger = $SwaggerJson | ConvertFrom-Json -Depth 99
# Parse swagger spec
$Paths = $Swagger.paths
$Paths.PSObject.Properties.Name | ForEach-Object {
    $PathName = $_
    $PathProperties = $Paths.$_
    $PathProperties.PSObject.Properties.Name | ForEach-Object {
        If ($_ -in ('delete', 'get', 'put', 'post', 'patch'))
        {
            $MethodName = $_
            $MethodProperties = $PathProperties.$_
            $operationId = $MethodProperties.operationId
            $AssociationEndpoints = $MethodProperties | Where-Object { $_.operationId -like '*Association*' `
                    -or $_.operationId -like '*Membership*' `
                    -or $_.operationId -like '*MemberOf*' `
                    -or $_.operationId -like '*Member*' `
                    -or $_.operationId -like '*Traverse*' }
            # $AssociationEndpoints = $MethodProperties | Where-Object { $_.operationId -like '*Set*Association*' }
            If ($AssociationEndpoints)
            {
                If ($MethodName -eq 'get')
                {
                    # Extract "op" parameter
                    $Targets = $AssociationEndpoints.parameters | Where-Object { $_.name -eq 'targets' }
                    $OutputObject += [PSCustomObject]@{
                        Path          = $PathName
                        Method        = $MethodName
                        operationId   = $operationId
                        ParameterName = $Targets.name
                        enum          = $Targets.items.enum
                    }
                }
                ElseIf ($MethodName -eq 'post')
                {
                    $EndpointParameters = Get-SwaggerItem -FilePath:($SwaggerFilePath) -JsonPath:($AssociationEndpoints.parameters.schema.'$ref')
                    # Extract "op" parameter
                    $OutputObject += [PSCustomObject]@{
                        Path          = $PathName
                        Method        = $MethodName
                        operationId   = $operationId
                        ParameterName = $EndpointParameters.properties.PSObject.Properties.Name | Where-Object { $_ -eq 'op' }
                        enum          = $EndpointParameters.properties.op.enum
                    }
                    # Extract "type" parameter
                    $OutputObject += [PSCustomObject]@{
                        Path          = $PathName
                        Method        = $MethodName
                        operationId   = $operationId
                        ParameterName = $EndpointParameters.properties.PSObject.Properties.Name | Where-Object { $_ -eq 'type' }
                        enum          = If ($EndpointParameters.properties.type.PSObject.Properties.Name | Where-Object { $_ -eq '$ref' })
                        {
                            (Get-SwaggerItem -FilePath:($SwaggerFilePath) -JsonPath:($EndpointParameters.properties.type.'$ref')).enum;
                        }
                        Else
                        {
                            $EndpointParameters.properties.type.enum;
                        };
                    }
                }
                Else
                {
                    Write-Error ("Unknown method: $MethodName")
                }
            }
        }
        ElseIf ($_ -in ('parameters'))
        {
            # Need to document?
        }
        Else
        {
            Write-Error "Unknown child path property:$($_)"
        }
    }
}

# Export CSV
$AssociationCommands = $OutputObject | Select-Object -Property:*, @{Name = 'FunctionType'; Expression = { ($_.operationId | Select-String -Pattern:('(^.*?-)(.*?)(Association|Membership|Member|Traverse)(.*?$)')).Matches.Groups[2].Value } }
$AssociationCommands | ForEach-Object { $_.enum = $_.enum -join ', ' }
$AssociationCommands | Export-Csv -Path:('temp.csv') -Force

# # Build sample commands
# $AssociationCommands | Where-Object { $_.Method -eq 'get' -and $_.ParameterName -eq 'targets' } | ForEach-Object {
#     $Command = $_
#     $_.enum | ForEach-Object {
#         "Get-JCAssociation -Type:('$($Command.FunctionType)') -Id:('') -TargetType:('$($_)');"
#     }
# } | Sort-Object
