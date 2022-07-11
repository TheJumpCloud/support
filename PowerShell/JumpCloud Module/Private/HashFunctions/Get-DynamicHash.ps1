Function Get-DynamicHash () {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)][ValidateSet('System', 'User', 'Command', 'Group')][string]$Object,
        [Parameter(Position = 1, Mandatory = $true)][ValidateNotNullOrEmpty()][string[]]$returnProperties
    )
    DynamicParam {
        if ($Object -eq 'Group') {
            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramAttributesCollect = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

            $paramAttributes = New-Object -Type System.Management.Automation.ParameterAttribute
            $paramAttributes.Mandatory = $true
            $paramAttributesCollect.Add($paramAttributes)
            $paramAttributesCollect.Add((New-Object -Type System.Management.Automation.ValidateSetAttribute('System', 'User')))

            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("GroupType", [string], $paramAttributesCollect)

            $paramDictionary.Add("GroupType", $dynParam1)
            return $paramDictionary
        }
    }
    begin {
        $GroupType = $PSBoundParameters['GroupType']
        $DynamicHash = New-Object System.Collections.Hashtable
    }
    process {
        switch ($Object) {
            System {
                Write-Debug "Generating ResultsHash"
                $ResultsHash = Get-JCSystem -returnProperties $returnProperties
            }
            User {
                Write-Debug "Generating ResultsHash"
                $ResultsHash = Get-JCUser -returnProperties $returnProperties
            }
            Command {
                Write-Debug "Generating ResultsHash"
                $ResultsHash = Get-JCCommand -returnProperties $returnProperties
            }
            Group {
                Write-Debug "Generating ResultsHash"
                $returnProperties += "id"
                switch ($GroupType) {
                    System {
                        $ResultsHash = Get-JCGroup -Type System | Select-Object -Property $returnProperties
                    }
                    User {
                        $ResultsHash = Get-JCGroup -Type User | Select-Object -Property $returnProperties
                    }
                }
            }
        }
        Write-Debug "Adding results to hashtable"
        foreach ($Result in $ResultsHash) {
            if ($Result.id) {
                $DynamicHash.Add($Result.id, @($Result | Select-Object -ExcludeProperty 'id'))
            } else {
                $DynamicHash.Add($Result._id, @($Result | Select-Object -ExcludeProperty '_id'))
            }
        }
    }
    end {
        return $DynamicHash
    }
}
