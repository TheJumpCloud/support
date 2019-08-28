# Load functions
. ((Split-Path -Path:($MyInvocation.MyCommand.Path)) + '\Functions.ps1')
# Define misc static variables
$UserStateMigrationToolPath = 'C:\adk\Assessment and Deployment Kit\User State Migration Tool\'
$FormResults = [PSCustomObject]@{}
#==============================================================================================
# XAML Code - Imported from Visual Studio WPF Application
#==============================================================================================
[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')
[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="JumpCloud ADMU 1.0.0" Height="425.101" Width="980.016" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" ForceCursor="True">
    <Grid Margin="0,0,-0.2,6.287">
        <ListView Name="lvProfileList" HorizontalAlignment="Left" Height="141.629" Margin="9.9,110.146,0,0" VerticalAlignment="Top" Width="944.422">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="System Accounts" DisplayMemberBinding="{Binding 'UserName'}" Width="330"/>
                    <GridViewColumn Header="Last Login" DisplayMemberBinding="{Binding 'LastLogin'}" Width="150"/>
                    <GridViewColumn Header="Currently Active" DisplayMemberBinding="{Binding 'Loaded'}" Width="150" />
                    <GridViewColumn Header="Domain Roaming" DisplayMemberBinding="{Binding 'RoamingConfigured'}" Width="150"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button Name="bDeleteProfile" Content="Select Profile" HorizontalAlignment="Left" Margin="861.603,354.337,0,0" VerticalAlignment="Top" Width="92.719" Height="23" IsEnabled="False">
            <Button.Effect>
                <DropShadowEffect/>
            </Button.Effect>
        </Button>
        <GroupBox Header="System Information" HorizontalAlignment="Left" Height="105.146" Margin="595.728,0,0,0" VerticalAlignment="Top" Width="358.594" FontWeight="Bold">
            <Grid HorizontalAlignment="Left" Height="89.178" VerticalAlignment="Top" Width="342.808">
                <Label Content="Local Computer Name:" HorizontalAlignment="Left" Margin="10,2.56,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                <Label Content="Domain Name:" HorizontalAlignment="Left" Margin="10,30.56,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                <Label Name="lbDomainName" Content="" Margin="141.002,29.712,35.609,35.839" Foreground="Black" FontWeight="Normal"/>
                <Label Content="USMT Detected:" HorizontalAlignment="Left" Margin="10,60.659,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                <Label Name="lbComputerName" Content="" HorizontalAlignment="Left" Margin="141.002,1.712,0,0" VerticalAlignment="Top" Width="166.021" FontWeight="Normal"/>
                <Label Name="lbUSMTStatus" Content="" HorizontalAlignment="Left" Margin="141.002,58.339,0,0" VerticalAlignment="Top" Width="165.621" FontWeight="Normal"/>
            </Grid>
        </GroupBox>
        <GroupBox Header="Account Migration Information" HorizontalAlignment="Left" Height="92.562" Margin="483.007,256.775,0,0" VerticalAlignment="Top" Width="471.315" FontWeight="Bold">
            <Grid HorizontalAlignment="Left" Height="66.859" Margin="1.212,2.564,0,0" VerticalAlignment="Top" Width="454.842">
                <Label Content="Local Account Username :" HorizontalAlignment="Left" Margin="7.088,8.287,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                <Label Content="Local Account Password :" HorizontalAlignment="Left" Margin="7.088,36.287,0,0" VerticalAlignment="Top" FontWeight="Normal"/>
                <TextBox Name="tbJumpCloudUserName" HorizontalAlignment="Left" Height="23" Margin="151.11,10.287,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="301.026" Text="Username should match JumpCloud username" Background="#FFC6CBCF" FontWeight="Bold" />
                <TextBox Name="tbTempPassword" HorizontalAlignment="Left" Height="23" Margin="151.11,39.287,0,0" TextWrapping="Wrap" Text="Temp123!" VerticalAlignment="Top" Width="301.026" FontWeight="Normal"/>
            </Grid>
        </GroupBox>
        <GroupBox Header="System Migration Options" HorizontalAlignment="Left" Height="92.562" Margin="9.9,256.775,0,0" VerticalAlignment="Top" Width="471.477" FontWeight="Bold">
            <Grid HorizontalAlignment="Left" Height="62.124" Margin="1.888,2.564,0,0" VerticalAlignment="Top" Width="456.049">
            <Label Name="lbMoreInfo" Content="More Info" HorizontalAlignment="Left" Margin="91.649,38,0,-0.876" VerticalAlignment="Top" Width="65.381" FontSize="11" FontWeight="Bold" FontStyle="Italic" Foreground="#FF005DFF"/>
            <CheckBox Name="cb_accepteula" Content="Accept EULA" HorizontalAlignment="Left" Margin="3.649,44.326,0,0" VerticalAlignment="Top" FontWeight="Normal" IsChecked="True"/>
                <Label Content="JumpCloud Connect Key :" HorizontalAlignment="Left" Margin="3.649,7.999,0,0" VerticalAlignment="Top" AutomationProperties.HelpText="https://console.jumpcloud.com/#/systems/new" ToolTip="https://console.jumpcloud.com/#/systems/new" FontWeight="Normal"/>
                <TextBox Name="tbJumpCloudConnectKey" HorizontalAlignment="Left" Height="23" Margin="148.673,10,0,0" TextWrapping="Wrap" Text="Enter JumpCloud Connect Key" VerticalAlignment="Top" Width="301.026" Background="#FFC6CBCF" FontWeight="Bold"/>
                <CheckBox Name="cb_installjcagent" Content="Install JCAgent" HorizontalAlignment="Left" Margin="155.699,44.326,0,0" VerticalAlignment="Top" FontWeight="Normal" IsChecked="True"/>
                <CheckBox Name="cb_leavedomain" Content="Leave Domain" HorizontalAlignment="Left" Margin="258.699,44.326,0,0" VerticalAlignment="Top" FontWeight="Normal" IsChecked="False"/>
                <CheckBox Name="cb_forcereboot" Content="Force Reboot" HorizontalAlignment="Left" Margin="359.699,44.326,0,0" VerticalAlignment="Top" FontWeight="Normal" IsChecked="False"/>
            </Grid>
        </GroupBox>
        <GroupBox Header="Migration Steps" HorizontalAlignment="Left" Height="105.146" Margin="9.9,0,0,0" VerticalAlignment="Top" Width="580.828" FontWeight="Bold">
            <TextBlock HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Height="69.564" Width="493.495" Margin="0,10,0,0" FontWeight="Normal"><Run Text="1. Select the domain account that you want to migrate to a local account from the list below."/><LineBreak/><Run Text="2. Enter a local account username and password to migrate the selected account to. "/><LineBreak/><Run Text="3. Enter your organizations JumpCloud system connect key."/><LineBreak/><Run Text="4. Click the "/><Run Text="Migrate Profile"/><Run Text=" button."/><LineBreak/><Run/></TextBlock>
        </GroupBox>
    </Grid>
</Window>
'@
# Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
Try
{
    $Form = [Windows.Markup.XamlReader]::Load($reader)
}
Catch
{
    Write-Error "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered.";
    Exit;
}
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
## Set labels and vars on load
# Check PartOfDomain & Disable Controls
$WmiComputerSystem = Get-WmiObject -Class:('Win32_ComputerSystem')
If ($WmiComputerSystem.PartOfDomain)
{
    $DomainName = $WmiComputerSystem.Domain
}
Else
{
    $DomainName = "Not Domain Joined"
    $bDeleteProfile.Content = "No Domain"
    $bDeleteProfile.IsEnabled = $false
    $tbJumpCloudConnectKey.IsEnabled = $false
    $tbJumpCloudUserName.IsEnabled = $false
    $tbTempPassword.IsEnabled = $false
    $lvProfileList.IsEnabled = $false
    $cb_accepteula.IsEnabled = $false
    $cb_installjcagent.IsEnabled = $false
    $cb_leavedomain.IsEnabled = $false
    $cb_forcereboot.IsEnabled = $false
    $lbDomainName.FontWeight = "Bold"
    $lbDomainName.Foreground = "Red"
}
$lbDomainName.Content = $DomainName
$lbComputerName.Content = $WmiComputerSystem.Name
$lbUSMTStatus.Content = Test-Path -Path:($UserStateMigrationToolPath)
Function Validate-Button([object]$tbJumpCloudUserName, [object]$tbJumpCloudConnectKey, [object]$tbTempPassword, [object]$lvProfileList)
{
    Write-Debug ('---------------------------------------------------------')
    Write-Debug ('Valid UserName: ' + $tbJumpCloudUserName)
    Write-Debug ('Valid ConnectKey: ' + $tbJumpCloudConnectKey)
    Write-Debug ('Valid Password: ' + $tbTempPassword)
    Write-Debug ('Has UserName not been selected: ' + [System.String]::IsNullOrEmpty($lvProfileList.SelectedItem.UserName))
    If(![System.String]::IsNullOrEmpty($lvProfileList.SelectedItem.UserName))
    {
        If(!(Validate-IsNotEmpty $tbJumpCloudUserName.Text) -and (Validate-HasNoSpaces $tbJumpCloudUserName.Text) `
        -and (Validate-Is40chars $tbJumpCloudConnectKey.Text) -and (Validate-HasNoSpaces $tbJumpCloudConnectKey.Text) `
        -and !(Validate-IsNotEmpty $tbTempPassword.Text) -and (Validate-HasNoSpaces $tbTempPassword.Text))
        {
            $script:bDeleteProfile.Content = "Migrate Profile"
            $script:bDeleteProfile.IsEnabled = $true
            Return $true
        }
        Else
        {
            $script:bDeleteProfile.Content = "Correct Errors"
            $script:bDeleteProfile.IsEnabled = $false
            Return $false
        }        
    }
    Else
    {
        $script:bDeleteProfile.Content = "Select Profile"
        $script:bDeleteProfile.IsEnabled = $false
        Return $false
    }
}
## Form changes & interactions

# EULA checkbox
$script:AcceptEULA = $true
$cb_accepteula.Add_Checked({$script:AcceptEULA = $true})
$cb_accepteula.Add_Unchecked({$script:AcceptEULA = $false})

# Install JCAgent checkbox
$script:InstallJCAgent = $true
$cb_installjcagent.Add_Checked({$script:InstallJCAgent = $true})
$cb_installjcagent.Add_Unchecked({$script:InstallJCAgent = $false})

# Leave Domain checkbox
$script:LeaveDomain = $false
$cb_leavedomain.Add_Checked({$script:LeaveDomain = $true})
$cb_leavedomain.Add_Unchecked({$script:LeaveDomain = $false})

# Force Reboot checkbox
$script:ForceReboot = $false
$cb_forcereboot.Add_Checked({$script:ForceReboot = $true})
$cb_forcereboot.Add_Unchecked({$script:ForceReboot = $false})

$tbJumpCloudUserName.add_TextChanged( {
        Validate-Button -tbJumpCloudUserName:($tbJumpCloudUserName) -tbJumpCloudConnectKey:($tbJumpCloudConnectKey) -tbTempPassword:($tbTempPassword) -lvProfileList:($lvProfileList)
        If ((!(Validate-IsNotEmpty $tbJumpCloudUserName.Text) -and (Validate-HasNoSpaces $tbJumpCloudUserName.Text)) -eq $false)
        {
            $tbJumpCloudUserName.Background = "#FFC6CBCF"
            $tbJumpCloudUserName.Tooltip = "JumpCloud User Name Can't Be Empty Or Contain Spaces"
        }
        Else
        {
            $tbJumpCloudUserName.Background = "white"
            $tbJumpCloudUserName.Tooltip = $null
            $tbJumpCloudUserName.FontWeight = "Normal"
        }
    })

$tbJumpCloudConnectKey.add_TextChanged( {
        Validate-Button -tbJumpCloudUserName:($tbJumpCloudUserName) -tbJumpCloudConnectKey:($tbJumpCloudConnectKey) -tbTempPassword:($tbTempPassword) -lvProfileList:($lvProfileList)
        If (((Validate-Is40chars $tbJumpCloudConnectKey.Text) -and (Validate-HasNoSpaces $tbJumpCloudConnectKey.Text)) -eq $false)
        {
            $tbJumpCloudConnectKey.Background = "#FFC6CBCF"
            $tbJumpCloudConnectKey.Tooltip = "Connect Key Must be 40chars & Not Contain Spaces"
        }
        Else
        {
            $tbJumpCloudConnectKey.Background = "white"
            $tbJumpCloudConnectKey.Tooltip = $null
            $tbJumpCloudConnectKey.FontWeight = "Normal"
        }
    })
$tbTempPassword.add_TextChanged( {
        Validate-Button -tbJumpCloudUserName:($tbJumpCloudUserName) -tbJumpCloudConnectKey:($tbJumpCloudConnectKey) -tbTempPassword:($tbTempPassword) -lvProfileList:($lvProfileList) 
        If ((!(Validate-IsNotEmpty $tbTempPassword.Text) -and (Validate-HasNoSpaces $tbTempPassword.Text)) -eq $false)
        {
            $tbTempPassword.Background = "#FFC6CBCF"
            $tbTempPassword.Tooltip = "Connect Key Must Be 40chars & No spaces"
        }
        Else
        {
            $tbTempPassword.Background = "white"
            $tbTempPassword.Tooltip = $null
            $tbTempPassword.FontWeight = "Normal"
        }
    })
# Change button when profile selected
$lvProfileList.Add_SelectionChanged( {
        $script:SelectedUserName = ($lvProfileList.SelectedItem.username)
        Validate-Button -tbJumpCloudUserName:($tbJumpCloudUserName) -tbJumpCloudConnectKey:($tbJumpCloudConnectKey) -tbTempPassword:($tbTempPassword) -lvProfileList:($lvProfileList)
    })
# AcceptEULA moreinfo link - Mouse button event
$lbMoreInfo.Add_PreviewMouseDown( {[System.Diagnostics.Process]::start('https://github.com/TheJumpCloud/support/tree/BS-ADMU-version_1.0.0/ADMU#EULA--Legal-Explanation')})
$bDeleteProfile.Add_Click( {
        # Build FormResults object
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('AcceptEula') -Value:($AcceptEula)
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('InstallJCAgent') -Value:($InstallJCAgent)
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('LeaveDomain') -Value:($LeaveDomain)
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('ForceReboot') -Value:($ForceReboot)
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('DomainUserName') -Value:($SelectedUserName.Substring($SelectedUserName.IndexOf('\') + 1))
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('JumpCloudUserName') -Value:($tbJumpCloudUserName.Text)
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('TempPassword') -Value:($tbTempPassword.Text)
        Add-Member -InputObject:($FormResults) -MemberType:('NoteProperty') -Name:('JumpCloudConnectKey') -Value:($tbJumpCloudConnectKey.Text)
        # Close form
        $Form.Close()
    })
# Get list of profiles from computer into listview
$Profiles = Get-WmiObject -Class:('Win32_UserProfile') -Property * | Where-Object {$_.Special -eq $false} | Select-Object SID, RoamingConfigured, Loaded, @{Name = "LastLogin"; EXPRESSION = {$_.ConvertToDateTime($_.lastusetime)}}, @{Name = "UserName"; EXPRESSION = {(New-Object System.Security.Principal.SecurityIdentifier($_.SID)).Translate([System.Security.Principal.NTAccount]).Value}; }
# Put the list of profiles in the profile box
$Profiles | ForEach-Object {$lvProfileList.Items.Add($_) | Out-Null}
#===========================================================================
# Shows the form
#===========================================================================
$Form.Showdialog() | Out-Null
If ($bDeleteProfile.IsEnabled -eq $true)
{
    Return $FormResults
}
