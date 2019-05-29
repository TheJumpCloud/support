Connect-JCOnlineTest
Describe "Invoke-JCDeployment 1.7.0" {

    It "Invokes a JumpCloud command deployment with 2 systems" {

        $Invoke2 = Invoke-JCDeployment -CommandID $PesterParams.DeployCommandID -CSVFilePath $JCDeployment_2_CSV
        $Invoke2.SystemID.count | Should -be "2"
    }

    It "Invokes a JumpCloud command deployment with 10 systems" {
        $Invoke10 = Invoke-JCDeployment -CommandID $PesterParams.DeployCommandID -CSVFilePath $JCDeployment_10_CSV
        $Invoke10.SystemID.count | Should -be "10"
    }

}
