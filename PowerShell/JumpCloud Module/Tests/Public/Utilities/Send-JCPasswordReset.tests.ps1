Describe -Tag:('JCPasswordReset') "Sent-JCPasswordReset 1.6.0" {
    BeforeAll { Connect-JCOnline -JumpCloudApiKey:($PesterParams_ApiKey) -force | Out-Null }
    It "Sends a single password reset email by username" {

        $SingleResetEmail = Send-JCPasswordReset -username $PesterParams_User1.Username
        $SingleResetEmail.ResetEmail | Should -Be "Sent"


    }

    It "Sends a single password reset email by UserID" {

        $SingleResetEmail = Send-JCPasswordReset -UserID $PesterParams_User1.Id
        $SingleResetEmail.ResetEmail | Should -Be "Sent"

    }

}
