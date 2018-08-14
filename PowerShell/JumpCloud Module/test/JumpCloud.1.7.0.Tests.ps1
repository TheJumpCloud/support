$SingleAdminAPIKey = ""

$SetCommandID = ""

$DeployCommandID = ""

$CSVFilePath_2Systems = ""

$CSVFilePath_10Systems = ""

$CSVFilePath_100Systems = ""

Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null

    }
}

Describe "Set-JCCommand" {

    It "Updates the command" {
        $CmdUpdate = Set-JCCommand -CommandID $SetCommandID -command "Updated command"
        $CmdUpdate.command | Should -be "Updated command"
        $CmdUpdate = Set-JCCommand -CommandID $SetCommandID -command "Not updated command"

    }

    It "Updates the launchType to manual" {
        $CmdUpdate = Set-JCCommand -CommandID $SetCommandID -launchType manual
        $CmdUpdate.launchType | Should -be "manual"
    }

    It "Updates the launchType to trigger" {
        $CmdUpdate = Set-JCCommand -CommandID $SetCommandID -launchType trigger -trigger "pesterTrigger"
        $CmdUpdate.launchType | Should -be "trigger"
        $CmdUpdate.trigger | Should -be "pesterTrigger"
    }

    It "Updates the name" {
        $CmdQuery = Get-JCCommand -CommandID $SetCommandID
        $CmdUpdate = Set-JCCommand -CommandID $SetCommandID -name "Updated name"
        $CmdUpdate.name | Should be "Updated Name"
        $SetBack = Set-JCCommand -CommandID $SetCommandID -name $CmdQuery.name

    }

    It "Updates the timeout" {
        $CmdQuery = Get-JCCommand -CommandID $SetCommandID
        $CmdUpdate = Set-JCCommand -CommandID $SetCommandID -timeout "200"
        $CmdUpdate.timeout | Should be "200"
        $SetBack = Set-JCCommand -CommandID $SetCommandID -timeout $CmdQuery.timeout
    }
}

Describe "Invoke-JCDeployment" {


    It "Invokes a JumpCloud command deployment with 2 systems" {

        $Invoke2 = Invoke-JCDeployment -CommandID $DeployCommandID -CSVFilePath $CSVFilePath_2Systems
        $Invoke2.SystemID.count | Should -be "2"
    }

    It "Invokes a JumpCloud command deployment with 10 systems" {
        $Invoke10 = Invoke-JCDeployment -CommandID $DeployCommandID -CSVFilePath $CSVFilePath_10Systems
        $Invoke10.SystemID.count | Should -be "10"
    }

    It "Invokes a JumpCloud command deployment with 100 systems" {
        $Invoke10 = Invoke-JCDeployment -CommandID $DeployCommandID -CSVFilePath $CSVFilePath_100Systems
        $Invoke10.SystemID.count | Should -be "100"
    }

}


