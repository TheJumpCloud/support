Describe 'Add-JCSystemUser' {

    It "Adds a single user to a single system by Username and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams.Username -SystemID $PesterParams.SystemID -force
        $UserAdd = Add-JCSystemUser -Username $PesterParams.Username -SystemID $PesterParams.SystemID
        $UserAdd.Status | Should Be 'Added'
    }


    It "Adds a single user to a single system by UserID and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams.Username -SystemID $PesterParams.SystemID -force
        $UserAdd = Add-JCSystemUser -UserID $PesterParams.UserID -SystemID $PesterParams.SystemID
        $UserAdd.Status | Should Be 'Added'
    }

    It "Adds two users to a single system using the pipeline and system ID" {
        $MultiUserRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCSystemUser -SystemID $PesterParams.SystemID -force
        $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $PesterParams.SystemID
        $MultiUserAdd.Status.Count | Should Be 2
    }

}