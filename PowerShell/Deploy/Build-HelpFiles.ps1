Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][ValidateNotNullOrEmpty()][System.String]$ModuleName = 'JumpCloud'
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Path to module root')][ValidateNotNullOrEmpty()][System.String]$ModulePath = (Get-Location).Path # $PSScriptRoot
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Which parameter set to be used for New-MarkdownHelp')][ValidateNotNullOrEmpty()][ValidateSet('FromCommand', 'FromModule')][System.String]$NewMarkdownHelpParamSet = 'FromCommand'
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Language locale')][ValidateNotNullOrEmpty()][System.String]$Locale = 'en-US'
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'For adding comment based help')][ValidateNotNullOrEmpty()][System.Boolean]$AddCommentBasedHelp = $false
)
# Define misc. vars
$FilePath_Psd1 = "$ModulePath/$ModuleName.psd1"
$FolderPath_Docs = "$ModulePath/Docs"
$FolderPath_enUS = "$ModulePath/$Locale"
$FilePath_ModulePagePath = "$FolderPath_Docs/$ModuleName.md"
Write-Host ("[status]Creating/Updating help files")
Try
{
    Write-Host ("[status]Installing module: PlatyPS")
    Install-Module -Repository:('PSGallery') -Name:('PlatyPS') -Force
    # Import module
    Write-Host ("[status]Importing module: $FilePath_Psd1")
    Import-Module ($FilePath_Psd1) -Force
    # Remove existing: .\en-Us\$ModuleName-help.xml and .\en-Us\about_$ModuleName.help.txt
    Remove-Item -Path:("$FolderPath_enUS/*") -Recurse -Force -Verbose
    # Get contents of psd1 file
    $Psd1 = Import-PowerShellDataFile -Path:($FilePath_Psd1)
    #########################################################
    ############### Adding Comment based help ###############
    #########################################################
    If ($AddCommentBasedHelp)
    {
        $FolderPath_Public = "$ModulePath/Public"
        # Move the help contents from docs files to ps1 files
        $DocFiles = Get-ChildItem $FolderPath_Docs
        $DocFiles | ForEach-Object {
            $file = Get-ChildItem $FolderPath_Public -Filter ($_.BaseName + ".ps1") -Recurse
            if ($file.FullName)
            {
                $help = Get-Help -Name $_.BaseName
                $content = Get-Content $file.FullName -Raw
                if ($content -notlike "<#*")
                {
                    $synopsis = ".Synopsis`r`n" + ($help.Synopsis).Trim()
                    $description = ".Description`r`n" + ($help.description.text).Trim()
                    $examples = $help.examples.example | ForEach-Object {
                        $Example = $_
                        $ExampleCode = If ($Example.code -like '*C:\>*')
                        {
                            ($Example.code).split(">")[1]
                        }
                        Else
                        {
                            $Example.code
                        }
                        (".Example`r`n" + ($ExampleCode).Trim() + "`r`n`r`n" + ($Example.remarks.text).Trim())
                    }
                    $notes = If ($help.alertSet.alert.text) { ".Notes`r`n" + ($help.alertSet.alert.text).Trim() }
                    $link = If ($help.relatedLinks.navigationLink.uri) { ".Link`r`n" + ($help.relatedLinks.navigationLink.uri).Trim() }
                    Set-Content $file.FullName -Value "<#", $synopsis, $description, $examples, $notes, $link, "#>"
                    Add-Content $file.FullName -Value $content
                }
            }
        }
        # Import module the second time to reload the updated function files
        Import-Module ($FilePath_Psd1) -Force
        # Remove doc files
        Remove-Item -Path:("$FolderPath_Docs/*") -Recurse -Force -Exclude:("about_$ModuleName.md", "$ModuleName.md")
    }
    #########################################################
    #########################################################
    # If not exist create: .\Docs\about_$ModuleName.md
    If (-not (Test-Path -Path:("$($FolderPath_Docs)/about_$($ModuleName).md")))
    {
        Write-Host ("[status]Creating New-MarkdownAboutHelp")
        New-MarkdownAboutHelp -OutputFolder:($FolderPath_Docs) -AboutName:($ModuleName)
    }
    # Creating help files: .\Docs\*.md
    Write-Host ("[status]Creating help files: .\Docs\*.md")
    Switch ($NewMarkdownHelpParamSet)
    {
        'FromCommand'
        {
            $Psd1.FunctionsToExport | ForEach-Object {
                If (-not (Test-Path -Path:("$($FolderPath_Docs)/$($_).md")))
                {
                    $parameters = @{
                        Command               = $_
                        Force                 = $true
                        AlphabeticParamsOrder = $true
                        OnlineVersionUrl      = "$($Psd1.PrivateData.PSData.ProjectUri)/$($FunctionName)"
                        OutputFolder          = $FolderPath_Docs
                        NoMetadata            = $false
                        UseFullTypeName       = $true
                        ExcludeDontShow       = $true
                        # Encoding              = '<Encoding>'
                        # Session               = '<PSSession>'
                        # Metadata              = '<Hashtable>'
                    }
                    New-MarkdownHelp @parameters
                }
            }
        }
        'FromModule'
        {
            $parameters = @{
                Module                = $ModuleName
                Force                 = $true
                AlphabeticParamsOrder = $true
                OutputFolder          = $FolderPath_Docs
                NoMetadata            = $false
                UseFullTypeName       = $true
                WithModulePage        = $true
                ModulePagePath        = $FilePath_ModulePagePath
                Locale                = $Locale
                HelpVersion           = $Psd1.ModuleVersion
                FwLink                = $Psd1.PrivateData.PSData.ProjectUri
                ExcludeDontShow       = $true
                # Encoding              = '<Encoding>'
                # Session               = '<PSSession>'
                # Metadata              = '<Hashtable>'
            }
            New-MarkdownHelp @parameters
        }
        Default
        {
            Write-Error ("Unknown `$NewMarkdownHelpParamSet value: $NewMarkdownHelpParamSet")
        }
    }
    # Update existing help files
    $parameters = @{
        Path                  = $FolderPath_Docs
        RefreshModulePage     = $true
        ModulePagePath        = $FilePath_ModulePagePath
        AlphabeticParamsOrder = $true
        UseFullTypeName       = $true
        UpdateInputOutput     = $true
        Force                 = $true
        ExcludeDontShow       = $true
        # LogPath               = "$FolderPath_Docs\PlatyPS.log"
        # LogAppend             = $true
        # Encoding              = '<Encoding>'
        # Session               = '<PSSession>'
    }
    Update-MarkdownHelpModule @parameters
    # Manually updating specific feilds within JumpCloud.md
    $ModulePageContent = Get-Content -Path:($FilePath_ModulePagePath) -Raw
    $ModulePageContent = $ModulePageContent.Replace("`r", '')
    $ModulePageContent = $ModulePageContent.Replace("## Description`n{{ Fill in the Description }}", "## Description`n$($Psd1.Description)")
    $ModulePageContent = $ModulePageContent.Replace(($ModulePageContent | Select-String -Pattern:([regex]"(Module Name: )(.*?)(\n)")).Matches.Value.Trim(), "Module Name: $($ModuleName)")
    $ModulePageContent = $ModulePageContent.Replace(($ModulePageContent | Select-String -Pattern:([regex]"(Module Guid: )(.*?)(\n)")).Matches.Value.Trim(), "Module Guid: $($Psd1.Guid)")
    $ModulePageContent = $ModulePageContent.Replace(($ModulePageContent | Select-String -Pattern:([regex]"(Download Help Link: )(.*?)(\n)")).Matches.Value.Trim(), "Download Help Link: $($Psd1.PrivateData.PSData.ProjectUri)")
    $ModulePageContent = $ModulePageContent.Replace(($ModulePageContent | Select-String -Pattern:([regex]"(Help Version: )(.*?)(\n)")).Matches.Value.Trim(), "Help Version: $($Psd1.ModuleVersion)")
    $ModulePageContent = $ModulePageContent.Replace(($ModulePageContent | Select-String -Pattern:([regex]"(Locale: )(.*?)(\n)")).Matches.Value.Trim(), "Locale: $($Locale)")
    $ModulePageContent | Set-Content -Path:($FilePath_ModulePagePath) -Force
    # Creating: .\en-Us\$ModuleName-help.xml and .\en-Us\about_$ModuleName.help.txt
    Write-Host ("[status]Creating: .\en-Us\$ModuleName-help.xml and .\en-Us\about_$ModuleName.help.txt")
    New-ExternalHelp -Path:($FolderPath_Docs) -OutputPath:($FolderPath_enUS) -Force # -ApplicableTag <String> -Encoding <Encoding> -MaxAboutWidth <Int32> -ErrorLogFile <String> -ShowProgress
}
Catch
{
    Write-Error ($_)
}


# Create online versions of the help files in the support.wiki
# Update docs with links to the online docs for 'Get-Help -online' commands

# ##TODO
# ### Add step check out support wiki
# $PathToSupportWikiRepo = ''
# $SupportRepoDocs = $PSScriptRoot + '/Docs'
# $SupportWiki = $PathToSupportWikiRepo + '/support.wiki'
# $Docs = Get-ChildItem -Path:($SupportRepoDocs + '/*.md') -Recurse
# ForEach ($Doc In $Docs)
# {
#     $DocName = $Doc.Name
#     $DocFullName = $Doc.FullName
#     $SupportWikiDocFullName = $SupportWiki + '/' + $DocName
#     $DocContent = Get-Content -Path:($DocFullName)
#     If (Test-Path -Path:($SupportWikiDocFullName))
#     {
#         $SupportWikiDocContent = Get-Content -Path:($SupportWikiDocFullName)
#         $Diffs = Compare-Object -ReferenceObject:($DocContent) -DifferenceObject:($SupportWikiDocContent)
#         If ($Diffs)
#         {
#             Write-Warning -Message:('Diffs found in: ' + $DocName)
#             # are you sure you want to continue?
#         }
#     }
#     Else
#     {
#         Write-Warning -Message:('Creating new file: ' + $DocName)
#     }
#     $NewDocContent = If (($DocContent | Select-Object -First 1) -eq '---')
#     {
#         $DocContent | Select-Object -Skip:(7)
#     }
#     Else
#     {
#         $DocContent
#     }
#     Set-Content -Path:($SupportWikiDocFullName) -Value:($NewDocContent) -Force
# }
# ### Add step check in changes to support wiki