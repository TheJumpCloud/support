function Test-MGGraph () {
    if (Get-Command Connect-MgGraph -eq '$true'-ErrorAction SilentlyContinue) {
        Write-Debug -Message "MSGraph module loaded"
    }

    else {
        Write-Debug -Message "MSGraph module is not loaded"

        try {
            Install-Module Microsoft.Graph -Force
        } catch {
            Return 1
        }
    }

}
