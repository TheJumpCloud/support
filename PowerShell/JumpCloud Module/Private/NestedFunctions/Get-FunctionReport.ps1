Function Get-FunctionReport
{
    Param([string[]]$Folder)
    # Get a list of all functions in the current runspace
    $CurrentFunctions = Get-ChildItem -Path:('function:')
    # Load all function files from the module
    $Files = Get-ChildItem -Path:($Folder) -Recurse | Where-Object { $_.Extension -eq '.ps1' }
    # Loop through each function file
    $FunctionList = ForEach ($File In $Files)
    {
        $FileFullName = $File.FullName
        $FileName = $File.Name
        $FileBaseName = $File.BaseName
        # Parse the file and look for function syntax to identify functions
        [regex]$Function_Regex = '(?<=^Function)(.*?)(?=$|\{|\()'
        $FunctionContent = Get-Content -Path:($FileFullName)
        $FunctionRegexMatch =  $FunctionContent | Select-String -Pattern:($Function_Regex) #| Where {-not [System.String]::IsNullOrEmpty($_)}
        $FunctionRegexMatchObject = $FunctionRegexMatch | Select-Object LineNumber, Line, @{Name = 'MatchValue'; Expression = { ($_.Matches.Value).Trim() } }
        # Load the function into the current runspace
        . ($FileFullName)
        # Regather a list of all functions in the current runspace and filter out the functions that existed before loading the function script
        $ScriptFunctions = Get-ChildItem -Path:('function:') | Where-Object { $CurrentFunctions -notcontains $_ }
        # $ScriptFunctions | Select *
        # Remove the function from the current runspace
        $ScriptFunctions | ForEach-Object { Remove-Item -Path:('function:\' + $_) }
        # $ScriptFunctions.Visibility
        $FolderLocation = If ($FileFullName -like '*Private*') { 'Private' }ElseIf ($FileFullName -like '*Public*') { 'Public' } Else { 'Unknown' }
        # Build dataset to perform validations against
        [PSCustomObject]@{
            # 'FullName'   = $FileFullName;
            'FileName'       = $FileName;
            'LineNumber'     = $FunctionRegexMatchObject.LineNumber
            'FileBaseName'   = $FileBaseName;
            'Function'       = $ScriptFunctions.Name
            'MatchValue'     = $FunctionRegexMatchObject.MatchValue
            'Line'           = $FunctionRegexMatchObject.Line
            'Verb'           = $ScriptFunctions.Verb
            'Noun'           = $ScriptFunctions.Noun
            'FolderLocation' = $FolderLocation
            'Content'        = $FunctionContent
        }
    }
    Return $FunctionList
}