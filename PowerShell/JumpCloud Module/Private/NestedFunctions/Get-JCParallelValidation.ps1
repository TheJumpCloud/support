Function Get-JCParallelValidation {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Boolean: Input the value of the function's parallel parameter")][bool]$parallel
    )
    begin {
        $CurrentPSVersion = $PSVersionTable.PSVersion.Major
    }
    process {
        if (($CurrentPSVersion -ge 7) -and ($parallel)) {
            Write-Debug "Parallel set to True, PSVersion greater than 7"
            $ParallelValidation = $true
        }
        elseif ($parallel -eq $false) {
            Write-Debug "Parallel set to False"
            $ParallelValidation = $false
        }
        else {
            Write-Warning "The installed version of PowerShell does not support Parallel functionality. Consider updating to PowerShell 7 to use this feature."
            Write-Warning "Visit aka.ms/powershell-release?tag=stable for latest release"
            Write-Debug "Invalid Parallel, unsupported configuration"
            $ParallelValidation = $false
        }
    }
    end {
        return $ParallelValidation
    }
}