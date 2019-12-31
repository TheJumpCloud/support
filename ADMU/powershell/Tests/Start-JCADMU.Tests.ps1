Describe 'Start-JCADMU' {

    Context 'Form Results'{

       It '$formResults is populated' {

        $FormResults = [PSCustomObject]@{}
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('AcceptEula') -Value:($true)

        (-not [System.String]::IsNullOrEmpty($formResults)) | Should Be $true
       }

       $FormResults = $null
       It '$formResults is not populated' {
        (-not [System.String]::IsNullOrEmpty($formResults)) | Should Be $false

    }
    }
}