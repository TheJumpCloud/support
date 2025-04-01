function New-UriListItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [System.String]$uri,

        [Parameter(Mandatory = $false)]
        [ValidateSet('int', 'string', 'chr', 'boolean', 'bool', 'float', 'xml', 'base64', 'b64')]
        [System.String]$format,

        [Parameter(Mandatory = $false)]
        [System.String]$value
    )

    process {
        if (-not $uri -or -not $format -or -not $value) {
            Write-Host "Please provide the URI, format, and value."
            $uri = Read-Host "Enter URI"

            do {
                $format = Read-Host "Enter format (int, string, boolean, float, xml, base64)"
                if ($format -notin ('int', 'string', 'boolean', 'float', 'xml', 'base64')) {
                    Write-Warning "Invalid format. Please enter one of the following: int, string, boolean, float, xml, base64"
                }
            } while ($format -notin ('int', 'string', 'boolean', 'float', 'xml', 'base64'))

            $isValidValue = $false
            do {
                $value = Read-Host "Enter the value: (format: $format)"

                switch ($format) {
                    'int' {
                        try {
                            [int]$value
                            $isValidValue = $true
                        } catch {
                            Write-Warning "Invalid integer value. Please enter a valid integer number."
                        }

                    }
                    'float' {
                        try {
                            [float]$value
                            $isValidValue = $true
                        } catch {
                            Write-Warning "Invalid float value. Please enter a valid float number."
                        }

                    }
                    'boolean' {
                        Write-Host "Please enter 'true' or 'false'."
                        try {
                            [System.Convert]::ToBoolean($value)
                            $isValidValue = $true
                            $format = 'bool' # API expects boolean to be passed as bool
                        } catch {
                            Write-Warning "Invalid boolean value. Please enter 'true' or 'false'."
                        }
                    }
                    'string' {
                        $isValidValue = $true
                        # Convert the format string to chr since it is default for the API
                        $format = 'chr' # API expects a string value for chr, so we can just return the string as is.
                    }
                    'xml' {
                        # Convert to XML
                        try {
                            [xml]$value
                            $isValidValue = $true
                        } catch {
                            Write-Warning "Invalid XML value. Please enter a valid XML string."
                        }
                    }
                    'base64' {
                        try {

                            [void][Convert]::FromBase64String($value)
                            $isValidValue = $true
                            $format = 'b64' # API expects base64 to be passed as b64
                        } catch {
                            Write-Warning "Invalid base64 value. Please enter a valid base64 string."
                        }

                    }
                    default {
                        Write-Warning "Invalid format. Please enter int, string, float, xml, boolean, or base64."
                        $isValidValue = $false
                    }
                }

            } while (!$isValidValue)
        } else {
            $isValidValue = $false;
            try {
                switch ($format) {
                    'int' {
                        try {
                            [int]$value
                            $isValidValue = $true
                        } catch {
                            throw "Invalid integer value. Please enter a valid integer number."
                        }

                    }
                    'float' {
                        try {
                            [float]$value
                            $isValidValue = $true
                        } catch {
                            throw "Invalid float value. Please enter a valid float number."
                        }

                    }
                    'boolean' {
                        try {
                            [System.Convert]::ToBoolean($value)
                            $isValidValue = $true
                            $format = 'bool' # API expects boolean to be passed as bool
                        } catch {
                            throw "Invalid boolean value. Please enter 'true' or 'false'."
                        }
                    }
                    'string' {
                        try {
                            $format = 'chr' # API expects a string value for chr, so we can just return the string as is.
                            $isValidValue = $true
                        } catch {
                            throw "Invalid string value. Please enter a valid string."
                        }

                    }
                    'xml' {
                        try {
                            [xml]$value
                            $isValidValue = $true
                        } catch {
                            throw "Invalid XML value. Please enter a valid XML string."
                        }

                    }
                    'base64' {
                        try {
                            $format = 'b64' # API expects base64 to be passed as b64
                            [Convert]::FromBase64String($value)
                            $isValidValue = $true
                        } catch {
                            throw "Invalid base64 value. Please enter a valid base64 string."
                        }

                    }
                    default {
                        throw "Invalid format. Please enter int, string, float, xml, boolean, or base64."
                    }
                }
            } catch {
                Write-Warning "Invalid value for format '$format'. Please check parameters."
            }
            if (!($isValidValue)) {
                return @()
            }
        }

    } end {
        # Create the object
        # Return the object as a list item
        $uriListItem = [PSCustomObject]@{
            format = $format
            uri    = $uri
            value  = $value
        }
        # Return the object
        return $uriListItem
    }
}