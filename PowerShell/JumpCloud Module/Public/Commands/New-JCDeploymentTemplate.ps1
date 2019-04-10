Function New-JCDeploymentTemplate()
{
    [CmdletBinding()]

    param
    (
    )

    begin
    {
        $Banner = @'
       __                          ______ __                   __
      / /__  __ ____ ___   ____   / ____// /____   __  __ ____/ /
 __  / // / / // __  __ \ / __ \ / /    / // __ \ / / / // __  / 
/ /_/ // /_/ // / / / / // /_/ // /___ / // /_/ // /_/ // /_/ /  
\____/ \____//_/ /_/ /_// ____/ \____//_/ \____/ \____/ \____/   
                       /_/                                                      
                              CSV Command Deployment Template

'@
        $Date = Get-Date -Format MMddyyTHHmmss
        $fileName = 'JCDeployment_' + $Date + '.csv'
        Write-Debug $fileName

        $Heading1 = 'The CSV file:'
        $Heading2 = 'Will be created within the directory:'
        
        If ($($PSVersionTable.Platform) -eq "Unix")
        {
            [System.Console]::Clear();
        }
        else
        {
            Clear-Host
        }

        Write-Host $Banner -ForegroundColor Green
        Write-Host $Heading1 -NoNewline
        Write-Host " $fileName`n" -ForegroundColor Yellow
        Write-Host $Heading2 -NoNewline
        Write-Host " $pwd" -ForegroundColor Yellow
        Write-Host ""


        while ($ConfirmFile -ne 'Y' -and $ConfirmFile -ne 'N')
        {
            $ConfirmFile = Read-Host  "Enter Y to confirm or N to change $fileName output location" #Confirm .csv file location creation
        }

        if ($ConfirmFile -eq 'Y')
        {

            $ExportLocation = $pwd
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
            SystemID = $null
        }

        $Done = $false

        while ($Done -eq $false)
        {

            If ($($PSVersionTable.Platform) -eq "Unix")
            {
                [System.Console]::Clear();
            }
            else
            {
                Clear-Host
            }

            Write-Host $Banner -ForegroundColor Green
    
            Write-Host "Enter a column heading for each of the system specific unique variable within the deployment command. `n" -ForegroundColor Yellow
    
            Write-Host "Global variables within the script DO NOT need to be added as column headings." -ForegroundColor Red
            
            Write-Host "`n================ CURRENT DEPLOYMENT CSV TEMPLATE ================= `n"

            foreach ($heading in $CSV.GetEnumerator())
            {
                Write-Host "$($heading.name)," -ForegroundColor Green -NoNewline
               
            }

            Write-Host "`n`n================================================================== `n"


            if ($CSV.count -gt 1)
            {
                Write-Host "Enter 'D' when DONE `n" -ForegroundColor Yellow
                Write-Host "Enter 'C' to CLEAR the CURRENT DEPLOYMENT CSV TEMPLATE and start over`n" -ForegroundColor Yellow
            }

            $VariableName = Read-Host "ENTER the name of the system specific unique variables: "

            switch ($VariableName)
            {
                'D' { $Done = $true }
                'C'
                {
                    $CSV = [ordered]@{
                        SystemID = $null
                    }
                }
                Default
                {
                    try
                    {   
                        if ($VariableName -ne "")
                        {
                            $CSV.add($VariableName, $null)
                        }
                        
                    }
                    catch
                    {
                        Write-Verbose $_.ErrorDetails
                    }
                }
            }

        }

        $CSVheader = New-Object psobject -Property $Csv
    }


    end
    {
        $ExportPath = Test-Path ("$ExportLocation/$FileName")
        if (!$ExportPath )
        {
            Write-Host ""
            $CSVheader | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
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
            $CSVheader | Export-Csv -path "$ExportLocation/$FileName" -NoTypeInformation
            Write-Host 'Creating file '  -NoNewline
            Write-Host $FileName -ForegroundColor Yellow -NoNewline
            Write-Host ' in the location' -NoNewline
            Write-Host " $ExportLocation" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "Do you want to open the file" -NoNewLine
        Write-Host " $FileName`?`n" -ForegroundColor Yellow

        while ($Open -ne 'Y' -and $Open -ne 'N')
        {
            $Open = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($Open -eq 'Y')
        {
            Invoke-Item -path "$ExportLocation/$FileName"

            $Open = $null

        }
        if ($Open -eq 'N') { $Open = $null }

        Write-Host "`nDo you want to export existing system information to CSV?" -ForegroundColor Yellow

        Write-Host "`n(You will need to populate the SystemID column of $FileName with target system JumpCloud SystemIDs)`n"

        while ($ConfirmSystem -ne 'Y' -and $ConfirmSystem -ne 'N')
        {
            $ConfirmSystem = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmSystem -eq 'Y')
        {


            $ExistingSystems = Get-JCSystem -returnProperties hostname, displayName, os, version | Select-Object hostname, displayName, os, version, @{Name = 'SystemID'; Expression = { $_._id } }, lastContact

            $SystemsCSV = 'JCSystems_' + $date + '.csv'

            $ExistingSystems | Export-Csv -path "$ExportLocation/$SystemsCSV" -NoTypeInformation

            Write-Host "`nCreating file "  -NoNewline
            Write-Host "$SystemsCSV" -ForegroundColor Yellow -NoNewline
            Write-Host ' with all existing systems in the location' -NoNewline
            Write-Host " $ExportLocation`n" -ForegroundColor Yellow

            Write-Host "Do you want to open the file" -NoNewLine

            Write-Host " $SystemsCSV `?`n" -ForegroundColor Yellow

            while ($Open -ne 'Y' -and $Open -ne 'N')
            {
                $Open = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($Open -eq 'Y')
            {
                Invoke-Item -path "$ExportLocation/$SystemsCSV"
                $Open = $null
            }
            if ($Open -eq 'N') { $Open = $null }

        }

        Write-Host "`nDo you want to export JumpCloud Command information to CSV?" -ForegroundColor Yellow

        Write-Host "`n(You will need the JumpCloud CommandID to use the Invoke-JCDeployment command)`n"

        while ($ConfirmCommand -ne 'Y' -and $ConfirmCommand -ne 'N')
        {
            $ConfirmCommand = Read-Host  "Enter Y for Yes or N for No"
        }

        if ($ConfirmCommand -eq 'Y')
        {


            $ExistingCommands = Get-JCCommand | Select-Object Name, CommandType, @{Name = 'CommandID'; Expression = { $_._id } }

            $CommandsCSV = 'JCCommands_' + $date + '.csv'

            $ExistingCommands | Export-Csv -path "$ExportLocation/$CommandsCSV" -NoTypeInformation

            Write-Host "`nCreating file "  -NoNewline
            Write-Host $CommandsCSV -ForegroundColor Yellow -NoNewline
            Write-Host ' with all existing commands in the location' -NoNewline
            Write-Host " $ExportLocation`n" -ForegroundColor Yellow

            Write-Host "Do you want to open the file" -NoNewLine

            Write-Host " $CommandsCSV `?`n" -ForegroundColor Yellow

            while ($Open -ne 'Y' -and $Open -ne 'N')
            {
                $Open = Read-Host  "Enter Y for Yes or N for No"
            }

            if ($Open -eq 'Y')
            {
                Invoke-Item -path "$ExportLocation/$CommandsCSV"
                $Open = $null

            }
            if ($Open -eq 'N') { $Open = $null }

        }

    }

}