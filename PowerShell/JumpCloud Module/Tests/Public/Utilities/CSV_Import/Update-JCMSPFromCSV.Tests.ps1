Describe -Tag:('MSP') 'Update-JCMSPFromCSV' -Skip {

    BeforeAll {
        # Validate MSP Test org is set to default:
        $updatedOrgName = 'Updated PesterMSP'
        $defaultOrgName = 'PesterMSP'
        $org = Get-JCSdkOrganization -id $env:JCOrgId
        if (($org.Settings.Name -ne $defaultOrgName) -And ($org.Settings.Name -eq $updatedOrgName)) {
            Set-JcSdkOrganization -Id $env:JCOrgId -Settings @{Name = $defaultOrgName }
            Write-Host "resetting org name"
        }
    }
    it 'should throw an error when an org id in the csv does not exist in console' {
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
        { Update-JCMSPFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateOrg.csv" -ProviderID $ProviderID -force } | should -Throw "Organization name: $($orgName) with id: $($generatedID) does not exist on console.jumpcloud.com"
    }
    it 'should throw an error when duplicate org names in the csv does are defined' {
        $orgs = Get-JcSdkOrganization
        # Select two real orgs:
        $selectedOrg1 = $orgs[$(Get-Random (0..[int]($orgs.count / 2)))]
        $selectedOrg2 = $orgs[$(Get-Random ([int]($orgs.count / 2 + 1)..($orgs.count - 1)))]


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
        { Update-JCMSPFromCSV -CSVFilePath "$PesterParams_UpdatePath/UpdateOrg.csv" -ProviderID $ProviderID -force } | should -Throw "Duplicate organization name: $($selectedOrg1.DisplayName) in update file. organiztion name already exists."
    }
    It 'Org Name and UserMax is updated with CSV' {
        # Get orgs list:
        $orgs = Get-JcSdkOrganization
        # Select one real org:
        $selectedOrg = Get-JcSdkOrganization -Id $env:JCOrgId

        $orgName = $updatedOrgName
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
}
