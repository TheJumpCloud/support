Describe -Tag:('MSP') 'Import-JCMSPFromCSV' {

    BeforeAll {
        # Validate MSP Test org is set to default:
        $org = Get-JCSdkOrganization -id $env:PESTER_ORGID
        if (($org.Settings.Name -ne "PesterMSP") -And ($org.Settings.Name -ne "Updated PesterMSP")) {
            Set-JcSdkOrganization -Id $env:PESTER_ORGID -Settings @{Name = "PesterMSP" }
        }
    }
    Context 'Organization Import' {
        it 'should import a valid org with the correct system users' {
            $orgName = 'org name'
            $orgUserMax = '10'
            $generatedID = 'p46392y0oyc45cez6ntedo92'

            $CSVDATA = @{
                name           = $orgName
                maxSystemUsers = $orgUserMax
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/importOrg.csv" -Force

            # mock IRM requests to return expected results
            Mock -ModuleName "JumpCloud" -commandName Invoke-RestMethod -MockWith {
                $obj = [PSCustomObject]@{
                    'name'           = $orgName
                    'maxSystemUsers' = $orgUserMax
                    'id'             = $generatedID
                }
                return $obj
            }
            $status = import-JCMSPFromCSV -CSVFilePath "$PesterParams_ImportPath/importOrg.csv" -ProviderID $ProviderID -force

            # assert statements
            $status.count | should -BeExactly 1
            $status.name | should -Be $orgName
            $status.maxSystemUsers | should -be $orgUserMax
            $status.status | should -be "Imported"
            $status.id | should -be $generatedID
        }
        it 'should throw an error when the org already exists on console' {
            $orgs = Get-JcSdkOrganization
            $selectedOrg = $orgs[$(Get-Random (0..($orgs.count - 1)))]

            $orgName = $selectedOrg.DisplayName
            $orgUserMax = '10'
            $generatedID = $selectedOrg.id

            $CSVDATA = @{
                name           = $orgName
                maxSystemUsers = $orgUserMax
            }
            $CSVFILE = $CSVDATA | Export-Csv "$PesterParams_ImportPath/importOrg.csv" -Force

            # mock IRM requests to return expected results
            Mock Invoke-RestMethod -MockWith {
                $obj = [PSCustomObject]@{
                    'name'           = $orgName
                    'maxSystemUsers' = $orgUserMax
                    'id'             = $generatedID
                }
                return $obj
            }
            { import-JCMSPFromCSV -CSVFilePath "$PesterParams_ImportPath/importOrg.csv" -ProviderID $ProviderID -force } | should -Throw "Duplicate organization name: $($orgName) already exists on console.jumpcloud.com"
        }
        it 'should throw an error when duplicate org names in the csv does are defined' {
            $orgName = "same name"
            $orgUserMax = '10'
            $generatedID = 'p46392y0oyc45cez6ntedo92'
            $CSV = New-Object System.Collections.ArrayList
            $CSV.add(@{
                    name           = $orgName
                    maxSystemUsers = $orgUserMax
                }) | Out-Null
            $CSV.add(@{
                    name           = $orgName
                    maxSystemUsers = $orgUserMax
                }) | Out-Null
            $CSVFILE = $CSV | Export-Csv "$PesterParams_ImportPath/importOrg.csv" -Force

            # mock IRM requests to return expected results
            Mock Invoke-RestMethod -MockWith {
                $obj = [PSCustomObject]@{
                    'name'           = $orgName
                    'maxSystemUsers' = $orgUserMax
                    'id'             = $generatedID
                }
                return $obj
            }
            { import-JCMSPFromCSV -CSVFilePath "$PesterParams_ImportPath/importOrg.csv" -ProviderID $ProviderID -force } | should -Throw "Duplicate organization name: $($orgName) in import file. organiztion name already exists."
        }
    }
}
