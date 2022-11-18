Function Get-JCObject {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The type of the object.')][ValidateNotNullOrEmpty()][ValidateSet('command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365', 'organization')][Alias('TypeNameSingular')][System.String]$Type
    )
    DynamicParam {
        $Action = 'get'
        $JCType = Get-JCType | Where-Object { $_.TypeName.TypeNameSingular -eq $Type };
        $RuntimeParameterDictionary = If ($Type) {
            Get-JCCommonParameters -Force:($true) -Action:($Action) -Type:($Type);
        } Else {
            Get-JCCommonParameters -Force:($true) -Action:($Action);
        }
        New-DynamicParameter -Name:('ReturnHashTable') -Type:([switch]) -ValueFromPipelineByPropertyName -RuntimeParameterDictionary:($RuntimeParameterDictionary) -DefaultValue:($false) | Out-Null
        New-DynamicParameter -Name:('ReturnCount') -Type:([switch]) -ValueFromPipelineByPropertyName -DefaultValue:($false) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin {
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
    }
    Process {
        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        Try {
            If ($JCType) {
                $UrlObject = @()
                # If searching ByValue add filters to query string and body.
                If ($PSCmdlet.ParameterSetName -eq 'ById') {
                    $SearchBy = 'ById'
                    $SearchByValue = $Id
                    $PropertyIdentifier = $JCType.ById
                } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByName') {
                    $SearchBy = 'ByName'
                    $SearchByValue = $Name
                    $PropertyIdentifier = $JCType.ByName
                } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByValue') {
                    $SearchBy = $SearchBy
                    $SearchByValue = $SearchByValue
                    $PropertyIdentifier = Switch ($SearchBy) {
                        'ById' {
                            $JCType.ById
                        };
                        'ByName' {
                            $JCType.ByName
                        };
                    }
                } ElseIf ($PSCmdlet.ParameterSetName -eq 'Default') {
                    # Populate url variables
                    $UrlOut = If ($SearchBy -eq 'ById') {
                        If ($JCType.Url.variables) {
                            ($JCType.Url.Item).Replace($JCType.Url.variables, $SearchByValue)
                        } Else {
                            $JCType.Url.Item
                        }
                    } Else {
                        $JCType.Url.List
                    }
                    # Build final body and url
                    $UrlObject += [PSCustomObject]@{
                        'Type'              = $Type;
                        'SearchBy'          = $null;
                        'SearchByValueItem' = $null;
                        'UrlPath'           = $UrlOut;
                        'QueryString'       = $QueryString;
                        'Body'              = $null;
                        'UrlFull'           = $JCUrlBasePath + $UrlOut + $QueryString;
                    }
                } Else {
                    Write-Error ('Unknown $PSCmdlet.ParameterSetName: ' + $PSCmdlet.ParameterSetName)
                }
                # Loop through each item passed in and build UrlObject
                ForEach ($SearchByValueItem In $SearchByValue) {


                    If (!($PSCmdlet.ParameterSetName -eq 'Default')) {
                        $QueryStrings = @()
                        $BodyParts = @()
                        # Populate url variables
                        $UrlOut = Switch ($SearchBy) {
                            'ById' {
                                If ($JCType.Url.variables) {
                                    ($JCType.Url.Item).Replace($JCType.Url.variables, $SearchByValueItem)
                                } Else {
                                    $JCType.Url.Item
                                }
                            }
                            'ByName' {
                                $JCType.Url.List
                            }
                        }
                        If ($SearchBy -eq 'ByName') {
                            # Add filters for exact match and wildcards
                            If ($SearchByValueItem -match '\*') {
                                If ($JCType.SupportRegexFilter) {
                                    $BodyParts += ('"filter":[{"' + $PropertyIdentifier + '":{"$regex": "(?i)(' + $SearchByValueItem.Replace('*', ')(.*?)(') + ')"}}]').Replace('()', '')
                                } Else {
                                    Write-Error ('The endpoint ' + $UrlOut + ' does not support wildcards in the $SearchByValueItem. Please remove "*" from "' + $SearchByValueItem + '".')
                                }
                            } Else {
                                if (($type -eq 'radius_server') -and ($PropertyIdentifier -eq 'name')) {
                                    $QueryStrings += 'search[fields][0]=name&search[searchTerm]=' + $SearchByValueItem
                                } else {
                                    $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValueItem + '&fields=' + $JCType.ById
                                    $BodyParts += '"filter":[{"' + $PropertyIdentifier + '":"' + $SearchByValueItem + '"}]'
                                }

                            }
                        }
                    }
                    # Build url info
                    $QueryString = If ($QueryStrings) {
                        '?' + ($QueryStrings -join '&')
                    } Else {
                        $null
                    };
                    $Body = If ($BodyParts) {
                        '{' + ($BodyParts -join ',') + '}'
                    } Else {
                        $null
                    };
                    $UrlObject += [PSCustomObject]@{
                        'Type'              = $Type;
                        'SearchBy'          = $SearchBy;
                        'SearchByValueItem' = $SearchByValueItem;
                        'UrlPath'           = $UrlOut;
                        'QueryString'       = $QueryString;
                        'Body'              = $Body;
                        'UrlFull'           = $JCUrlBasePath + $UrlOut + $QueryString;
                    }
                }
                #########################################################
                # $UrlObject
                #########################################################
                # Make each API call
                ForEach ($UrlItem In $UrlObject) {
                    $UrlFull = $UrlItem.UrlFull
                    $Body = $UrlItem.Body
                    Write-Verbose "Url item = $($UrlItem.SearchByValueItem)"
                    $SearchByValueItem = $UrlItem.SearchByValueItem
                    $SearchBy = $UrlItem.SearchBy
                    If ($SearchBy -eq 'ByName') {
                        $FieldsReturned = $JCType.ById
                    } Else {
                        $FieldsReturned = $PsBoundParameters.Fields
                    }
                    ## Escape Url????
                    # $UrlFull= ([uri]::EscapeDataString($UrlFull)
                    # Build function parameters
                    $FunctionParameters = [ordered]@{ }
                    If (-not ([System.String]::IsNullOrEmpty($UrlFull))) {
                        $FunctionParameters.Add('Url', $UrlFull)
                    }
                    If (-not ([System.String]::IsNullOrEmpty($JCType.Method))) {
                        $FunctionParameters.Add('Method', $JCType.Method)
                    }
                    If (-not ([System.String]::IsNullOrEmpty($Body))) {
                        $FunctionParameters.Add('Body', $Body)
                    }
                    If (-not ([System.String]::IsNullOrEmpty($PsBoundParameters.Limit))) {
                        $FunctionParameters.Add('Limit', $PsBoundParameters.Limit)
                    }
                    If (-not ([System.String]::IsNullOrEmpty($PsBoundParameters.Skip))) {
                        $FunctionParameters.Add('Skip', $PsBoundParameters.Skip)
                    }
                    If ($ReturnHashTable) {
                        $Values = $FieldsReturned
                        $Key = If ($PropertyIdentifier) {
                            $PropertyIdentifier
                        } Else {
                            $JCType.ById
                        }
                        If (-not ([System.String]::IsNullOrEmpty($Key))) {
                            $FunctionParameters.Add('Key', $Key)
                        }
                        If (-not ([System.String]::IsNullOrEmpty($Values))) {
                            $FunctionParameters.Add('Values', $Values)
                        }
                    } Else {
                        If (-not ([System.String]::IsNullOrEmpty($FieldsReturned))) {
                            $FunctionParameters.Add('Fields', $FieldsReturned)
                        }
                        If (-not ([System.String]::IsNullOrEmpty($PsBoundParameters.Paginate))) {
                            $FunctionParameters.Add('Paginate', $PsBoundParameters.Paginate)
                        }
                        If ($ReturnCount -eq $true) {
                            $FunctionParameters.Add('ReturnCount', $ReturnCount)
                        }
                    }
                    # Run command
                    $Result = If ($ReturnHashTable -eq $true) {
                        Get-JCHash @FunctionParameters
                    } Else {
                        Invoke-JCApi @FunctionParameters
                    }
                    If ($JCType.TypeName.TypeNameSingular -in ('g_suite', 'office_365')) {
                        # Hacky logic to get g_suite and office_365 directories

                        If ($ReturnCount -eq $true) {
                            $Directory = $Result.results | Where-Object { $_.Type -eq $JCType.TypeName.TypeNameSingular }
                            $Result.totalCount = ($Directory | Measure-Object).Count
                            $Result.results = $Directory
                        } Else {
                            $Result = $Result | Where-Object { $_.Type -eq $JCType.TypeName.TypeNameSingular }
                        }
                        # manual filter since the API doesn't support it
                        foreach ($dirResult in $Result) {
                            if ($dirResult.Name -eq $SearchByValueItem) {
                                # if match on name, just API results to just be the single match
                                $Result = $dirResult
                            } else {
                                $result = $result | Where-Object { $_ –ne $dirResult }
                            }
                        }

                    }
                    # Validate results
                    If ($Result -and $Result.PSObject.Properties.name -notcontains 'NoContent') {
                        If ($SearchBy -and ($Result | Measure-Object).Count -gt 1) {
                            Write-Warning -Message:('Found "' + [string]($Result | Measure-Object).Count + '" "' + $JCType.TypeName.TypeNamePlural + '" with the "' + $SearchBy.Replace('By', '').ToLower() + '" of "' + $SearchByValueItem + '"')
                        }
                        $Results += $Result
                    } ElseIf ($SearchByValueItem) {
                        Write-Warning ('A "' + $JCType.TypeName.TypeNameSingular + '" called "' + $SearchByValueItem + '" does not exist. Note the search is case sensitive.')
                    } Else {
                        Write-Warning ('The search value is blank or no "' + $JCType.TypeName.TypeNamePlural + '" have been setup in your org. SearchValue:"' + $SearchByValueItem + '"')
                    }
                }

                # Re-lookup object by id
                If ($Results -and $SearchBy -eq 'ByName' -and $JCType.TypeName.TypeNameSingular -notin ('g_suite', 'office_365')) {
                    # Hacky logic to get g_suite and office_365 directories
                    $PsBoundParameters.Remove('Name') | Out-Null
                    $PsBoundParameters.Remove('SearchBy') | Out-Null
                    $PsBoundParameters.Remove('SearchByValue') | Out-Null
                    $PsBoundParameters.Add('Id', $Results.($JCType.ById)) | Out-Null
                    $Results = Get-JCObject @PsBoundParameters
                } Else {
                    If ($Results) {
                        Write-Verbose "Results = $($Results)"
                        $ById = $JCType.ById
                        $ByName = $JCType.ByName
                        $TypeName = $JCType.TypeName
                        $TypeNameSingular = $TypeName.TypeNameSingular
                        $TypeNamePlural = $TypeName.TypeNamePlural
                        $Targets = $JCType.Targets
                        $TargetSingular = $Targets.TargetSingular
                        $TargetPlural = $Targets.TargetPlural
                        $Table = $JCType.Table
                        # List values to add to results
                        $HiddenProperties = @('ById', 'ByName', 'TypeName', 'TypeNameSingular', 'TypeNamePlural', 'Targets', 'TargetSingular', 'TargetPlural')
                        If (-not [System.String]::IsNullOrEmpty($PsBoundParameters.Table)) {
                            $Table = $JCType.Table
                            $HiddenProperties += 'Table'
                        }
                        # Append meta info to each result record
                        Get-Variable -Name:($HiddenProperties) |
                        ForEach-Object {
                            $Variable = $_
                            $Results |
                            ForEach-Object {
                                Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($Variable.Name) -Value:($Variable.Value);
                            }
                        }
                        # Set the meta info to be hidden by default
                        $Results = Hide-ObjectProperty -Object:($Results) -HiddenProperties:($HiddenProperties)
                    }
                }
            } Else {
                Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + ($JCType.TypeName.TypeNameSingular -join ','))
            }
        } Catch {
            Write-Error ($_)
        }
    }
    End {
        Return $Results
    }
}