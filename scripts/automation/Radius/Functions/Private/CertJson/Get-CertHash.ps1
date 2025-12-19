
function Get-CertHash {
    begin {
        $allCerts = Get-CertInfo -UserCerts
        $shaFuncDef = ${function:Get-CertBySHA}.ToString()
        $deploymentTableDef = ${function:New-DeploymentTable}.ToString()
        $resultsArrayP = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()
    }
    process {
        $allCerts | ForEach-Object -ThrottleLimit 5 -Parallel {
            $ENV:JCEnvironment = $using:JCEnvironment
            $global:PSDefaultParameterValues['*-JcSdk*:ApiHost'] = $using:PSDefaultParameterValues['*-JcSdk*:ApiHost']
            $global:PSDefaultParameterValues['*-JcSdk*:ConsoleHost'] = $using:PSDefaultParameterValues['*-JcSdk*:ConsoleHost']
            # set the required variables
            $JCAPIKEY = $using:JCAPIKEY
            $JCORGID = $using:JCORGID
            $JCRScriptRoot = $using:JCRScriptRoot

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
