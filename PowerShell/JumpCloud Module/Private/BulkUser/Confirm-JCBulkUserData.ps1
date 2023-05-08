function Confirm-JCBulkUserData {
    Param(
        [Parameter(Position = 0, Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject[]]$bulkUserData,
        [Parameter(Position = 1, Mandatory = $true)][ValidateSet('New', 'Set')][string]$endpoint
    )
    begin {
        # initalize the bulk user attribute mapping for valid user properties
        switch ($endpoint) {
            New {
                $BulkUserAttributeMap = [JumpCloud.SDK.V1.Models.SystemuserPutPost]::new()
            }
            Set {
                $BulkUserAttributeMap = [JumpCloud.SDK.V1.Models.SystemuserPut]::new()
                $BulkUserAttributeMap | Add-Member -MemberType NoteProperty -Name "id" -Value ""
            }
        }

        $bulkUserArray = [System.Collections.ArrayList]@()
    }
    process {
        $bulkUserData | ForEach-Object {

            # Flag to track if object is valid or not
            $validObject = $true

            # Ensure that required properties are set for respective endpoints
            # New: username, email
            # Set: id
            if ($endpoint -eq "New") {
                if ($_.psobject.Properties.Name -notcontains "email" -or $_.psobject.Properties.Name -notcontains "username") {
                    Write-Debug "Missing required property in Object"
                    throw "$($_) is missing required property: email or username"
                }
            } else {
                if ($_.psobject.Properties.Name -notcontains "id") {
                    Write-Debug "Missing required property in Object"
                    throw "$($_) is missing required property: id"
                }
            }

            # Iterate through all properties and compare to properties in the BulkUserAttributeMap object
            $_.psobject.Properties.Name.GetEnumerator() | ForEach-Object {
                if ($_ -in $bulkUserAttributeMap.psobject.Properties.Name) {
                    Write-Debug "$($_): Valid Property"
                } else {
                    Write-Debug "$($_): Invalid Property"
                    $validObject = $false
                }
            }

            # If a single property was determined to be invalid, throw error
            if ($validObject -eq $false) {
                throw "$($_) is not a valid Object. Please validate that properties are set correctly"
            } else {
                # Add valid object to output array
                $bulkUserArray.Add($_) | Out-Null
            }
        }
    }
    end {
        return $bulkUserArray
    }
}
