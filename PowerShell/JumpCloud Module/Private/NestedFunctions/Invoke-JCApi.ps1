Function Invoke-JCApi {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$Method,
        [Parameter(Mandatory = $false, Position = 2)][ValidateNotNullOrEmpty()][ValidateRange(1, [int]::MaxValue)][int]$Limit = 100,
        [Parameter(Mandatory = $false, Position = 3)][ValidateNotNullOrEmpty()][ValidateRange(0, [int]::MaxValue)][int]$Skip = 0,
        [Parameter(Mandatory = $false, Position = 4)][ValidateNotNull()][array]$Fields = @(),
        [Parameter(Mandatory = $false, Position = 5)][ValidateNotNull()][string]$Body = '',
        [Parameter(Mandatory = $false, Position = 6)][ValidateNotNullOrEmpty()][bool]$Paginate = $false,
        [Parameter(Mandatory = $false, Position = 7)][ValidateNotNullOrEmpty()][switch]$ReturnCount
    )
    Begin {
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        # Populate $env:JCApiKey if its not set
        If ([System.String]::IsNullOrEmpty($env:JCApiKey)) {
            Connect-JCOnline -force | Out-Null
        }
        # Populate $env:JCOrgId if its not set
        If (-not [System.String]::IsNullOrEmpty($env:JCApiKey) -and [System.String]::IsNullOrEmpty($env:JCOrgId) -and $Url -notlike '*/api/organizations*') {
            Set-JCOrganization -JumpCloudAPIKey:($env:JCApiKey) | Out-Null
        }
        #Set JC headers
        $Headers = @{
            'Content-Type' = 'application/json';
            'Accept'       = 'application/json';
            'x-api-key'    = "$($env:JCApiKey)";
            'x-org-id'     = "$($env:JCOrgId)";
        }
        # TODO: CUT-4439 need a dynamic list of endpoints that do not accept x-org-id
        # Organizations endpoint does not accept x-org-id in header
        If (
            ($Url -like '*/api/organizations*') -or
            ($URL -like "*/api/v2/providers/*") -or
            ($URL -like "*/api/v2/organizations/*")) {
            $Headers.Remove('x-org-id') | Out-Null
        }
    }
    Process {
        Try {
            $Results = @()
            If ([System.String]::IsNullOrEmpty($JCUrlBasePath)) {
                $JCUrlBasePath = 'https://console.jumpcloud.com'
            }
            If ($Url -notlike ('*' + $JCUrlBasePath + '*')) {
                $Url = $JCUrlBasePath + $Url
            }
            If ($Url -like '*`?*') {
                $SearchOperator = '&'
            } Else {
                $SearchOperator = '?'
            }
            # Convert passed in body to json
            If ($Body) {
                $ObjectBody = $Body | ConvertFrom-Json
            } Else {
                $ObjectBody = ''
            }
            # Pagination
            Do {
                $QueryStrings = @()
                # Add fields
                If ($Fields) {
                    $JoinedFields = ($Fields -join ' ')
                    If ($ObjectBody.PSObject.Properties.name -eq 'fields') {
                        $JoinedFields = $ObjectBody.fields
                    } Else {
                        $ObjectBody = $ObjectBody | Select-Object *, @{Name = 'fields'; Expression = { $JoinedFields } }
                    }
                    If ($Url -notlike '*fields*') { $QueryStrings += 'fields=' + $JoinedFields }
                }
                # Add limit
                If ($ObjectBody.PSObject.Properties.name -eq 'limit') {
                    $ObjectBody.limit = $Limit
                } Else {
                    $ObjectBody = $ObjectBody | Select-Object *, @{Name = 'limit'; Expression = { $Limit } }
                }
                If ($Url -notlike '*limit*') { $QueryStrings += 'limit=' + $Limit }
                # Add skip
                If ($ObjectBody.PSObject.Properties.name -eq 'skip') {
                    $ObjectBody.skip = $Skip
                } Else {
                    $ObjectBody = $ObjectBody | Select-Object *, @{Name = 'skip'; Expression = { $Skip } }
                }
                If ($Url -notlike '*skip*') { $QueryStrings += 'skip=' + $Skip }
                # Build url query string and body
                $ObjectBody = $ObjectBody | Select-Object -Property * -ExcludeProperty Length
                $Body = $ObjectBody | ConvertTo-Json -Depth:(10) -Compress | Sort-Object
                If ($QueryStrings) {
                    $Uri = $Url + $SearchOperator + (($QueryStrings | Sort-Object) -join '&')
                } Else {
                    $Uri = $Url
                }
                # Run request
                $UserAgent = Get-JCUserAgent
                Write-Verbose ('Connecting to: ' + $Uri)
                # PowerShell 5 won't let you send a GET with a body.
                If ($Method -eq 'GET') {
                    Write-Debug("[CallFunction]: Invoke-WebRequest -Method:('$Method') -Headers:(@" + ($Headers | ConvertTo-Json -Compress).Replace(':', '=').Replace(',', ';') + ") -Uri:('$Uri') -UseBasicParsing -UserAgent:('$UserAgent')")
                    $RequestResult = Invoke-WebRequest -Method:($Method) -Headers:($Headers) -Uri:($Uri) -UserAgent:($UserAgent) -UseBasicParsing
                } Else {
                    Write-Debug("[CallFunction]: Invoke-WebRequest -Method:('$Method') -Headers:(@" + ($Headers | ConvertTo-Json -Compress).Replace(':', '=').Replace(',', ';') + ") -Uri:('$Uri') -UseBasicParsing -UserAgent:('$UserAgent') -Body:('$Body')")
                    $RequestResult = Invoke-WebRequest -Method:($Method) -Headers:($Headers) -Uri:($Uri) -UserAgent:($UserAgent) -Body:($Body) -UseBasicParsing
                }
                If ($RequestResult) {
                    $Result = $RequestResult.Content | ConvertFrom-Json
                    $httpMetaData = $RequestResult | Select-Object -Property:('*') -ExcludeProperty:('Content')
                    If ($Result) {
                        $ResultPopulated = $false
                        # Specific logic for v1 and v2 api specs
                        If ($Url -like '*/api/*' -and ($Url -notlike '*/api/v2/*' -and $Result.PSObject.Properties.name -eq 'results')) {
                            $ResultCount = ($Result.results | Measure-Object).Count
                            If ($ResultCount -gt 0) {
                                $ResultPopulated = $true
                                If ($ReturnCount) {
                                    $ResultObjects = $Result
                                    $Paginate = $false
                                } Else {
                                    $ResultObjects = $Result.results
                                }
                            }
                        } ElseIf ($Url -like '*/api/*' -and ($Url -like '*/api/v2/*' -or $Result.PSObject.Properties.name -ne 'results')) {
                            $ResultCount = ($Result | Measure-Object).Count
                            If ($ResultCount -gt 0) {
                                $ResultPopulated = $true
                                If ($ReturnCount) {
                                    $ResultObjects = [PSCustomObject]@{'totalCount' = [int](($httpMetaData.Headers.'X-Total-Count') -join ','); 'results' = $Result; }
                                    $Paginate = $false
                                } Else {
                                    $ResultObjects = $Result
                                }
                            }
                        } Else {
                            Write-Error ('Url is not a valid JumpCloud V1 or V2 endpoint')
                        }
                        If ($ResultPopulated -eq $true) {
                            $Skip += $ResultCount
                            $Results += $ResultObjects
                        }
                    } Else {
                        If ($Paginate) {
                            $ResultCount = ($Result | Measure-Object).Count
                        }
                    }
                }
                Write-Debug ('Paginate:' + [string]$Paginate + ';ResultsCount:' + [string]$ResultCount + ';Limit:' + [string]$Limit + ';')
            }
            While ($Paginate -and $ResultCount -eq $Limit)
            Write-Verbose ('Returned ' + [string]($Results | Measure-Object).Count + ' total results.')
        } Catch {
            Invoke-Command -ScriptBlock:($ScriptBlock_TryCatchError) -ArgumentList:($_, $true) -NoNewScope
        }
    }
    End {
        # List values to add to results
        $HiddenProperties = @('httpMetaData')
        # Validate that all fields passed into the function exist in the output
        If ($Results) {
            # Append meta info to each result record
            Get-Variable -Name:($HiddenProperties) |
            ForEach-Object {
                $Variable = $_
                $Results |
                ForEach-Object {
                    Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:($Variable.Name) -Value:($Variable.Value)
                }
            }
            # Validate results properties returned
            $Fields | ForEach-Object {
                If ($_ -notin ($Results | ForEach-Object { $_.PSObject.Properties.Name } | Select-Object -Unique)) {
                    Write-Warning ('API output does not contain the field "' + $_ + '". Please refer to https://docs.jumpcloud.com for API endpoint field names.')
                }
            }
        } Else {
            $Results += [PSCustomObject]@{
                'NoContent'    = $null;
                'httpMetaData' = $httpMetaData;
            }
        }
        # Set the meta info to be hidden by default
        Return Hide-ObjectProperty -Object:($Results) -HiddenProperties:($HiddenProperties)
    }
}
