Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Name of module')][ValidateNotNullOrEmpty()][System.String]$ModuleName = 'JumpCloud'
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Path to module root')][ValidateNotNullOrEmpty()][System.String]$ModulePath = './PowerShell/JumpCloud Module' # $PSScriptRoot
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Which parameter set to be used for New-MarkdownHelp')][ValidateNotNullOrEmpty()][ValidateSet('FromCommand', 'FromModule')][System.String]$NewMarkdownHelpParamSet = 'FromCommand'
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Language locale')][ValidateNotNullOrEmpty()][System.String]$Locale = 'en-Us'
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'For adding comment based help')][ValidateNotNullOrEmpty()][System.Boolean]$AddCommentBasedHelp = $false
)
# modified from source: https://github.com/PowerShell/platyPS/issues/595#issuecomment-1820971702
function Remove-CommonParameterFromMarkdown {
    <#
        .SYNOPSIS
            Remove a PlatyPS generated parameter block.

        .DESCRIPTION
            Removes parameter block for the provided parameter name from the markdown file provided.

    #>
    param(
        [Parameter(Mandatory)]
        [string[]]
        $Path,

        [Parameter(Mandatory = $false)]
        [string[]]
        $ParameterName = @('ProgressAction')
    )
    $ErrorActionPreference = 'Stop'
    $Docs = Get-ChildItem -Path $Path -Recurse
    foreach ($p in $Docs) {
        Write-Host "[status]Removing ProgressAction from $p"
        $content = (Get-Content -Path $p -Raw).TrimEnd()
        $updateFile = $false
        foreach ($param in $ParameterName) {
            if (-not ($Param.StartsWith('-'))) {
                $param = "-$($param)"
            }
            # Remove the parameter block
            $pattern = "(?m)^### $param\r?\n[\S\s]*?(?=#{2,3}?)"
            $newContent = $content -replace $pattern, ''
            # Remove the parameter from the syntax block
            $pattern = " \[$param\s?.*?]"
            $newContent = $newContent -replace $pattern, ''
            if ($null -ne (Compare-Object -ReferenceObject $content -DifferenceObject $newContent)) {
                Write-Verbose "Added $param to $p"
                # Update file content
                $content = $newContent
                $updateFile = $true
            }
        }
        # Save file if content has changed
        if ($updateFile) {
            $newContent | Out-File -Encoding utf8 -FilePath $p
            Write-Verbose "Updated file: $p"
        }
    }
    return
}
# Define misc. vars
$FilePath_Psd1 = "$ModulePath/$ModuleName.psd1"
$FolderPath_Docs = "$ModulePath/Docs"
$FolderPath_enUS = "$ModulePath/$Locale"
$FilePath_ModulePagePath = "$FolderPath_Docs/$ModuleName.md"
Write-Host ("[status]Creating/Updating help files")
Try {
    Write-Host ("[status]Installing module: PlatyPS")
    Install-Module -Repository:('PSGallery') -Name:('PlatyPS') -Force
    # Import module
    Write-Host ("[status]Importing module: $FilePath_Psd1")
    Import-Module ($FilePath_Psd1) -Force -Global
    # Remove existing: .\en-Us\$ModuleName-help.xml and .\en-Us\about_$ModuleName.help.txt
    Remove-Item -Path:("$FolderPath_enUS/*") -Recurse -Force -Verbose
    # Get contents of psd1 file
    $Psd1 = Import-PowerShellDataFile -Path:($FilePath_Psd1)
    #########################################################
    ############### Adding Comment based help ###############
    #########################################################
    If ($AddCommentBasedHelp) {
        $FolderPath_Public = "$ModulePath/Public"
        # Move the help contents from docs files to ps1 files
        $DocFiles = Get-ChildItem $FolderPath_Docs
        $DocFiles | ForEach-Object {
            $file = Get-ChildItem $FolderPath_Public -Filter ($_.BaseName + ".ps1") -Recurse
            if ($file.FullName) {
                $help = Get-Help -Name $_.BaseName
                $content = Get-Content $file.FullName -Raw
                if ($content -notlike "<#*") {
                    $synopsis = ".Synopsis`r`n" + ($help.Synopsis).Trim()
                    $description = ".Description`r`n" + ($help.description.text).Trim()
                    $examples = $help.examples.example | ForEach-Object {
                        $Example = $_
                        $ExampleCode = If ($Example.code -like '*C:\>*') {
                            ($Example.code).split(">")[1]
                        } Else {
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
        Import-Module ($FilePath_Psd1) -Force -Global
        # Remove doc files
        Remove-Item -Path:("$FolderPath_Docs/*") -Recurse -Force -Exclude:("about_$ModuleName.md", "$ModuleName.md")
    }
    #########################################################
    #########################################################
    # If not exist create: .\Docs\about_$ModuleName.md
    If (-not (Test-Path -Path:("$($FolderPath_Docs)/about_$($ModuleName).md"))) {
        Write-Host ("[status]Creating New-MarkdownAboutHelp")
        New-MarkdownAboutHelp -OutputFolder:($FolderPath_Docs) -AboutName:($ModuleName)
    }
    # Creating help files: .\Docs\*.md
    Write-Host ("[status]Creating help files: .\Docs\*.md")
    Switch ($NewMarkdownHelpParamSet) {
        'FromCommand' {
            $Psd1.FunctionsToExport | ForEach-Object {
                If (-not (Test-Path -Path:("$($FolderPath_Docs)/$($_).md"))) {
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
        'FromModule' {
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
        Default {
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
    # Remove ProgressAction from Doc files (PowerShell 7.4.1 with PlatyPS)
    Remove-CommonParameterFromMarkdown -Path:($FolderPath_Docs)
    $ProgressActionXML1 = @"
      <command:parameter required="false" variableLength="true" globbing="false" pipelineInput="False" position="named" aliases="proga">
        <maml:name>ProgressAction</maml:name>
        <maml:description>
          <maml:para>{{ Fill ProgressAction Description }}</maml:para>
        </maml:description>
        <command:parameterValue required="true" variableLength="false">System.Management.Automation.ActionPreference</command:parameterValue>
        <dev:type>
          <maml:name>System.Management.Automation.ActionPreference</maml:name>
          <maml:uri />
        </dev:type>
        <dev:defaultValue>None</dev:defaultValue>
      </command:parameter>
"@
    $ProgressActionXML2 = @"
        <command:parameter required="false" variableLength="true" globbing="false" pipelineInput="False" position="named" aliases="proga">
          <maml:name>ProgressAction</maml:name>
          <maml:description>
            <maml:para>{{ Fill ProgressAction Description }}</maml:para>
          </maml:description>
          <command:parameterValue required="true" variableLength="false">System.Management.Automation.ActionPreference</command:parameterValue>
          <dev:type>
            <maml:name>System.Management.Automation.ActionPreference</maml:name>
            <maml:uri />
          </dev:type>
          <dev:defaultValue>None</dev:defaultValue>
        </command:parameter>
"@
    (Get-Content -Path "$FolderPath_enUS/$ModuleName-help.xml" -Raw).Replace($ProgressActionXML1, '') | Set-Content "$FolderPath_enUS/$ModuleName-help.xml"
    (Get-Content -Path "$FolderPath_enUS/$ModuleName-help.xml" -Raw).Replace($ProgressActionXML2, '') | Set-Content "$FolderPath_enUS/$ModuleName-help.xml"

} Catch {
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