
# BeforeAll {
# }
Describe -Tag:('MSP') 'Update-JCMSPFromCSV' {

    BeforeAll {
        BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -JumpCloudOrgId:($env:XORGID_PesterMSP) -force | Out-Null }

        # Validate MSP Test org is set to default:
        $org = Get-JCSdkOrganization -id $env:XORGID_PesterMSP
        if (($org.Settings.Name -ne "PesterMSP") -And ($org.Settings.Name -ne "Updated PesterMSP")) {
            Set-JcSdkOrganization -Id $env:XORGID_PesterMSP -Settings @{Name = "PesterMSP" }
        }
    }

    it 'should throw an error when an org name in the csv does not exist in console' {
        # Get orgs list:
        $orgs = Get-JcSdkOrganization
        # Select two real orgs:
        $selectedOrg1 = $orgs[$(Get-Random (0..[int]($orgs.count / 2)))]
        $selectedOrg2 = $orgs[$(Get-Random ([int]($orgs.count / 2 + 1)..$orgs.count))]


        $orgName = "Fake Org"
        $orgUserMax = '10'
        $generatedID = 'p46392y0oyc45cez6ntedo92'
        $CSV = New-Object System.Collections.ArrayList
        $CSV.add(@{
                name           = $selectedOrg1.DisplayName
                maxSystemUsers = $orgUserMax
                id             = $selectedOrg1.Id
            }) | Out-Null
        $CSV.add(@{
                name           = $orgName
                maxSystemUsers = $orgUserMax
                id             = $generatedID
            }) | Out-Null
        $CSVFILE = $CSV | Export-Csv "$PesterParams_UpdatePath/UpdateOrg.csv" -Force

        # mock IRM requests to return expected results
        Mock Invoke-RestMethod -MockWith {
            $obj = [PSCustomObject]@{
                'name'           = $orgName
                'maxSystemUsers' = $orgUserMax
                'id'             = $generatedID
            }
            return $obj
        }
        { Update-JCMSPFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateOrg.csv" -ProviderID $ProviderID -force } | should -Throw "Organization name: $($orgName) does not exist on console.jumpcloud.com"
    }
    it 'should throw an error when duplicate org names in the csv does are defined' {
        $orgs = Get-JcSdkOrganization
        # Select two real orgs:
        $selectedOrg1 = $orgs[$(Get-Random (0..[int]($orgs.count / 2)))]
        $selectedOrg2 = $orgs[$(Get-Random ([int]($orgs.count / 2 + 1)..$orgs.count))]


        $orgName = "fake name"
        $orgUserMax = '10'
        $generatedID = 'p46392y0oyc45cez6ntedo92'
        $CSV = New-Object System.Collections.ArrayList
        $CSV.add(@{
                name           = $selectedOrg1.DisplayName
                maxSystemUsers = $orgUserMax
                id             = $selectedOrg1.Id
            }) | Out-Null
        $CSV.add(@{
                name           = $selectedOrg1.DisplayName
                maxSystemUsers = $orgUserMax
                id             = $selectedOrg1.id
            }) | Out-Null
        $CSV.add(@{
                name           = $selectedOrg2.DisplayName
                maxSystemUsers = $orgUserMax
                id             = $selectedOrg2.id
            }) | Out-Null
        $CSVFILE = $CSV | Export-Csv "$PesterParams_UpdatePath/UpdateOrg.csv" -Force

        # mock IRM requests to return expected results
        Mock Invoke-RestMethod -MockWith {
            $obj = [PSCustomObject]@{
                'name'           = $orgName
                'maxSystemUsers' = $orgUserMax
                'id'             = $generatedID
            }
            return $obj
        }
        { Update-JCMSPFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateOrg.csv" -ProviderID $ProviderID -force } | should -Throw "Duplicate organization name: $($selectedOrg1.DisplayName) in import file. organiztion name already exists."
    }
    It 'Org Name and UserMax is updated with CSV' {
        # Get orgs list:
        $orgs = Get-JcSdkOrganization
        # Select one real org:
        $selectedOrg = Get-JcSdkOrganization -Id $env:JCOrgId

        $orgName = "Updated PesterMSP"
        $orgUserMax = '10'
        $generatedID = 'p46392y0oyc45cez6ntedo92'
        $CSV = New-Object System.Collections.ArrayList
        $CSV.add(@{
                name           = $orgName
                maxSystemUsers = $orgUserMax
                id             = $selectedOrg.Id
            }) | Out-Null
        $CSVFILE = $CSV | Export-Csv "$PesterParams_UpdatePath/UpdateOrg.csv" -Force

        $updatedOrgs = Update-JCMSPFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateOrg.csv" -ProviderID $ProviderID -force

        $updatedOrgs.id | should -Be $selectedOrg.id
        $updatedOrgs.name | should -not -Be $selectedOrg.DisplayName
        $updatedOrgs.name | should -Be $orgName
        $updatedOrgs.maxSystemUsers | should -Be $orgUserMax
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

        $status = Update-JCMSPFromCSV -CSVFilePath "/Users/jworkman/demo/csvMTP/JCMSPUpdateImport_06-06-2023.csv" -ProviderID '5c901bece9665c34ee5b846a' -force
        write-host "status is $status"
    }
}
