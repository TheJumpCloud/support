Function New-JCImportTemplate()
{
    [CmdletBinding()]

    param
    (
    )

    begin
    {
        $Banner = @"
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  / 
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /  
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/   
                       /_/                                                     
                                    CSV User Import Template
"@

        $date = Get-Date -Format MM-dd-yyyy
        $fileName = 'JCUserImport_' + $date + '.csv'
        Write-Debug $fileName

        $Heading1 = 'The CSV file:'
        $Heading2 = 'Will be created within the directory:'
        
        Clear-host

        Write-Host $Banner -ForegroundColor Green
        Write-Host $Heading1 -NoNewline
        Write-Host " $fileName" -ForegroundColor Yellow
        Write-Host $Heading2 -NoNewline
        Write-Host " $home" -ForegroundColor Yellow
        Write-Host ""


        while ($ConfirmFile -ne 'Y' -and $ConfirmFile -ne 'N')
        {
            $ConfirmFile = Read-Host  "Enter Y to confirm or N to change $fileName output location" #Confirm .csv file location creation
        }

        if ($ConfirmFile -eq 'Y')
        {

            $ExportLocation = $home
        }

        elseif ($ConfirmFile -eq 'N')
        {
            $ExportLocation = Read-Host "Enter the full path to the folder you wish to create $fileName in"

            while (-not(Test-Path -Path $ExportLocation -PathType Container))
            {
                Write-Host -BackgroundColor Yellow -ForegroundColor Red "The location $ExportLocation does not exist. Try another"
                $ExportLocation = Read-Host "Enter the full path to the folder you wish to create $fileName in"

            }
            Write-Host ""
            Write-Host -BackgroundColor Green -ForegroundColor Black "The .csv file $fileName will be created within the $ExportLocation directory"
            Pause

        }

    }

    process
    {
        $CSV = [ordered]@{
            FirstName = $null
            LastName  = $null
            Username  = $null
            Email     = $null
            Password  = $null
        }

        Write-Host ""
        Write-Host 'Do you want to bind your new users to existing JumpCloud systems during import?'

        while ($ConfirmSystem -ne 'Y' -and $ConfirmSystem -ne 'N')
        {
            $ConfirmSystem = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmSystem -eq 'Y')
        {

            $CSV.add('SystemID', $null)
            $CSV.add('Administrator', $null)

            $ExistingSystems = Get-JCSystem -returnProperties hostname, displayName | Select-Object HostName, DisplayName, @{Name = 'SystemID'; Expression = {$_._id}}, lastContact

            $SystemsName = 'JCSystems_' + $date + '.csv'

            $ExistingSystems | Export-Csv -path "$ExportLocation/$SystemsName" -NoTypeInformation

            Write-Host 'Creating file '  -NoNewline
            Write-Host $SystemsName -ForegroundColor Yellow -NoNewline
            Write-Host ' with all existing systems in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow

        }

        elseif ($ConfirmAttributes -eq 'N') {}

        Write-Host ""
        Write-Host 'Do you want to add the new users to JumpCloud user groups during import?'

        while ($ConfirmGroups -ne 'Y' -and $ConfirmGroups -ne 'N')
        {
            $ConfirmGroups = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmGroups -eq 'Y')
        {
            [int]$GroupNumber = Read-Host  "What is the maximum number of groups you want to add a single user to during import? ENTER A NUMBER"
            [int]$NewGroup = 0
            [int]$GroupID = 1
            $GroupsArray = @()

            while ($NewGroup -ne $GroupNumber)
            {
                $GroupsArray += "Group$GroupID"
                $NewGroup++
                $GroupID++
            }

            foreach ($Group in $GroupsArray)
            {
                $CSV.add($Group, $null)
            }

        }

        elseif ($ConfirmGroups -eq 'N') {}


        Write-Host ""
        Write-Host 'Do you want to add any custom attributes to your users during import?'

        while ($ConfirmAttributes -ne 'Y' -and $ConfirmAttributes -ne 'N')
        {
            $ConfirmAttributes = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmAttributes -eq 'Y')
        {
            [int]$AttributeNumber = Read-Host  "What is the maximum number of custom attributes you want to add to a single user during import? ENTER A NUMBER"
            [int]$NewAttribute = 0
            [int]$AttributeID = 1
            $NewAttributeArrayList = New-Object System.Collections.ArrayList

            while ($NewAttribute -ne $AttributeNumber)
            {
                $temp = New-Object PSObject
                $temp | Add-Member -MemberType NoteProperty -Name AttributeName  -Value "Attribute$AttributeID`_name"
                $temp | Add-Member -MemberType NoteProperty -Name AttributeValue  -Value "Attribute$AttributeID`_value"
                $NewAttributeArrayList.Add($temp) | Out-Null
                $NewAttribute ++
                $AttributeID ++
            }


            foreach ($Attribute in $NewAttributeArrayList)
            {
                $CSV.add($Attribute.AttributeName, $null)
                $CSV.add($Attribute.AttributeValue, $null)
            }

        }

        elseif ($ConfirmAttributes -eq 'N') {}

        $CSVheader = New-Object psobject -Property $Csv
    }


    end
    {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if (!$ExportPath )
        {
            Write-Host ""
            $CSVheader  | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file'  -NoNewline
            Write-Host " $fileName" -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }
        else
        {
            Write-Host ""
            Write-Warning "The file $fileName already exists do you want to overwrite it?" -WarningAction Inquire
            Write-Host ""
            $CSVheader  | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file '  -NoNewline
            Write-Host $FileName -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "Do you want to open the file" -NoNewLine
        Write-Host " $FileName`?" -ForegroundColor Yellow

        while ($Open -ne 'Y' -and $Open -ne 'N')
        {
            $Open = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($Open -eq 'Y')
        {
            Invoke-Item -path "$ExportLocation/$FileName"

        }
        if ($Open -eq 'N') {}
    }

}