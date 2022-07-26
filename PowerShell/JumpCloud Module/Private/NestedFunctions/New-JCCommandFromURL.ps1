Function New-JCCommandFromURL {
    [CmdletBinding()]
    param (

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        [alias("URL")]
        $GitHubURL

    )

    process {

        # Convert GitHub url to raw url
        $httpUrl = $GitHubURL | Select-String -Pattern "\bmaster.*$" | % { $_.Matches }  | % { $_.Value }
        $rawUrl = "https://raw.githubusercontent.com/TheJumpCloud/support/$httpUrl"

        $rawUrlInvoke = Invoke-WebRequest -Uri $rawUrl -UseBasicParsing -UserAgent:(Get-JCUserAgent)
        $content = [Regex]::Matches($rawUrlInvoke.Content, '#### (Name|commandType).*[\r\n]+(.*)|#### Command[\n\r]+.*\n([\s\S]*?)```$', [System.Text.RegularExpressions.RegexOptions]::Multiline)

        # Command Values
        $Name = $content[0].Groups[2].Value #Name
        $commandType = $content[1].Groups[2].Value #CommandType
        $Command = $content[2].Groups[3].Value #Command

        $NewCommandParams = @{

            name        = $Name
            commandType = $commandType
            command     = $command
        }
        try {

            $NewCommand = New-JCCommand @NewCommandParams

        } catch {

            $NewCommand = $_.ErrorDetails

        }
    }
    end {

        Return $NewCommand

    }
}