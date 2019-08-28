# Get OS version and build info
$UNAME=(Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber)
$SYSINFO=$UNAME.Caption
$BUILD=$UNAME.Version
$SERVICE='jumpcloud-agent'
$JCPATH='C:\Program Files\JumpCloud'
$SERVICEVERSION=(Get-Content -Path (Join-Path -Path $JCPATH -ChildPath Plugins\Contrib\version.txt))
$JCLOG='C:\Windows\Temp'
$STAMP=Get-Date -Format 'yyyyMMddhhmmss'
$TZONE=([TimeZoneInfo]::Local).DisplayName
$STATUS=(Get-Service $SERVICE).Status
$WRITEPATH=$HOME+'\Desktop'
$ZIPFILE='jc'+$STAMP
$OUTPUTFILE=$WRITEPATH+'\output.log'

function zipjc {
    # Take inventory of files to be zipped.
    $TEMP=Join-Path -Path $(Get-Location) -ChildPath 'temp'
    $INVENTORY=(Get-ChildItem -Exclude *.crt, *.key -Recurse $JCPATH).Name
    if(Test-Path $WRITEPATH\$ZIPFILE) {
        $zipjc_out=("`t$ZIPFILE exists moving to $ZIPFILE.bak.zip")
        Move-Item $WRITEPATH\$ZIPFILE.zip $WRITEPATH\jc$STAMP.bak -Force
        }
    $zipjc_out=("$(foreach($in in $INVENTORY) { ("`t$in`n") })")
    Get-ChildItem -Path $JCPATH | ForEach-Object {
        Copy-Item $_.FullName $TEMP -Recurse -Force -Exclude @("*.crt", "*.key")
}
    Compress-Archive -Path $TEMP -DestinationPath $WRITEPATH\$ZIPFILE
    Remove-Item -Path $TEMP -Recurse
    return $zipjc_out
}

function ziplog {
    # Zip the log files.
    $fileArray=(Get-ChildItem -Path $JCLOG -Include jc*, Jump* -Name)
    foreach($LOGFILE in $fileArray) {
        Copy-Item $JCLOG\$LOGFILE $WRITEPATH\$LOGFILE
        Compress-Archive -Path $WRITEPATH\$LOGFILE -Update -DestinationPath $WRITEPATH\$ZIPFILE
        Remove-Item -Path $WRITEPATH\$LOGFILE
        $ziplog_out+=("`t$LOGFILE has been added to $ZIPFILE.zip`n")
        }
    return $ziplog_out
}

function users {
    # Get a list of users.
    $USERLIST=(Get-CimInstance -Class Win32_UserAccount -Filter "LocalAccount='True'").name
    foreach($u in $USERLIST) {
        $users_out+=("`t$u`n")
    }
    return $users_out
}

function jconf {
    # Get and Format the contents of the jcagent.conf for quick display in the output.log.
    $JCAGENTCONFIG=(Get-Content -Path $JCPATH\Plugins\Contrib\jcagent.conf).Split(',')
    foreach($l in $JCAGENTCONFIG) {
        $jconf_out+=("`t$($l -replace '[{}]', '')`n")
    }
    return $jconf_out
}

function info_out {
    # Write the output.log file.
    if(Test-Path $OUTPUTFILE) {
        Move-Item $OUTPUTFILE $WRITEPATH\output$STAMP.log -Force
    }
    $("`nOS/BUILD INFO:") | Out-file -Append -FilePath $OUTPUTFILE
    Write-Output `t$SYSINFO | Out-File -Append -FilePath $OUTPUTFILE
    Write-Output `t$BUILD | Out-File -Append -FilePath $OUTPUTFILE
    $("`nSERVICE VERSION:") | Out-File -Append -FilePath $OUTPUTFILE
    Write-Output `t$SERVICEVERSION | Out-File -Append -FilePath $OUTPUTFILE
    $("`nJCAGENT STATUS:") | Out-file -Append -FilePath $OUTPUTFILE
    Write-Output `t$STATUS | Out-File -Append -FilePath $OUTPUTFILE
    $("`nTIMEZONE:") | Out-File -Append -FilePath $OUTPUTFILE
    Write-Output `t$TZONE | Out-File -Append -FilePath $OUTPUTFILE
    $("`nSYSTEM USERS:") | Out-File -Append -FilePath $OUTPUTFILE
    $(users) | Out-File -Append -FilePath $OUTPUTFILE
    $("`nJCAGENT CONFIGURATION:") | Out-File -Append -FilePath $OUTPUTFILE
    $(jconf) | Out-File -Append -FilePath $OUTPUTFILE
    $("`nFILES INCLUDED:") | Out-File -Append -FilePath $OUTPUTFILE
    $(zipjc) | Out-File -Append -FilePath $OUTPUTFILE
    $("`nLOGS INCLUDED:") | Out-File -Append -FilePath $OUTPUTFILE
    $(ziplog) | Out-File -Append -FilePath $OUTPUTFILE
    Compress-Archive -Path $OUTPUTFILE -Update -DestinationPath $WRITEPATH\$ZIPFILE
}

info_out
Get-Content $OUTPUTFILE
