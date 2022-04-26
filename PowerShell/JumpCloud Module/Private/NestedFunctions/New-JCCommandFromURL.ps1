Function New-JCCommandFromURL
{
    [CmdletBinding()]
    param (

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName = $True)]
        [string]
        [alias("URL")]
        $GitHubURL

    )

    begin
    {

    }

    process
    {

        $Command = Invoke-WebRequest -Uri $GitHubURL -UseBasicParsing -UserAgent:(Get-JCUserAgent) | Select-Object RawContent

        $CodeRaw = $Command | Select-String '(?<=\<code(.*?)\>)((.|\n|\r)*?)(?=<\/code>)' # Contain XML escape characters

        $Code = ((((($CodeRaw.Matches.Value.Trim() -replace "&amp;", "&") -replace "&lt;", "<") -replace "&gt;", ">") -replace "&quot;", '"') -Replace "&apos;", "'") # Replace XML character references

        $Name = (((((($Command -split 'Name</h4>')[1]) -replace "`n", "") -split '</p>')[0]) -replace '(\<p)(.*?)(\>)', '')

        $commandType = (((($Command -split 'commandType</h4>')[1] -replace "`n", "") -split '</p>')[0] -replace '(\<p)(.*?)(\>)', "")

        $NewCommandParams = @{

            name        = $Name
            commandType = $commandType
            command     = $code
        }

        Write-Verbose $NewCommandParams

        try
        {

            $NewCommand = New-JCCommand @NewCommandParams

        }


        catch
        {

            $NewCommand = $_.ErrorDetails

        }
    }

    end
    {

        Return $NewCommand

    }
}