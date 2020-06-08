Describe -Tag:('JCPasswordReset') "Sent-JCPasswordReset 1.6.0" {
    Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
    It "Sends a single password reset email by username" {

        $SingleResetEmail = Send-JCPasswordReset -username $PesterParams_Username
        $SingleResetEmail.ResetEmail | Should -be "Sent"


    }

    It "Sends a single password reset email by UserID" {

        $SingleResetEmail = Send-JCPasswordReset -UserID $PesterParams_UserID
        $SingleResetEmail.ResetEmail | Should -be "Sent"

    }

}
