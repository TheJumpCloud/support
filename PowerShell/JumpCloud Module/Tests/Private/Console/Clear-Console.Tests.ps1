Describe -Tag:('Console') 'Clear-Console' {
    BeforeAll {
        $script:ModuleRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.Parent.FullName
        . (Join-Path $script:ModuleRoot 'Private/Console/Clear-Console.ps1')

        function script:Invoke-ClearConsoleTest {
            param(
                [Parameter(Mandatory)]
                [int]$CurrentLine,

                [Parameter(Mandatory)]
                [int]$BufferWidth,

                [Parameter(Mandatory)]
                [int]$LinesToClear
            )

            $script:CapturedCursorPositions = [System.Collections.Generic.List[int[]]]::new()
            $script:CapturedWrites = [System.Collections.Generic.List[string]]::new()
            $script:TestStartLine = $null

            $source = Get-Content -Path (Join-Path $script:ModuleRoot 'Private/Console/Clear-Console.ps1') -Raw
            $instrumentedSource = $source `
                -replace '\$Host\.UI\.RawUI\.CursorPosition\.Y', '$TestCurrentLine' `
                -replace '\$Host\.UI\.RawUI\.BufferSize\.Width', '$TestBufferWidth' `
                -replace '\[Console\]::SetCursorPosition\(0, \$i\)', '$script:CapturedCursorPositions.Add(@(0, $i))' `
                -replace '\[Console\]::SetCursorPosition\(0, \$startLine\)', '$script:CapturedCursorPositions.Add(@(0, $startLine)); $script:TestStartLine = $startLine' `
                -replace '\[Console\]::Write\(" " \* \$bufferWidth\)', '$script:CapturedWrites.Add((" " * $bufferWidth))'

            $testScript = @"
`$TestCurrentLine = $CurrentLine
`$TestBufferWidth = $BufferWidth
$instrumentedSource
Clear-Console -LinesToClear $LinesToClear
"@

            Invoke-Expression $testScript

            return [PSCustomObject]@{
                StartLine       = $script:TestStartLine
                CursorPositions = @($script:CapturedCursorPositions)
                Writes          = @($script:CapturedWrites)
            }
        }
    }

    Context 'Command metadata' {
        It 'Should expose Clear-Console as a function' {
            Get-Command Clear-Console -ErrorAction Stop | Should -Not -BeNullOrEmpty
        }

        It 'Should declare LinesToClear as a mandatory int parameter' {
            $linesToClearParameter = (Get-Command Clear-Console).Parameters['LinesToClear']
            $linesToClearParameter.Attributes.Mandatory | Should -Be $true
            $linesToClearParameter.ParameterType | Should -Be ([int])
        }
    }

    Context 'Clearing behavior' {
        It 'Should set the final cursor position to start line <ExpectedStartLine> when current line is <CurrentLine> and LinesToClear is <LinesToClear>' -TestCases @(
            @{ CurrentLine = 10; BufferWidth = 80; LinesToClear = 3; ExpectedStartLine = 7 }
            @{ CurrentLine = 5; BufferWidth = 120; LinesToClear = 5; ExpectedStartLine = 0 }
            @{ CurrentLine = 2; BufferWidth = 80; LinesToClear = 10; ExpectedStartLine = 0 }
            @{ CurrentLine = 5; BufferWidth = 80; LinesToClear = 0; ExpectedStartLine = 5 }
        ) {
            $result = Invoke-ClearConsoleTest -CurrentLine $CurrentLine -BufferWidth $BufferWidth -LinesToClear $LinesToClear

            $result.StartLine | Should -Be $ExpectedStartLine
            $result.CursorPositions[-1] | Should -Be @(0, $ExpectedStartLine)
        }

        It 'Should clear each line from start line through the current line when current line is <CurrentLine> and LinesToClear is <LinesToClear>' -TestCases @(
            @{ CurrentLine = 10; BufferWidth = 80; LinesToClear = 3; ExpectedClearedLines = 7..10 }
            @{ CurrentLine = 2; BufferWidth = 80; LinesToClear = 10; ExpectedClearedLines = 0..2 }
        ) {
            $result = Invoke-ClearConsoleTest -CurrentLine $CurrentLine -BufferWidth $BufferWidth -LinesToClear $LinesToClear

            $clearedLines = $result.CursorPositions[0..($result.CursorPositions.Count - 2)] | ForEach-Object { $_[1] }
            $clearedLines | Should -Be $ExpectedClearedLines
        }

        It 'Should write a full buffer-width blank line for each cleared row when buffer width is <BufferWidth>' -TestCases @(
            @{ CurrentLine = 4; BufferWidth = 40; LinesToClear = 2 }
            @{ CurrentLine = 1; BufferWidth = 120; LinesToClear = 1 }
        ) {
            $result = Invoke-ClearConsoleTest -CurrentLine $CurrentLine -BufferWidth $BufferWidth -LinesToClear $LinesToClear

            $result.Writes.Count | Should -Be ($CurrentLine - $result.StartLine + 1)
            foreach ($write in $result.Writes) {
                $write.Length | Should -Be $BufferWidth
                $write | Should -Match '^\s+$'
            }
        }
    }

    Context 'Invocation' {
        It 'Should complete without error for LinesToClear <LinesToClear>' -TestCases @(
            @{ LinesToClear = 0; CurrentLine = 5; BufferWidth = 80 }
            @{ LinesToClear = 1; CurrentLine = 5; BufferWidth = 80 }
            @{ LinesToClear = 10; CurrentLine = 15; BufferWidth = 80 }
        ) {
            { Invoke-ClearConsoleTest -CurrentLine $CurrentLine -BufferWidth $BufferWidth -LinesToClear $LinesToClear } | Should -Not -Throw
        }
    }
}
