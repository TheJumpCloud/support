<### This script will remove all MDM Entries, as well as their
  associated scheduled tasks, from a device###>

###Initialize an array to store Enrollment IDs###
$valueName = "ProviderID"
$EnrollIDs = @()

###Check if the registry path exists###
Test-Path -Path "Registry::HKLM:\SOFTWARE\Microsoft\Enrollments\"
###Get enrollment IDs###
Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    ###Check if the registry key exists and suppress errors###
    if ($item = Get-ItemProperty -LiteralPath $_.PsPath -ErrorAction SilentlyContinue) {
        if ($item.PSObject.Properties.Name -contains $valueName) {
            ###Extracting the last part (GUID) from the path###
            $pathParts = $_.PsPath -split '\\'
            $EnrollID = $pathParts[-1]

            ###Add the enrollment ID to the array###
            $EnrollIDs += $EnrollID

            ###Output the enrollment ID for each iteration###
            Write-Host "Here is the $EnrollID"

            ###Removing Associated Scheduled Tasks###
            $Tasks = Get-ScheduledTask | Where-Object { $psitem.TaskPath -like "\Microsoft\Windows\EnterpriseMgmt\*" }
            if ($EnrollID -match '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}') {
                Write-Host "Found EnrollID - $EnrollID" -ForegroundColor Green
            } else {
                Write-Host "Error parsing EnrollID. Stopping" -ForegroundColor Red
                Break
            }
            Write-Host "Removing scheduledTasks" -ForegroundColor Yellow
            Try {
                $Tasks | ForEach-Object { Unregister-ScheduledTask -InputObject $psitem -Verbose -Confirm:$false }
            } catch {
                Throw $_.Exception.Message
            }
            Write-Host "Done" -ForegroundColor Green
            Write-Host "Trying to remove tasks folder" -ForegroundColor Yellow
            $TaskFolder = Test-Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID"
            try {
                if ($TaskFolder) {
                    Remove-Item -Path "C:\windows\System32\Tasks\Microsoft\Windows\EnterpriseMgmt\$EnrollID" -Force -Verbose
                }
            } catch {
                Throw $_.Exception.Message
            }

            ### Removing Associated Reg Keys ###
            Write-Host "Removing registry keys" -ForegroundColor Yellow
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\Status\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions\$EnrollID -Recurse -Force -Verbose
            }
            $EnrollmentReg = Test-Path -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID
            if ($EnrollmentReg) {
                Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Enrollments\$EnrollID -Recurse -Force
            }

            Write-Host "Done removing registry keys forthe Enrollment ID $EnrollID" -ForegroundColor Green
        }
    }
}

###List Removed Enrollment GUIDs###
Write-Output "Removed the following MDM GUIDs: $($EnrollIDs -join ', ')"
