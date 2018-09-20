$SingleAdminAPIKey = ''
Describe "Connect-JCOnline" {

    It "Connects to JumpCloud with a single admin API Key using force" {
        
        $Connect = Connect-JCOnline -JumpCloudAPIKey $SingleAdminAPIKey -force
        $Connect | Should -be $null

    }
}

Describe "New-JCUser" {

    It "Creates a user with the extended attributes" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $NewUser.middlename | Should -Be "middleName"
        $NewUser.displayname | Should -Be "displayName"
        $NewUser.jobTitle | Should -Be "jobTitle"
        $NewUser.employeeIdentifier | Should -Match "employeeIdentifier"
        $NewUser.department | Should -Be "department"
        $NewUser.costCenter | Should -Be "costCenter"
        $NewUser.company | Should -be "Company"
        $NewUser.employeeType | Should -be "employeeType"
        $NewUser.description | Should -be "description"
        $NewUser.location | Should -be "location"

    }

    It "Creates a user with a work address using work city and state" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_city          = "work_city"
            work_state         = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"


        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses.poBox | Should -Be "work_poBox"
        $NewUser.addresses.locality | Should -Be "work_city"
        $NewUser.addresses.region | Should -Be "work_state"
        $NewUser.addresses.postalCode | Should -Be "work_postalCode"
        $NewUser.addresses.country | Should -Be "work_country"

    }

    It "Creates a user with a work address using work locality and region" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"


        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses.poBox | Should -Be "work_poBox"
        $NewUser.addresses.locality | Should -Be "work_city"
        $NewUser.addresses.region | Should -Be "work_state"
        $NewUser.addresses.postalCode | Should -Be "work_postalCode"
        $NewUser.addresses.country | Should -Be "work_country"

    }

    It "Creates a user with a home address using home locality and region" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_locality      = "home_city"
            home_region        = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"


        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses.poBox | Should -Be "home_poBox"
        $NewUser.addresses.locality | Should -Be "home_city"
        $NewUser.addresses.region | Should -Be "home_state"
        $NewUser.addresses.postalCode | Should -Be "home_postalCode"
        $NewUser.addresses.country | Should -Be "home_country"

    }

    It "Creates a user with a home address using home city and state" {

        $UserWithWorkAddress = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
        }

        $NewUser = New-JCUser @UserWithWorkAddress

        $NewUser.addresses.streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses.poBox | Should -Be "home_poBox"
        $NewUser.addresses.locality | Should -Be "home_city"
        $NewUser.addresses.region | Should -Be "home_state"
        $NewUser.addresses.postalCode | Should -Be "home_postalCode"
        $NewUser.addresses.country | Should -Be "home_country"
    }

    It "Creates a user with a home address and work address" {

        $UserWithHomeAndWorkAddress = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"
        }

        $NewUser = New-JCUser @UserWithHomeAndWorkAddress

        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty poBox | Should -Be "work_poBox"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty locality | Should -Be "work_city"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty region | Should -Be "work_state"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode | Should -Be "work_postalCode"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty country | Should -Be "work_country"

        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty poBox |  Should -Be "home_poBox"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty locality | Should -Be "home_city"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty region | Should -Be "home_state"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode | Should -Be "home_postalCode"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty country | Should -Be "home_country"

    }

    It "Creates a user with a home address and work address and new user attributes" {

        $UserWithHomeAndWorkAddressAndAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"
        }

        $NewUser = New-JCUser @UserWithHomeAndWorkAddressAndAttributes

        $NewUser.middlename | Should -Be "middleName"
        $NewUser.displayname | Should -Be "displayName"
        $NewUser.jobTitle | Should -Be "jobTitle"
        $NewUser.employeeIdentifier | Should -Match "employeeIdentifier"
        $NewUser.department | Should -Be "department"
        $NewUser.costCenter | Should -Be "costCenter"
        $NewUser.company | Should -be "Company"
        $NewUser.employeeType | Should -be "employeeType"
        $NewUser.description | Should -be "description"
        $NewUser.location | Should -be "location"

        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress | Should -Be "work_streetAddress"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty poBox | Should -Be "work_poBox"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty locality | Should -Be "work_city"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty region | Should -Be "work_state"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode | Should -Be "work_postalCode"
        $NewUser.addresses | ? type -eq work | Select-Object -ExpandProperty country | Should -Be "work_country"

        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress | Should -Be "home_streetAddress"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty poBox |  Should -Be "home_poBox"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty locality | Should -Be "home_city"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty region | Should -Be "home_state"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode | Should -Be "home_postalCode"
        $NewUser.addresses | ? type -eq home | Select-Object -ExpandProperty country | Should -Be "home_country"

    }

    It "Creates a user with mobile number" {

        $UserWithNumber = @{
            Username      = "$(New-RandomString)"
            FirstName     = "Delete"
            LastName      = "Me"
            Email         = "$(New-RandomString)@pleasedelete.me"
            mobile_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "1234"

    }

    It "Creates a user with home number" {
        $UserWithNumber = @{
            Username    = "$(New-RandomString)"
            FirstName   = "Delete"
            LastName    = "Me"
            Email       = "$(New-RandomString)@pleasedelete.me"
            home_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "1234"
    }

    It "Creates a user with work number" {
        $UserWithNumber = @{
            Username    = "$(New-RandomString)"
            FirstName   = "Delete"
            LastName    = "Me"
            Email       = "$(New-RandomString)@pleasedelete.me"
            work_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "1234"
    }

    It "Creates a user with work mobile number" {
        $UserWithNumber = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            work_mobile_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "1234"
    }
    

    It "Creates a user with work fax number" {
        $UserWithNumber = @{
            Username        = "$(New-RandomString)"
            FirstName       = "Delete"
            LastName        = "Me"
            Email           = "$(New-RandomString)@pleasedelete.me"
            work_fax_number = "1234"
        }

        $NewUser = New-JCUser @UserWithNumber

        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "1234"
    }

    It "Creates a user with all numbers" {
        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"
    }
}

Describe "Set-JCUser" {

    It "Updates a users middle name" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -middlename "new_middle_name"
        $SetUser.middlename | Should -be "new_middle_name"

    }

    It "Updates a users displayName" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -displayname "new_displayName"
        $SetUser.displayname | Should -be "new_displayName"

    }

    It "Updates a users jobTitle" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -jobTitle "new_jobTitle"
        $SetUser.jobTitle | Should -be "new_jobTitle"

    }

    It "Updates a users employeeIdentifier" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -employeeIdentifier "new_employeeIdentifier_$(New-RandomString)"
        $SetUser.employeeIdentifier | Should -Match "new_employeeIdentifier"

    }

    It "Updates a users department" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -department "new_department"
        $SetUser.department | Should -be "new_department"

    }

    It "Updates a users costCenter" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -costCenter "new_costCenter"
        $SetUser.costCenter | Should -be "new_costCenter"

    }

    It "Updates a users company" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -company "new_company"
        $SetUser.company | Should -be "new_company"

    }

    It "Updates a users employeeType" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -employeeType "new_employeeType"
        $SetUser.employeeType | Should -be "new_employeeType"

    }

    It "Updates a users description" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -description "new_description"
        $SetUser.description | Should -be "new_description"

    }

    It "Updates a users location" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -location "new_location"
        $SetUser.location | Should -be "new_location"

    }

    It "Updates a users middle name using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }
    
        $NewUser = New-JCUser @UserWithAttributes
    
        $SetUser = Set-JCUser -UserID $NewUser._id -middlename "new_middle_name"
        $SetUser.middlename | Should -be "new_middle_name"
    
    }
    
    It "Updates a users displayName using userID" {
    
        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -displayname "new_displayName"
        $SetUser.displayname | Should -be "new_displayName"

    }

    It "Updates a users jobTitle using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -jobTitle "new_jobTitle"
        $SetUser.jobTitle | Should -be "new_jobTitle"

    }

    It "Updates a users employeeIdentifier using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -employeeIdentifier "new_employeeIdentifier_$(New-RandomString)"
        $SetUser.employeeIdentifier | Should -Match "new_employeeIdentifier"

    }

    It "Updates a users department using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -department "new_department"
        $SetUser.department | Should -be "new_department"

    }

    It "Updates a users costCenter using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -costCenter "new_costCenter"
        $SetUser.costCenter | Should -be "new_costCenter"

    }

    It "Updates a users company using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -company "new_company"
        $SetUser.company | Should -be "new_company"

    }

    It "Updates a users employeeType using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -employeeType "new_employeeType"
        $SetUser.employeeType | Should -be "new_employeeType"

    }

    It "Updates a users description using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -description "new_description"
        $SetUser.description | Should -be "new_description"

    }

    It "Updates a users location using userID" {

        $UserWithAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
        }

        $NewUser = New-JCUser @UserWithAttributes

        $SetUser = Set-JCUser -UserID $NewUser._id -location "new_location"
        $SetUser.location | Should -be "new_location"

    }
}

Describe "Set-JCUser addresses" {

    It "Updates a users work address" {
        $UserWithHomeAndWorkAddressAndAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"
        }

        $NewUser = New-JCUser @UserWithHomeAndWorkAddressAndAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -work_streetAddress "new_workStreetAddress"

        $SetUser.addresses | ? type -EQ work | Select-Object -ExpandProperty streetAddress | Should -Be "new_workStreetAddress"

        $SetUser = Set-JCUser -Username $NewUser.username -work_poBox "new_work_poBox"

        $SetUser.addresses | ? type -EQ work | Select-Object -ExpandProperty poBox | Should -Be "new_work_poBox"

        $SetUser = Set-JCUser -Username $NewUser.username -work_city "new_work_city"

        $SetUser.addresses | ? type -EQ work | Select-Object -ExpandProperty locality | Should -Be "new_work_city"

        $SetUser = Set-JCUser -Username $NewUser.username -work_state "new_work_state"

        $SetUser.addresses | ? type -EQ work | Select-Object -ExpandProperty region | Should -Be "new_work_state"

        $SetUser = Set-JCUser -Username $NewUser.username -work_postalCode "new_work_postalCode"

        $SetUser.addresses | ? type -EQ work | Select-Object -ExpandProperty postalCode | Should -Be "new_work_postalCode"

        $SetUser = Set-JCUser -Username $NewUser.username -work_country "new_work_country"

        $SetUser.addresses | ? type -EQ work | Select-Object -ExpandProperty country | Should -Be "new_work_country"
    }


    It "Updates a users home address" {
        $UserWithHomeAndWorkAddressAndAttributes = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            MiddleName         = 'middlename'
            displayName        = 'displayName'
            jobTitle           = 'jobTitle'
            employeeIdentifier = "employeeIdentifier_$(New-RandomString)"
            department         = 'department'
            costCenter         = 'costCenter'
            company            = 'company'
            employeeType       = 'employeeType'
            description        = 'description'
            location           = 'location'
            home_streetAddress = "home_streetAddress"
            home_poBox         = "home_poBox"
            home_city          = "home_city"
            home_state         = "home_state"
            home_postalCode    = "home_postalCode"
            home_country       = "home_country"
            work_streetAddress = "work_streetAddress"
            work_poBox         = "work_poBox"
            work_locality      = "work_city"
            work_region        = "work_state"
            work_postalCode    = "work_postalCode"
            work_country       = "work_country"
        }

        $NewUser = New-JCUser @UserWithHomeAndWorkAddressAndAttributes

        $SetUser = Set-JCUser -Username $NewUser.username -home_streetAddress "new_homeStreetAddress"

        $SetUser.addresses | ? type -EQ home | Select-Object -ExpandProperty streetAddress | Should -Be "new_homeStreetAddress"

        $SetUser = Set-JCUser -Username $NewUser.username -home_poBox "new_home_poBox"

        $SetUser.addresses | ? type -EQ home | Select-Object -ExpandProperty poBox | Should -Be "new_home_poBox"

        $SetUser = Set-JCUser -Username $NewUser.username -home_city "new_home_city"

        $SetUser.addresses | ? type -EQ home | Select-Object -ExpandProperty locality | Should -Be "new_home_city"

        $SetUser = Set-JCUser -Username $NewUser.username -home_state "new_home_state"

        $SetUser.addresses | ? type -EQ home | Select-Object -ExpandProperty region | Should -Be "new_home_state"

        $SetUser = Set-JCUser -Username $NewUser.username -home_postalCode "new_home_postalCode"

        $SetUser.addresses | ? type -EQ home | Select-Object -ExpandProperty postalCode | Should -Be "new_home_postalCode"

        $SetUser = Set-JCUser -Username $NewUser.username -home_country "new_home_country"

        $SetUser.addresses | ? type -EQ home | Select-Object -ExpandProperty country | Should -Be "new_home_country"
    }
}

Describe "Set-JCUser phoneNumbers" {

    It "Updates a users mobile number" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -mobile_number "new_mobile_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "new_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

    }

    It "Updates a users home number" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }
    
        $NewUser = New-JCUser @UserWithNumbers
    
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -home_number "new_home_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "new_home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

    }

    It "Updates a users work number" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_number "new_work_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

    }

    It "Updates a users work_mobile_number" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_mobile_number "new_work_mobile_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "new_work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

    }

    It "Updates a users work_fax_number" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_fax_number "new_work_fax_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"

    }

    IT "Updates two numbers on a user" {


        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_fax_number "new_work_fax_number" -work_number "new_work_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
    }

   

    IT "Updates all numbers on a user" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -work_fax_number "new_work_fax_number" -work_number "new_work_number" -home_number "new_home_number" -mobile_number "new_mobile_number" -work_mobile_number "new_work_mobile_number"


        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "new_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "new_home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "new_work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "new_work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
    }
}

Describe "Updating users phoneNumbers and attributes" {
    
    IT "Updates a number and adds an attribute" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }
    
        $NewUser = New-JCUser @UserWithNumbers
    
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"
    

        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'one' -work_fax_number "new_work_fax_number"
    
        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -be "one"
    }

    IT "Updates a number and adds two attribute" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"


        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 2 -Attribute1_name 'attr1' -Attribute1_value 'one' -work_fax_number "new_work_fax_number" -Attribute2_name 'attr2' -Attribute2_value 'two'

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -be "one"
        $UpdatedUser.attributes | Where-Object name -EQ "attr2" | Select-Object -ExpandProperty value | Should -be "two"
    }

    IT "Updates a number and updates an attribute" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"


        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'one'

        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'updated_one' -work_fax_number "new_work_fax_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -be "updated_one"
    }

    IT "Updates a number and updates two attribute" {

        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }

        $NewUser = New-JCUser @UserWithNumbers

        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"


        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 2 -Attribute1_name 'attr1' -Attribute1_value 'one' -Attribute2_name 'attr2' -Attribute2_value 'two'

        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 2 -Attribute1_name 'attr1' -Attribute1_value 'updated_one' -work_fax_number "new_work_fax_number" -Attribute2_name 'attr2' -Attribute2_value 'updated_two'

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -be "updated_one"
        $UpdatedUser.attributes | Where-Object name -EQ "attr2" | Select-Object -ExpandProperty value | Should -be "updated_two"
    }

    IT "Updates a number and removes an attribute" {


        $UserWithNumbers = @{
            Username           = "$(New-RandomString)"
            FirstName          = "Delete"
            LastName           = "Me"
            Email              = "$(New-RandomString)@pleasedelete.me"
            mobile_number      = "mobile_number"
            home_number        = "home_number"
            work_number        = "work_number"
            work_mobile_number = "work_mobile_number"
            work_fax_number    = "work_fax_number"
        }
        
        $NewUser = New-JCUser @UserWithNumbers
        
        $NewUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $NewUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "work_fax_number"

        $UpdatedUser = Set-JCUser -Username $NewUser.username -NumberOfCustomAttributes 1 -Attribute1_name 'attr1' -Attribute1_value 'one' 

        $UpdatedUser = Set-JCUser -Username $NewUser.username -RemoveAttribute 'attr1' -work_fax_number "new_work_fax_number"

        $UpdatedUser.phoneNumbers | Where-Object type -EQ mobile | Select-Object -ExpandProperty number | Should -be "mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ home | Select-Object -ExpandProperty number | Should -be "home_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work | Select-Object -ExpandProperty number | Should -be "work_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_mobile | Select-Object -ExpandProperty number | Should -be "work_mobile_number"
        $UpdatedUser.phoneNumbers | Where-Object type -EQ work_fax | Select-Object -ExpandProperty number | Should -be "new_work_fax_number"
        $UpdatedUser.attributes | Where-Object name -EQ "attr1" | Select-Object -ExpandProperty value | Should -be $Null

    }

}

Describe "Get-JCUser with new attributes" {

    $RandomString = New-RandomStringLower
    
    $UserWithAttributes = @{
        Username           = "$(New-RandomString)"
        FirstName          = "Delete"
        LastName           = "Me"
        Email              = "$(New-RandomString)@pleasedelete.me"
        MiddleName         = "middlename_$RandomString"
        displayName        = "displayname_$RandomString"
        jobTitle           = "jobTitle_$RandomString"
        employeeIdentifier = "employeeIdentifier_$RandomString"
        department         = "department_$RandomString"
        costCenter         = "costCenter_$RandomString"
        company            = "company_$RandomString"
        employeeType       = "employeeType_$RandomString"
        description        = "description_$RandomString"
        location           = "location_$RandomString"
    }

    New-JCUser @UserWithAttributes

    It "Searches for a user by middlename" {

        $Search = Get-JCUser -middlename "middlename_$RandomString" -returnProperties middlename
        $Search.middlename | Should -be "middlename_$RandomString"

    }
    It "Searches for a user by displayname" {
        $Search = Get-JCUser -displayname "displayname_$RandomString" -returnProperties displayname
        $Search.displayname | Should -be "displayname_$RandomString"
    }
    It "Searches for a user by jobTitle" {
        $Search = Get-JCUser -jobTitle "jobTitle_$RandomString" -returnProperties jobTitle
        $Search.jobTitle | Should -be "jobTitle_$RandomString"
    }
    It "Searches for a user by employeeIdentifier" {
        $Search = Get-JCUser -employeeIdentifier "employeeIdentifier_$RandomString" -returnProperties employeeIdentifier
        $Search.employeeIdentifier | Should -be "employeeIdentifier_$RandomString"
    }
    It "Searches for a user by department" {
        $Search = Get-JCUser -department "department_$RandomString" -returnProperties department
        $Search.department | Should -be "department_$RandomString"
    }
    It "Searches for a user by costCenter" {
        $Search = Get-JCUser -costCenter "costCenter_$RandomString" -returnProperties costCenter
        $Search.costCenter | Should -be "costCenter_$RandomString"
    }
    It "Searches for a user by company" {
        $Search = Get-JCUser -company "company_$RandomString" -returnProperties company
        $Search.company | Should -be "company_$RandomString"
    }
    It "Searches for a user by employeeType" {
        $Search = Get-JCUser -employeeType "employeeType_$RandomString" -returnProperties employeeType
        $Search.employeeType | Should -be "employeeType_$RandomString"
    }
    It "Searches for a user by description" {
        $Search = Get-JCUser -description "description_$RandomString" -returnProperties description
        $Search.description | Should -be "description_$RandomString"
    }
    It "Searches for a user by location" {
        $Search = Get-JCUser -location "location_$RandomString" -returnProperties location
        $Search.location | Should -be "location_$RandomString"
    }
}

Describe "Import-JCUsersFromCSV" {
    It "Imports users from a CSV populated with telephony attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_telephonyAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_telephonyAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)
        }
    }

    It "Imports users from a CSV populated with information attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_userInformationAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_userInformationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

        }
    }



    It "Imports users from a CSV populated with user location attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_userLocationAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_userLocationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

    }

    It "Imports users from a CSV populated with telephony, location, and user information attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_allNewAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_allNewAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }
        
    }

    It "Imports users from a CSV populated with telephony, location, user information attributes, group additions, system binding, and custom attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_AllNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_AllNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

            $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty systemAdd | Should -be "Added"
        

            $UserCSVImport | Where-Object Username -eq "$($User.username)" | Select-Object -ExpandProperty GroupsAdd | Select-object Status -Unique | Select-Object -ExpandProperty Status | Should -be "Added"
        }

    }
}

Get-JCUser | ? Email -like *pleasedelete* | Remove-JCUser -force

Describe "Update-JCUsersFromCSV" {
    
    It "Updates users from a CSV populated with telephony attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_telephonyAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_telephonyAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)
        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath ./csv_files/update/UpdateExample_telephonyAttributes.csv -force
        $UserUpdateInfo = Import-Csv ./csv_files/update/UpdateExample_telephonyAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)
        }
    }
    

    It "Updates users from a CSV populated with information attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_userInformationAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_userInformationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath ./csv_files/update/UpdateExample_userInformationAttributes.csv -force
        $UserUpdateInfo = Import-Csv ./csv_files/update/UpdateExample_userInformationAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.MiddleName | Should -be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -be $UpdateUserInfo.location

        }
    }


    It "Updates users from a CSV populated with user location attributes" {
        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_userLocationAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_userLocationAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath ./csv_files/update/UpdateExample_userLocationAttributes.csv -force
        $UserUpdateInfo = Import-Csv ./csv_files/update/UpdateExample_userLocationAttributes.csv

        foreach ($UpdateUser in $UserCSVUpdate)
        {
            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

    }

    It "Updates users from a CSV populated with user telephony, information, and location attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_AllNewAttributes.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_AllNewAttributes.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath ./csv_files/update/UpdateExample_AllNewAttributes.csv -force
        $UserUpdateInfo =  Import-Csv ./csv_files/update/UpdateExample_AllNewAttributes.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {

            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

            $UpdateCheck.MiddleName | Should -be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -be $UpdateUserInfo.location

            $UpdateCheck.mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

        }


    }

    It "Updates users from a CSV populated with user telephony, information, and location attributes and custom attributes" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_AllNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_AllNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath ./csv_files/update/UpdateExample_AllNewAttributesAndAllCustom.csv -force
        $UserUpdateInfo =  Import-Csv ./csv_files/update/UpdateExample_AllNewAttributesAndAllCustom.csv

        foreach ($UpdateUser in $UserUpdateCSVImport)
        {

            $UpdateUserInfo = Get-JCUser -username $UpdateUser.username
            $UpdateCheck = $UserUpdateInfo | Where-Object Username -EQ "$($UpdateUser.username)"
            $GroupSysCheck = $UserUpdateCSVImport | Where-Object Username -EQ "$($UpdateUser.username)"

            $UpdateCheck.home_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.home_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $UpdateCheck.home_city | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $UpdateCheck.home_state | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $UpdateCheck.home_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.home_country | Should -be $($UpdateUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $UpdateCheck.work_streetAddress | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $UpdateCheck.work_poBox | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $UpdateCheck.work_city | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $UpdateCheck.work_state | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $UpdateCheck.work_postalCode | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $UpdateCheck.work_country | Should -be $($UpdateUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

            $UpdateCheck.MiddleName | Should -be $UpdateUserInfo.middleName
            $UpdateCheck.preferredName | Should -be $UpdateUserInfo.displayname
            $UpdateCheck.jobTitle | Should -be $UpdateUserInfo.jobTitle
            $UpdateCheck.employeeIdentifier | Should -be $UpdateUserInfo.employeeIdentifier
            $UpdateCheck.department | Should -be $UpdateUserInfo.department
            $UpdateCheck.costCenter | Should -be $UpdateUserInfo.costCenter
            $UpdateCheck.company | Should -be $UpdateUserInfo.company
            $UpdateCheck.employeeType | Should -be $UpdateUserInfo.employeeType
            $UpdateCheck.decription | Should -be $UpdateUserInfo.decription
            $UpdateCheck.location | Should -be $UpdateUserInfo.location

            $UpdateCheck.mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.home_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $UpdateCheck.work_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $UpdateCheck.work_mobile_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $UpdateCheck.work_fax_number | Should -be $($UpdateUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty systemAdd | Should -be '{"message":"Already Exists"}'
        

            $GroupSysCheck | Where-Object Username -eq "$($UpdateUser.username)" | Select-Object -ExpandProperty GroupsAdd | Select-object Status -Unique | Select-Object -ExpandProperty Status | Should -be "Added"

        }


    }

    It "Updates users from a CSV populated with no information" {

        $UserCSVImport = Import-JCUsersFromCSV -CSVFilePath ./csv_files/import/ImportExample_AllNewAttributesAndAllCustom.csv -force
        $UserImportInfo = Import-Csv ./csv_files/import/ImportExample_AllNewAttributesAndAllCustom.csv

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

        $UserUpdateCSVImport = Update-JCUsersFromCSV -CSVFilePath ./csv_files/update/UpdateExample_NoChanges.csv -force

        foreach ($User in $UserCSVImport)
        {
            $NewUserInfo = Get-JCUser -username $User.username
            $ImportCheck = $UserImportInfo | Where-Object Username -EQ "$($User.username)"

            $ImportCheck.MiddleName | Should -be $NewUserInfo.middleName
            $ImportCheck.preferredName | Should -be $NewUserInfo.displayname
            $ImportCheck.jobTitle | Should -be $NewUserInfo.jobTitle
            $ImportCheck.employeeIdentifier | Should -be $NewUserInfo.employeeIdentifier
            $ImportCheck.department | Should -be $NewUserInfo.department
            $ImportCheck.costCenter | Should -be $NewUserInfo.costCenter
            $ImportCheck.company | Should -be $NewUserInfo.company
            $ImportCheck.employeeType | Should -be $NewUserInfo.employeeType
            $ImportCheck.decription | Should -be $NewUserInfo.decription
            $ImportCheck.location | Should -be $NewUserInfo.location

            $ImportCheck.mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq mobile | Select-Object -ExpandProperty number)
            $ImportCheck.home_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq home | Select-Object -ExpandProperty number)
            $ImportCheck.work_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work | Select-Object -ExpandProperty number)
            $ImportCheck.work_mobile_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_mobile | Select-Object -ExpandProperty number)
            $ImportCheck.work_fax_number | Should -be $($NewUserInfo.phoneNumbers | ? type -eq work_fax | Select-Object -ExpandProperty number)

            $ImportCheck.home_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.home_poBox | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty poBox)
            $ImportCheck.home_city | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty locality)
            $ImportCheck.home_state | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty region)
            $ImportCheck.home_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty postalCode)
            $ImportCheck.home_country | Should -be $($NewUserInfo.addresses | ? type -eq home | Select-Object -ExpandProperty country)

            $ImportCheck.work_streetAddress | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty streetAddress)
            $ImportCheck.work_poBox | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty poBox)
            $ImportCheck.work_city | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty locality)
            $ImportCheck.work_state | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty region)
            $ImportCheck.work_postalCode | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty postalCode)
            $ImportCheck.work_country | Should -be $($NewUserInfo.addresses | ? type -eq work | Select-Object -ExpandProperty country)

        }

    }
}


Get-JCUser | ? Email -like *pleasedelete* | Remove-JCUser -force
