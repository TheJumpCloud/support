Connect-JCOnlineTest

Describe -Tag:('JCPasswordReset') "Sent-JCPasswordReset 1.6.0" {

    It "Sends a single password reset email by username" {

        $SingleResetEmail = Send-JCPasswordReset -username $PesterParams.Username
        $SingleResetEmail.ResetEmail | Should -be "Sent"


    }

    It "Sends a single password reset email by UserID" {

        $SingleResetEmail = Send-JCPasswordReset -UserID $PesterParams.UserID
        $SingleResetEmail.ResetEmail | Should -be "Sent"

    }

}
