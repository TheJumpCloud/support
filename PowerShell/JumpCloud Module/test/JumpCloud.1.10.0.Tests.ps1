$Now = Get-Date

$DayLimit_Valid = 45
$StartTime_Valid = $Now.AddDays(-$DayLimit_Valid).ToUniversalTime()
$StartTime_Valid_Timespan = New-Timespan -Start:($StartTime_Valid)
$EndTime_Valid = $StartTime_Valid.AddDays(44)
$Days_Valid = 42
$Hours_Valid = 24
$Minutes_Valid = 1440
$Seconds_Valid = 86400

$DayLimit_Invalid = 46
$StartTime_Invalid = $Now.AddDays(-$DayLimit_Invalid).ToUniversalTime()
$StartTime_Invalid_Timespan = New-Timespan -Start:($StartTime_Invalid)
$EndTime_Invalid = $StartTime_Invalid.AddDays(1)
$Days_Invalid = 46
$Hours_Invalid = 1081
$Minutes_Invalid = 64801
$Seconds_Invalid = 3888001

$StartDateTime_Invalid = '12/10/2018 10:05'
$EndDateTime_Invalid = '12/10/2018 10:05'
Describe "Get-JCEvent Functional Tests" {
    Context 'Run Get-JCEvent with VALID parameters to generate a success.' {
        It 'Should call Event API with VALID StartDate and no EndDate and API should return data within the specified range.' {
            $JCEvents = Get-JCEvent -StartDate:($StartTime_Valid)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call Event API with VALID StartDate and VALID EndDate and API should return data within the specified range.' {
            $JCEvents = Get-JCEvent -StartDate:($StartTime_Valid) -EndDate:($EndTime_Valid)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
            $DateTimeMaxMin.Maximum | Should -BeLessOrEqual $EndTime_Valid
        }
        It 'Should call Event API with VALID day and API should return data within the specified range.' {
            $JCEvents = Get-JCEvent -Days:($StartTime_Valid_Timespan.TotalDays)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call Event API with VALID hours.' {
            $JCEvents = Get-JCEvent -Hours:($StartTime_Valid_Timespan.TotalHours)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call Event API with VALID minutes.' {
            $JCEvents = Get-JCEvent -Minutes:($StartTime_Valid_Timespan.TotalMinutes)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call Event API with VALID seconds.' {
            $JCEvents = Get-JCEvent -Seconds:($StartTime_Valid_Timespan.TotalSeconds)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterOrEqual $StartTime_Valid
        }
        It 'Should call Event API with VALID multiple time increments.' {
            $JCEvents = Get-JCEvent -Days:($Days_Valid) -Hours:($Hours_Valid) -Minutes:($Minutes_Valid) -Seconds:($Seconds_Valid)
            $DateTimeMaxMin = ($JCEvents.time | Measure-Object -Maximum -Minimum)
            $DateTimeMaxMin.Minimum | Should -BeGreaterThan ($Now.AddDays(-$Days_Valid).AddHours(-$Hours_Valid).AddMinutes(-$Minutes_Valid).AddSeconds(-$Seconds_Valid))
        }
    }
    Context 'Run Get-JCEvent with INVALID parameters to generate a warning.' {
        It 'Should call Event API with the same StartDate and VALID EndDate. Should generate a warning and not return an object.' {
            $JCEvents = Get-JCEvent -StartDate:($StartDateTime_Invalid) -EndDate:($EndDateTime_Invalid) -WarningVariable Warning
            $Warning | Should -Match 'No events found within date range'
            $JCEvents | Should -Be $null
        }
    }
    Context 'Run Get-JCEvent with INVALID parameters to generate an error.' {
        It 'Should call Event API with INVALID StartDate and no EndDate and API should return data within the specified range.' {
            {Get-JCEvent -StartDate:($StartTime_Invalid)} | Should Throw "Cannot validate argument on parameter 'StartDate'. Value must be within 45 days of current date."
        }
        It 'Should call Event API with INVALID StartDate and INVALID EndDate and API should return data within the specified range.' {
            {Get-JCEvent -StartDate:($StartTime_Invalid) -EndDate:($EndTime_Invalid)} | Should Throw "Cannot validate argument on parameter 'StartDate'. Value must be within 45 days of current date."
        }
        It 'Should call Event API with INVALID day and API should return data within the specified range.' {
            {Get-JCEvent -Days:($StartTime_Invalid_Timespan.TotalDays)} | Should Throw "Cannot validate argument on parameter 'Days'. Value must be within 45 days of current date."
        }
        It 'Should call Event API with INVALID hours.' {
            {Get-JCEvent -Hours:($StartTime_Invalid_Timespan.TotalHours)} | Should Throw "Cannot validate argument on parameter 'Hours'. Value must be within 1080 hours of current date."
        }
        It 'Should call Event API with INVALID minutes.' {
            {Get-JCEvent -Minutes:($StartTime_Invalid_Timespan.TotalMinutes)} | Should Throw "Cannot validate argument on parameter 'Minutes'. Value must be within 64800 minutes of current date."
        }
        It 'Should call Event API with INVALID seconds.' {
            {Get-JCEvent -Seconds:($StartTime_Invalid_Timespan.TotalSeconds)} | Should Throw "Cannot validate argument on parameter 'Seconds'. Value must be within 3888000 seconds of current date."
        }
        It 'Should call Event API with INVALID multiple time increments.' {
            {Get-JCEvent -Days:($Days_Invalid) -Hours:($Hours_Invalid) -Minutes:($Minutes_Invalid) -Seconds:($Seconds_Invalid)} | Should Throw "Cannot validate argument on parameter 'Days'. Value must be within 45 days of current date."
        }
    }
}