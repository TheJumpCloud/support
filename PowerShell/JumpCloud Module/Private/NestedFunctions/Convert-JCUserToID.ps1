function Convert-JCUserToID {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, HelpMessage = 'The username, id or email of a user')][ValidateNotNullOrEmpty()]
        [System.String]$UserIdentifier
    )
    process {
        # First check if UserIdentifier returns valid user with id
        # Regex match a userid
        $regexPattern = [Regex]'^[a-z0-9]{24}$'
        if (((Select-String -InputObject $UserIdentifier -Pattern $regexPattern).Matches.value)::IsNullOrEmpty) {
            # if we have a 24 characterid, try to match the id using the search endpoint
            $UserIdentifierSearch = @{
                filter = @{
                    'and' = @(
                        @{'_id' = @{'$eq' = "$($UserIdentifier)" } }
                    )
                }
                fields = 'id'
            }
            $UserIdentifierResults = Search-JcSdkUser -Body:($UserIdentifierSearch)
            # Set UserIdentifierValue; this is a validated user id
            $UserIdentifierValue = $UserIdentifierResults.id
        } else {
            # Use class mailaddress to check if $_.value is email
            try {
                $null = [mailaddress]$UserIdentifier
                Write-Debug "This is true"
                # Search for UserIdentifier using email
                $UserIdentifierSearch = @{
                    filter = @{
                        'and' = @(
                            @{'email' = @{'$regex' = "(?i)(`^$($UserIdentifier)`$)" } }
                        )
                    }
                    fields = 'email'
                }
                $UserIdentifierResults = Search-JcSdkUser -Body:($UserIdentifierSearch)
                # Set UserIdentifierValue; this is a validated user id
                $UserIdentifierValue = $UserIdentifierResults.id
                # if no value was returned, then assume the case this is actually a username and search
                if (!$UserIdentifierValue) {
                    $UserIdentifierSearch = @{
                        filter = @{
                            'and' = @(
                                @{'username' = @{'$regex' = "(?i)(`^$($UserIdentifier)`$)" } }
                            )
                        }
                        fields = 'username'
                    }
                    $UserIdentifierResults = Search-JcSdkUser -Body:($UserIdentifierSearch)
                    # Set UserIdentifierValue from the matched username
                    $UserIdentifierValue = $UserIdentifierResults.id
                }
            } catch {
                # search the username in the search endpoint
                $UserIdentifierSearch = @{
                    filter = @{
                        'and' = @(
                            @{'username' = @{'$regex' = "(?i)(`^$($UserIdentifier)`$)" } }
                        )
                    }
                    fields = 'username'
                }
                $UserIdentifierResults = Search-JcSdkUser -Body:($UserIdentifierSearch)
                # Set UserIdentifierValue from the matched username
                $UserIdentifierValue = $UserIdentifierResults.id
            }
        }
    }
    end {
        if ($null -eq $UserIdentifierValue) {
            Write-Error "Could not validate $UserIdentifier. Please ensure the information was entered correctly"
        } else {
            return $UserIdentifier
        }
    }
}