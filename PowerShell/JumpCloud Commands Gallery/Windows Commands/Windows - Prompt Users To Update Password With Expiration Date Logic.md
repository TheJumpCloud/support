#### Name

Windows - Windows - Prompt Users To Update Password With Expiration Date Logic | v1.0 JCCG

#### commandType

windows

#### Command

```
# Populate below variable before running command
$JCAPIKEY = ''
# Message Specific Variables
$MessageBoxStyle = 4 # Look inside the Invoke-BroadcastMessage function for options.
$MessageTitle = 'Update Your JumpCloud Password Immediately' # Text to display in the message box title.
$MessageBody = 'Please update your JumpCloud password immediately. Click "Yes" to send a JumpCloud password reset link to your email.' # Text to display in the message box body.
$TimeOutSec = 60 # How long you want the message box to display to the user.
# $AdvancedLogging = true

#------- Do not modify below this line ------
Function Invoke-BroadcastMessage
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][int]$SessionId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateRange(1, 6)][int]$MessageBoxStyle = 4,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][string]$MessageTitle,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true, Position = 3)][ValidateNotNullOrEmpty()][string]$MessageBody,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][scriptblock]$ConfirmationAction,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][int]$TimeOutSec = 60
    )
    # Message Box Style Options:
    # 1 - Ok, Cancel
    # 2 - Abort, Retry, Ignore
    # 3 - Yes, No, Cancel
    # 4 - Yes, No
    # 5 - Retry, Cancel
    # 6 - Cancel, Try Again, Continue
    try
    {
        # Import classes
        $WTSOpenSig = @"
[DllImport("wtsapi32.dll", SetLastError=true)]
public static extern IntPtr WTSOpenServer(string pServerName);
"@
        $WTSSendMessageSig = @"
[DllImport("wtsapi32.dll", SetLastError = true)]
public static extern bool WTSSendMessage(
IntPtr hServer,
[MarshalAs(UnmanagedType.I4)] int SessionId,
String pTitle,
[MarshalAs(UnmanagedType.U4)] int TitleLength,
String pMessage,
[MarshalAs(UnmanagedType.U4)] int MessageLength,
[MarshalAs(UnmanagedType.U4)] int Style,
[MarshalAs(UnmanagedType.U4)] int Timeout,
[MarshalAs(UnmanagedType.U4)] out int pResponse,
bool bWait);
"@
        $WTSOpen = Add-Type -MemberDefinition:($WTSOpenSig) -Name:('PSWTSOpenServer') -Namespace:('GetLoggedOnUsers') -PassThru
        $WTSMessage = Add-Type -MemberDefinition:($WTSSendMessageSig) -Name:('PSWTSSendMessage') -Namespace:('GetLoggedOnUsers') -PassThru
        # Define target machine
        $Server = $WTSOpen::WTSOpenServer('LocalHost')
        # Define misc variables
        $ComputerName = $Env:ComputerName
        $Response = ''
        # Prompt user for message
        $WTSMessage::WTSSendMessage($Server, $SessionId, $MessageTitle, $MessageTitle.Length, $MessageBody, $MessageBody.Length, $MessageBoxStyle, $TimeOutSec, [ref]$Response, $true) 
        $ResponseMessage = Switch ($Response)
        {
            1 {'Ok'}
            2 {'Cancel'}
            3 {'Abort'}
            4 {'Retry'}
            5 {'Ignore'}
            6 {'Yes'}
            7 {'No'}
            10 {'Try Again'}
            11 {'Continue'}
            32001 {'Function returned without waiting for a response'}
            32000 {'User did not respond within the timeout period'}
            Default {'Unknown Response Value'}
        }
        If ($Response -in @(1, 6, 11))
        {
            If (-not([string]::IsNullOrEmpty($ConfirmationAction)))
            {
                Write-Verbose ("Running command: $ConfirmationAction")
                Invoke-Command -ScriptBlock:($ConfirmationAction)
            }
        }
        $Responses = [PSCustomObject]@{
            'ComputerName'    = $ComputerName;
            'SessionId'       = $SessionId;
            'ResponseId'      = $Response;
            'ResponseMessage' = $ResponseMessage;
        }
        Return $Responses
    }
    Catch
    {
        $Exception = $_.Exception
        $Message = $Exception.Message
        While ($Exception.InnerException)
        {
            $Exception = $Exception.InnerException
            $Message += "`n" + $Exception.Message
        }
        Write-Error ($_.FullyQualifiedErrorId.ToString() + "`n" + $_.InvocationInfo.PositionMessage + "`n" + $Message)
    }
}

Function Invoke-PasswordResetNotification
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$JCAPIKEY,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateRange(1, 6)][int]$MessageBoxStyle = 4,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][string]$MessageTitle,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true, Position = 3)][ValidateNotNullOrEmpty()][string]$MessageBody,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][int]$TimeOutSec = 60
    )
    Try
    {
        #Set JC headers
        Write-Verbose 'Populating API headers'
        $hdrs = @{
            'Content-Type' = 'application/json'
            'Accept'       = 'application/json'
            'X-API-KEY'    = $JCAPIKEY
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        # Get list of users on machine
        $ActiveUsers = (quser) -Replace ('^>', '') -Replace ('\s{2,}', ',') | ConvertFrom-Csv
        # ForEach user
        If ($ActiveUsers) {
            ForEach ($ActiveUser In $ActiveUsers)
            {
                $UserName = $ActiveUser.UserName
                $SessionId = $ActiveUser.ID
                $UserState = $ActiveUser.State
                If ($UserState -eq 'Active')
                {
                    # Get organization info
                    $Settings_Url = 'https://console.jumpcloud.com/api/settings'
                    $Organizations_Url = 'https://console.jumpcloud.com/api/organizations/{0}'
                    $Settings = Invoke-RestMethod -Method:('GET') -Headers:($hdrs) -Uri:($Settings_Url)
                    $Organizations = Invoke-RestMethod -Method:('GET') -Headers:($hdrs) -Uri:($Organizations_Url -f $Settings.ORG_ID)
                    # Get user info
                    $SystemUser_URL = 'https://console.jumpcloud.com/api/systemusers?fields=username email password_expiration_date&search[fields]=username&search[searchTerm]=' + $UserName
                    $SystemUser = Invoke-RestMethod -Method:('GET') -Headers:($hdrs) -Uri:($SystemUser_URL)
                    $SystemUser = $SystemUser.results | Where-Object {$_.username -eq $UserName}
                    If ($SystemUser)
                    {
                        $Id = $SystemUser._id
                        $UserName = $SystemUser.UserName
                        $email = $SystemUser.email
                        $password_expiration_date = $SystemUser.password_expiration_date
                        $passwordExpirationInDays = $Organizations.settings.passwordPolicy.passwordExpirationInDays
                        $password_set_date = (Get-Date($password_expiration_date)).AddDays(-$passwordExpirationInDays)
                        If ($password_expiration_date)
                        {
                            #Convert dates to ToUniversalTime
                            $TodaysDate = (Get-Date).ToUniversalTime()
                            $password_expiration_date_Universal = Get-Date -Date:($password_expiration_date)
                            # Get days till users password expires
                            $TimeSpan = New-TimeSpan -Start:($TodaysDate) -End:($password_expiration_date_Universal)
                            $DaysUntilPasswordExpire = [math]::ceiling($TimeSpan.TotalDays)
                            # If DaysUntilPasswordExpire is less than passwordExpirationInDays
                            If ($DaysUntilPasswordExpire -lt $passwordExpirationInDays)
                            {
                                # Build confirmation action body
                                $ConfirmationAction = {
                                    $JsonBody = '{"isSelectAll":false,"models":[{"_id":"' + $Id + '"}]}'
                                    $PasswordReset_URL = 'https://console.jumpcloud.com/api/systemusers/reactivate'
                                    $PasswordReset = Invoke-RestMethod -Method:('POST') -Headers:($hdrs) -Uri:($PasswordReset_URL) -Body:($JsonBody)
                                }
                                $Response = Invoke-BroadcastMessage -SessionId:($SessionId) -MessageBoxStyle:($MessageBoxStyle) -MessageTitle:($MessageTitle) -MessageBody:($MessageBody -f $DaysUntilPasswordExpire) -ConfirmationAction:($ConfirmationAction) -TimeOutSec:($TimeOutSec)
                                Return $Response | Where-Object {$_.ComputerName} | Select-Object ComputerName, SessionId, ResponseId, ResponseMessage, `
                                @{Name = 'UserName'; Expression = {$UserName}}, `
                                @{Name = 'password_expiration_date'; Expression = {$password_expiration_date}}, `
                                @{Name = 'DaysUntilPasswordExpiration'; Expression = {$DaysUntilPasswordExpire}}, `
                                @{Name = 'PasswordUpdate'; Expression = {'Pending'}}
                            }
                            else
                            {
                                Return [PSCustomObject]@{
                                    'UserName'                 = $UserName
                                    'password_expiration_date' = $password_expiration_date
                                    'DaysUntilPasswordExpires' = $DaysUntilPasswordExpire
                                    'PasswordUpdate'           = 'Complete'
                                }
                            }
                        }
                        else
                        {
                            Write-Error ('Unable to find expiration date for user:' + $UserName)
                        }
                    }
                    Else
                    {
                        Write-Error ('Unable to find user: "' + $UserName + '". Active user is not a JumpCloud user')
                    }
                }
                else 
                {
                    Write-Error ('Cannot read the state of the active user: "' + $UserState + '" Is not a valid state')
                }
            } 
        }
        Else 
        {
            Write-Error ("No active users")
        }
    }
    Catch
    {
        $Exception = $_.Exception
        $Message = $Exception.Message
        While ($Exception.InnerException)
        {
            $Exception = $Exception.InnerException
            $Message += "`n" + $Exception.Message
        }
        Write-Error ($_.FullyQualifiedErrorId.ToString() + "`n" + $_.InvocationInfo.PositionMessage + "`n" + $Message)
    }
}

Invoke-PasswordResetNotification -JCAPIKEY:($JCAPIKEY) -MessageBoxStyle:($MessageBoxStyle) -MessageTitle:($MessageTitle) -MessageBody:($MessageBody) -TimeOutSec:($TimeOutSec)
```

#### Description

1. Runs "quser" command to get a list of all active sessions on the machine.
2. Query the organizations JumpCloud password expiration policy.
3. For each user with an active session query the users password expiration date.
4. If the signed in user has not reset their password on the day the command is run then a notification is sent to the user. **This logic allows the command to be set to run as a repeating on a set of target systems and will only re-prompt users who do not take action and update their passwords.**
5. If the user selects "Yes" then the action will trigger a password reset email to be sent to their inbox. If the user selects "No" then no action will occur.
6. The output will contain the users response to the message box in the ResponseMessage field.


Required Variables:
* JCAPIKEY - This must be populated with your API key.
* Password aging must be enabled in the JumpCloud Organization settings.

![Windows_PasswordUpdate_Notification](https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Files/Windows_PasswordUpdate_Notification.png?raw=true)

#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL 'https://git.io/fhpfr'
```
