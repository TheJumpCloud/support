Describe -Tag:('JCDeployment') "Invoke-JCDeployment 1.7.0" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null }
    It "Invokes a JumpCloud command deployment with 2 systems" {

        $Invoke2 = Invoke-JCDeployment -CommandID $PesterParams_DeployCommandID -CSVFilePath $JCDeployment_2_CSV
        $Invoke2.SystemID.count | Should -Be "2"
    }

    It "Invokes a JumpCloud command deployment with 10 systems" {
        $Invoke10 = Invoke-JCDeployment -CommandID $PesterParams_DeployCommandID -CSVFilePath $JCDeployment_10_CSV
        $Invoke10.SystemID.count | Should -Be "10"
    }

}
