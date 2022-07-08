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
                $ResultsHash = Get-JCSystem -returnProperties $returnProperties
            }
            User {
                $ResultsHash = Get-JCUser -returnProperties $returnProperties
            }
            Command {
                $ResultsHash = Get-JCCommand -returnProperties $returnProperties
            }
            Group {
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
        foreach ($Result in $ResultsHash) {
            $AttributeHash = $Result | Select-Object -ExcludeProperty $(if ($Result.id) {
                    'id'
                } else {
                    '_id'
                })
            $DynamicHash.Add($(if ($Result.id) {
                        $Result.id
                    } else {
                        $Result._id
                    }), $AttributeHash)
        }
    }
    end {
        return $DynamicHash
    }
}