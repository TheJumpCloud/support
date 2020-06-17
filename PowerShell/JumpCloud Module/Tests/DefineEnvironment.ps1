Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
)
# Authenticate to JumpCloud
Connect-JCOnline -JumpCloudApiKey:($JumpCloudApiKey) -force | Out-Null
# Define variable names
$PesterParamsHash_VariableName = @{
    VariableNamePrefix     = 'PesterParams_';
    VariableNamePrefixHash = 'PesterParamsHash_';
}
# Determine OS type
$OS = If ($env:AGENT_OS)
{
    $env:AGENT_OS
}
Else
{
    If ($PSVersionTable.PSEdition -eq 'Core')
    {
        If ($IsWindows) { 'Windows_NT' }
        ElseIf ($IsMacOS) { 'Darwin' }
        ElseIf ($IsLinux) { 'Linux' }
        Else { Write-Error ('Unknown Operation System') }
    }
    Else
    {
        'Windows_NT'
    }
}
# Set test parameters bases on os
$PesterParamsHash_OS = If ($OS -eq 'Windows_NT')
{
    @{
        OrgIdMsp1              = "5d2f6ff0e7aad925fc317577"
        OrgIdMsp2              = "5d2f6ffd8910770b8545756a"
        networkSourceIpInitial = '250.250.250.250'
        networkSourceIpUpdate  = '250.250.250.251'
    }
}
ElseIf ($OS -eq 'Darwin')
{
    @{
        OrgIdMsp1              = "5d2f7011f3b0a039b65f4e8b"
        OrgIdMsp2              = "5d2f701be7aad925fc317667"
        networkSourceIpInitial = '250.251.250.251'
        networkSourceIpUpdate  = '250.251.250.252'
    }
}
ElseIf ($OS -eq 'Linux')
{
    @{
        OrgIdMsp1              = "5d2f7024f0e1526be4df38e7"
        OrgIdMsp2              = "5d35e14eb90ad46e65ba0739"
        networkSourceIpInitial = '250.252.250.252'
        networkSourceIpUpdate  = '250.252.250.253'
    }
}
Else
{
    Write-Error ("Unknown OS: $($OS)")
}
# Configure for local testing
If ($env:USERNAME -ne 'VssAdministrator')
{
    $PesterParamsHash_OS.networkSourceIpInitial = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
    $PesterParamsHash_OS.networkSourceIpUpdate = [IPAddress]::Parse([String](Get-Random)).IPAddressToString
}
# Parameters that are not Org specific
$PesterParamsHash_Common = @{
    ApiKey                          = $JumpCloudApiKey
    ApiKeyMsp                       = $JumpCloudApiKeyMsp
    PesterResultsFileXml            = "$($PSScriptRoot)/JumpCloud-$($OS)-TestResults.xml"
    UserLastName                    = 'Test'
    Groups                          = @('One', 'Two', 'Three', 'Four', 'Five', 'Six')
    # CSV Files
    Import_JCUsersFromCSV_1_1_Tests = "$PSScriptRoot/Csv_Files/import/ImportExample_Pester_Tests_1.1.0.csv" # This CSV file is specific to pester environment (SystemID's and Group Names)
    JCDeployment_2_CSV              = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_2.csv"
    JCDeployment_10_CSV             = "$PSScriptRoot/Csv_Files/commandDeployment/JCDeployment_10.csv"
    ImportPath                      = "$PSScriptRoot/Csv_Files/import"
    UpdatePath                      = "$PSScriptRoot/Csv_Files/update"
    # Policy Info
    MultiplePolicyList              = @('1 Linux', 'Disable USB Storage - Linux')
    SinglePolicyList                = @('Disable USB Storage - Linux')
    CommandResultCount              = 10
    SystemNameLinux                 = 'PesterTest-Linux'
    SystemNameMac                   = 'PesterTest-Mac'
    SystemNameWindows               = 'PesterTest-Windows'
    SystemInsightsTables            = (Get-JCType -Type:('system')).SystemInsights.Table
}
# Define items
$RandomString1 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
$RandomString2 = ( -join (( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
$PesterParamsHash_Definitions = @{
    NewUser1        = @{
        username                 = "pester.tester1_$($RandomString1)"
        email                    = "$($RandomString1)1@DeleteMe.com"
        employeeIdentifier       = "employeeIdentifier_$($RandomString1)"
        allow_public_key         = $false
        password_never_expires   = $true
        NumberOfCustomAttributes = 1
        Attribute1_name          = 'One1'
        Attribute1_value         = 'Attr_1'
        company                  = 'company_1'
        costCenter               = 'costCenter_1'
        department               = 'department_1'
        description              = 'description_1'
        displayName              = 'displayName_1'
        employeeType             = 'employeeType_1'
        firstname                = 'Pester_1'
        home_city                = 'home_city_1'
        home_country             = 'home_country_1'
        home_number              = 'home_number_1'
        home_poBox               = 'home_poBox_1'
        home_postalCode          = 'home_postalCode_1'
        home_state               = 'home_state_1'
        home_streetAddress       = 'home_streetAddress_1'
        jobTitle                 = 'jobTitle_1'
        lastname                 = 'Tester_1'
        location                 = 'location_1'
        MiddleName               = 'middlename_1'
        mobile_number            = 'mobile_number_1'
        work_city                = 'work_city_1'
        work_country             = 'work_country_1'
        work_fax_number          = 'work_fax_number_1'
        work_mobile_number       = 'work_mobile_number_1'
        work_number              = 'work_number_1'
        work_poBox               = 'work_poBox_1'
        work_postalCode          = 'work_postalCode_1'
        work_state               = 'work_state_1'
        work_streetAddress       = 'work_streetAddress_1'
    };
    NewUser2        = @{
        username                 = "pester.tester2_$($RandomString2)"
        email                    = "$($RandomString2)2@DeleteMe.com"
        employeeIdentifier       = "employeeIdentifier_$($RandomString2)"
        allow_public_key         = $false
        password_never_expires   = $true
        NumberOfCustomAttributes = 1
        Attribute1_name          = 'One2'
        Attribute1_value         = 'Attr_2'
        company                  = 'company_2'
        costCenter               = 'costCenter_2'
        department               = 'department_2'
        description              = 'description_2'
        displayName              = 'displayName_2'
        employeeType             = 'employeeType_2'
        firstname                = 'Pester_2'
        home_city                = 'home_city_2'
        home_country             = 'home_country_2'
        home_number              = 'home_number_2'
        home_poBox               = 'home_poBox_2'
        home_postalCode          = 'home_postalCode_2'
        home_state               = 'home_state_2'
        home_streetAddress       = 'home_streetAddress_2'
        jobTitle                 = 'jobTitle_2'
        lastname                 = 'Tester_2'
        location                 = 'location_2'
        MiddleName               = 'middlename_2'
        mobile_number            = 'mobile_number_2'
        work_city                = 'work_city_2'
        work_country             = 'work_country_2'
        work_fax_number          = 'work_fax_number_2'
        work_mobile_number       = 'work_mobile_number_2'
        work_number              = 'work_number_2'
        work_poBox               = 'work_poBox_2'
        work_postalCode          = 'work_postalCode_2'
        work_state               = 'work_state_2'
        work_streetAddress       = 'work_streetAddress_2'
    };
    NewSystemGroup  = @{
        GroupName = 'PesterTest_SystemGroup'
    };
    NewUserGroup    = @{
        GroupName = 'PesterTest_UserGroup'
    };
    NewRadiusServer = @{
        networkSourceIp = $PesterParamsHash_OS.networkSourceIpInitial
        sharedSecret    = 'f3TkHSK2GT4JR!W9tugRPp2zQnAVObv'
        name            = 'PesterTest_RadiusServer'
    };
    NewCommand1     = @{
        name        = 'GetJCAgentLog'
        trigger     = 'GetJCAgentLog'
        commandType = 'linux'
        command     = 'cat /opt/jc/*.log'
        launchType  = 'trigger'
        timeout     = 120
    };
    NewCommand2     = @{
        name        = 'Invoke JCDeployment Test'
        commandType = 'linux'
        command     = 'echo $One echo $Two'
        launchType  = 'manual'
        timeout     = 0
    };
    NewCommand3     = @{
        name        = 'Pester Set-JCCommand'
        commandType = 'linux'
        command     = 'Not updated command'
        launchType  = 'trigger'
        timeout     = 0
        trigger     = 'pesterTrigger'
    };
    NewCommand4     = @{
        name        = 'Invoke Pester One Variable'
        commandType = 'linux'
        command     = 'echo $One'
        launchType  = 'trigger'
        timeout     = 120
        trigger     = 'onetrigger'
    };
    NewCommand5     = @{
        name        = 'Invoke Pester Two Variable'
        commandType = 'linux'
        command     = "echo `$One`necho `$Two"
        launchType  = 'trigger'
        timeout     = 120
        trigger     = 'twotrigger'
    };
    NewCommand6     = @{
        name        = 'Invoke Pester Three Variable'
        commandType = 'linux'
        command     = "echo `$One`necho `$Two`necho `$Three"
        launchType  = 'trigger'
        timeout     = 120
        trigger     = 'threetrigger'
    }
};
# Combine all hash tables into one list and foreach of their values create a new global parameter
(Get-Variable -Scope:('Script') -Name:("$($PesterParamsHash_VariableName.VariableNamePrefixHash)*")).Value | ForEach-Object {
    $_.GetEnumerator() | ForEach-Object {
        Set-Variable -Name:("$($PesterParamsHash_VariableName.VariableNamePrefix)$($_.Name)") -Value:($_.Value) -Scope:('Global')
    }
}