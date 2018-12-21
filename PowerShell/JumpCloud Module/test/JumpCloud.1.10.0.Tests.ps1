Describe "Get-JCEvent Functional Tests" {
    $DayLimit_Valid = 44
    $StartTime_Valid = (Get-Date).AddDays(-$DayLimit_Valid).ToUniversalTime()
    $StartTime_Valid_Timespan = New-Timespan -Start:($StartTime_Valid)
    $EndTime_Valid = $StartTime_Valid.AddDays(43)
    $EndTime_Valid_Timespan = New-Timespan -Start:($EndTime_Valid)

    $DayLimit_Invalid = 46
    $StartTime_Invalid = (Get-Date).AddDays(-$DayLimit_Invalid).ToUniversalTime()
    $StartTime_Invalid_Timespan = New-Timespan -Start:($StartTime_Invalid)
    $EndTime_Invalid = $StartTime_Invalid.AddDays(1)
    $EndTime_Invalid_Timespan = New-Timespan -Start:($EndTime_Invalid)


    Context 'Run Get-JCEvent with valid parameters to generate a success.' {
        It 'Should call event API with valid StartDate and no EndDate and API should return data within the specified range.' {
            $JCEvents = Get-JCEvent -StartDate:($StartTime_Valid)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call event API with valid StartDate and valid EndDate and API should return data within the specified range.' {
            $JCEvents = Get-JCEvent -StartDate:($StartTime_Valid) -EndDate:($EndTime_Valid)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
            $DateTimeMaxMin.Maximum | Should -BeLessOrEqual $EndTime_Valid
        }
        It 'Should call event API with valid day and API should return data within the specified range.' {
            $JCEvents = Get-JCEvent -Days:($StartTime_Valid_Timespan.TotalDays)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call event API with valid hour.' {
            $JCEvents = Get-JCEvent -Hours:($StartTime_Valid_Timespan.TotalHours)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call event API with valid minute.' {
            $JCEvents = Get-JCEvent -Minutes:($StartTime_Valid_Timespan.TotalMinutes)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call event API with valid second.' {
            $JCEvents = Get-JCEvent -Seconds:($StartTime_Valid_Timespan.TotalSeconds)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call event API with valid multiple time increments.' {
            $Days = 1
            $Hours = 2
            $Minutes = 3
            $Seconds = 4
            $StartTime = Get-Date
            $JCEvents = Get-JCEvent -Days:($Days) -Hours:($Hours) -Minutes:($Minutes) -Seconds:($Seconds)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterThan ($StartTime.AddDays(-$Days).AddHours(-$Hours).AddMinutes(-$Minutes).AddSeconds(-$Seconds))
            #$JCEvents | Should -BeTrue
        }
    }
    Context 'Run Get-JCEvent with invalid parameters to generate a warning.' {
        It 'Should call event API with the same StartDate and valid EndDate. Should generate a warning and not return an object.' {
            $JCEvents = Get-JCEvent -StartDate:('12/10/2018 10:05') -EndDate:('12/10/2018 10:05') -WarningVariable Warning
            $Warning | Should -Match 'No events found within date range'
            $JCEvents | Should -Be $null
        }
    }
    Context 'Run Get-JCEvent with invalid parameters to generate an error.' {
        It 'Should call event API with invalid StartDate and no EndDate and API should return data within the specified range.' {
            Get-JCEvent -StartDate:($StartTime_Invalid)| Should -Throw

        }
        # It 'Should call event API with invalid StartDate and invalid EndDate and API should return data within the specified range.' {
        #     $JCEvents = Get-JCEvent -StartDate:($StartTime_Invalid) -EndDate:($EndTime_Invalid)
        #     $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
        #     $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Invalid
        #     $DateTimeMaxMin.Maximum | Should -BeLessOrEqual $EndTime_Invalid
        # }
        # It 'Should call event API with invalid day and API should return data within the specified range.' {
        #     $JCEvents = Get-JCEvent -Days:($StartTime_Invalid_Timespan.TotalDays)
        #     $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
        #     $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Invalid
        # }
        # It 'Should call event API with invalid hour.' {
        #     $JCEvents = Get-JCEvent -Hours:($StartTime_Invalid_Timespan.TotalHours)
        #     $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
        #     $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Invalid
        # }
        # It 'Should call event API with invalid minute.' {
        #     $JCEvents = Get-JCEvent -Minutes:($StartTime_Invalid_Timespan.TotalMinutes)
        #     $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
        #     $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Invalid
        # }
        # It 'Should call event API with invalid second.' {
        #     $JCEvents = Get-JCEvent -Seconds:($StartTime_Invalid_Timespan.TotalSeconds)
        #     $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
        #     $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Invalid
        # }
        # It 'Should call event API with invalid multiple time increments.' {
        #     $Days = 1
        #     $Hours = 2
        #     $Minutes = 3
        #     $Seconds = 4
        #     $StartTime = Get-Date
        #     $JCEvents = Get-JCEvent -Days:($Days) -Hours:($Hours) -Minutes:($Minutes) -Seconds:($Seconds)
        #     $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
        #     $DateTimeMaxMin.Minimum | Should -BeGreaterThan ($StartTime.AddDays(-$Days).AddHours(-$Hours).AddMinutes(-$Minutes).AddSeconds(-$Seconds))
        #     #$JCEvents | Should -BeTrue
        # }
    }
}