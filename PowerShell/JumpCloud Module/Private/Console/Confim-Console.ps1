function Confirm-Console {
    param(
        [Parameter(Mandatory=$False)]
        [string]$Message,
        [Parameter(Mandatory=$False)]
        [scriptblock]$YesAction
    )
    $LinesToClear = 1
    if($Message) {
        Write-Host $Message -ForegroundColor Yellow
        # $LinesToClear += ($Message.Split("`n").Count)
    }
    $res = Find-Interactive -choices @("No", "Yes");
    if($res -eq "Yes" -and $YesAction) {
        Invoke-Command -ScriptBlock $YesAction
        $temp = $true
    } else {
        $temp = $false
    }

    Clear-Console -LinesToClear $LinesToClear
    return $temp
}