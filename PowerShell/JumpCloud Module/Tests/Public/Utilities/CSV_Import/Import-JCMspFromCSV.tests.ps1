
# BeforeAll {
# }
Describe -Tag:('MSP') 'Import-JCMSPFromCSV' {

    BeforeAll {
        BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -JumpCloudOrgId:($env:XORGID_PesterMSP) -force | Out-Null }

        # Validate MSP Test org is set to default:
        $org = Get-JCSdkOrganization -id $env:XORGID_PesterMSP
        if (($org.Settings.Name -ne "PesterMSP") -And ($org.Settings.Name -ne "Updated PesterMSP")) {
            Set-JcSdkOrganization -Id $env:XORGID_PesterMSP -Settings @{Name = "PesterMSP" }
        }
    }

    Context 'Organization pre-import validation tests' {
        it 'should throw an error when an organiztion name already exists in the console' {

        }
        it 'should throw an error when an organiztion name is duplicated in the import CSV' {

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


    It 'Should return a response' {

    }

    it ' should trhow an error' -skip {
        Mock Invoke-RestMethod {
            # Use the actual types returned by your function or directly from Invoke-WebRequest.
            if ($PSVersionTable.PSEdition -eq "Desktop") {
                $WR = New-MockObject -Type 'System.Net.HttpWebResponse'
                $Code = [System.Net.HttpStatusCode]::NotFound
                # Use Add-Member because StatusCode is a read-only field on HttpWebResponse
                $WR | Add-Member -MemberType NoteProperty -Name StatusCode -Value $Code -Force
                $Status = [System.Net.WebExceptionStatus]::ProtocolError
                $Ex = [System.Net.WebException]::new("404", $null, $Status, $WR)
            } else {
                $Message = [System.Net.Http.HttpResponseMessage]::new()
                $Message.StatusCode = [System.Net.HttpStatusCode]::NotFound
                $details = [System.Net.WebException]::new('This is the error from my API')
                $Ex = [Microsoft.PowerShell.Commands.HttpResponseException]::new("404", $Message)
            }
            throw $details
        }

        $status = import-jcMSPFromCSV -CSVFilePath "/Users/jworkman/demo/csvMTP/JCMSPUpdateImport_06-06-2023.csv" -ProviderID $ProviderID -force
        write-host "status is $status"
    }
}
