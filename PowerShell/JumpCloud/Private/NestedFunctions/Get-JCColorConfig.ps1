<#
.NOTES
Returns object with the color values
    $JCColorConfig.BackgroundColor
    $JCColorConfig.ForegroundColor_UserPrompt
    $JCColorConfig.ForegroundColor_Header
    $JCColorConfig.ForegroundColor_Body
    $JCColorConfig.ForegroundColor_Indentation
    $JCColorConfig.ForegroundColor_Url
    $JCColorConfig.ForegroundColor_Action
    $JCColorConfig.IndentChar
.EXAMPLE
    # Load color scheme
    $JCColorConfig = Get-JCColorConfig
    Write-Host ('Message:') -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Header)
    Write-Host ($JCColorConfig.IndentChar) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Indentation) -NoNewline
    Write-Host ($BodyContent) -BackgroundColor:($JCColorConfig.BackgroundColor) -ForegroundColor:($JCColorConfig.ForegroundColor_Body)
#>
Function Get-JCColorConfig
{
    # Set color scheme
    Return [PSCustomObject]@{
        'BackgroundColor'             = 'Black'
        'ForegroundColor_UserPrompt'  = 'Yellow'
        'ForegroundColor_Header'      = 'Magenta'
        'ForegroundColor_Body'        = 'Green'
        'ForegroundColor_Indentation' = 'Gray'
        'ForegroundColor_Url'         = 'Blue'
        'ForegroundColor_Action'      = 'Gray'
        'ForegroundColor_Important'   = 'Red'
        'IndentChar'                  = '    + '
    }
}
