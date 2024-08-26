
function Get-CertHash {
    begin {
        $allCerts = Get-CertInfo -UserCerts
        $shaFuncDef = ${function:Get-CertBySHA}.ToString()
        $deploymentTableDef = ${function:New-DeploymentTable}.ToString()
        $resultsArrayP = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()
    }
    process {
        # $allCerts | Foreach-Object -ThrottleLimit 5 -Parallel {
        #     #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
        #     $resultsArrayP = $using:resultsArrayP
        #     # . $using:JCScriptRoot/Functions/Private/CertResults/Get-CertBySHA.ps1
        #     ${function:Get-CertBySHA} = $using:shaFuncDef
        #     ${function:New-DeploymentTable} = $using:deploymentTableDef
        #     $item = get-CertBySHA -sha1 $PSItem.sha1
        #     if ($item) {
        #         $resultsArrayP.AddOrUpdate("$($PSItem.sha1)", $item, { param($key, $oldValue) $item }) | Out-Null
        #     }
        # }
        $allCerts | Foreach-Object -ThrottleLimit 5 -Parallel {
            #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
            $resultsArrayP = $using:resultsArrayP
            ${function:Get-CertBySHA} = $using:shaFuncDef
            ${function:New-DeploymentTable} = $using:deploymentTableDef
            $item = get-CertBySHA -sha1 $PSItem.sha1
            if ($item) {
                $resultsArrayP.AddOrUpdate("$($PSItem.sha1)", $item, { $item } ) | Out-Null
            }
        }

    }
    end {
        return $resultsArrayP

    }

}
