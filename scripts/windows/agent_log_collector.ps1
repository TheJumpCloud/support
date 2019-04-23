## Get OS version and build info
$UNAME=(Get-WmiObject Win32_OperatingSystem | select Caption, Version, BuildNumber)
$SYSINFO=$UNAME.Caption
$BUILD=$UNAME.Version
$SERVICE='jumpcloud-agent'
$JCPATH='C:\Program Files\JumpCloud'
$SERVICEVERSION=(Get-Content -Path (Join-Path -Path $JCPATH -ChildPath Plugins\Contrib\version.txt))
#$JCPATH='..\files\'
$JCLOG='C:\Windows\Temp\'
$STAMP=Get-Date -Format 'yyyyMMddhhmmss'
$TZONE=([TimeZoneInfo]::Local).DisplayName
$STATUS=(Get-Service $SERVICE).Status
$ZIPFILE='jc'+$STAMP
$OUTPUTFILE='.\output.log'

function zipjc {
    ## Take inventory of files to be zipped.
    $TEMP=Join-Path -Path $(pwd) -ChildPath 'temp'
    $INVENTORY=(Get-ChildItem -Exclude *.crt, *.key -Recurse $JCPATH).Name
    if(Test-Path .\$ZIPFILE) {
        $zipjc_out=("`t$ZIPFILE exists moving to $ZIPFILE.bak.zip")
        mv .\$ZIPFILE.zip .\jc$STAMP.bak -Force
        }
    $zipjc_out=("$(foreach($in in $INVENTORY) { ("`t$in`n") })")
    Get-ChildItem -Path $JCPATH | % {
        Copy-Item $_.FullName $TEMP -Recurse -Force -Exclude @("*.crt", "*.key")
}
    Compress-Archive -Path $TEMP -DestinationPath .\$ZIPFILE
    Remove-Item -Path $TEMP -Recurse
    return $zipjc_out
}

function ziplog {
    ## Zip the log files.
    $LOGFILE="jcagent.log"
    cp $JCLOG\$LOGFILE .\$LOGFILE
    Compress-Archive -Path .\$LOGFILE -Update -DestinationPath .\$ZIPFILE
    Remove-Item -Path $LOGFILE
    $ziplog_out+=("`tjcagent.log has been added to $ZIPFILE.zip")
    return $ziplog_out
}

function users {
    ## Get a list of users.
    $USERLIST=(Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='True'").name
    foreach($u in $USERLIST) {
        $users_out+=("`t$u`n")
    }
    return $users_out
}

function jconf {
    ## Get and Format the contents of the jcagent.conf for quick display in the output.log.
    $JCAGENTCONFIG=(Get-Content -Path $JCPATH\Plugins\Contrib\jcagent.conf).Split(',')
    foreach($l in $JCAGENTCONFIG) {
        $jconf_out+=("`t$($l -replace '[{}]', '')`n")
    }
    return $jconf_out
}

function info_out {
    ## Write the output.log file.
    if(Test-Path .\output.log) {
    mv output.log output$STAMP.log -Force
    }
    $("`nOS/BUILD INFO:") | Out-file -Append -FilePath $OUTPUTFILE
    echo `t$SYSINFO | Out-File -Append -FilePath $OUTPUTFILE
    echo `t$BUILD | Out-File -Append -FilePath $OUTPUTFILE
    $("`nSERVICE VERSION:") | Out-File -Append -FilePath $OUTPUTFILE
    echo `t$SERVICEVERSION | Out-File -Append -FilePath $OUTPUTFILE
    $("`nJCAGENT STATUS:") | Out-file -Append -FilePath $OUTPUTFILE
    echo `t$STATUS | Out-File -Append -FilePath $OUTPUTFILE
    $("`nTIMEZONE:") | Out-File -Append -FilePath $OUTPUTFILE
    echo `t$TZONE | Out-File -Append -FilePath $OUTPUTFILE
    $("`nSYSTEM USERS:") | Out-File -Append -FilePath $OUTPUTFILE
    $(users) | Out-File -Append -FilePath $OUTPUTFILE
    $("`nJCAGENT CONFIGURATION:") | Out-File -Append -FilePath $OUTPUTFILE
    $(jconf) | Out-File -Append -FilePath $OUTPUTFILE
    $("`nFILES INCLUDED:") | Out-File -Append -FilePath $OUTPUTFILE
    $(zipjc) | Out-File -Append -FilePath $OUTPUTFILE
    $("`nLOGS INCLUDED:") | Out-File -Append -FilePath $OUTPUTFILE
    $(ziplog) | Out-File -Append -FilePath $OUTPUTFILE

}

info_out
cat .\output.log