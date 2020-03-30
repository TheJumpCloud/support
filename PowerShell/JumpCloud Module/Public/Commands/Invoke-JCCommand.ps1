Function Invoke-JCCommand ()
{
    [CmdletBinding(DefaultParameterSetName = 'NoVariables')]

    param
    (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0, HelpMessage = 'When creating a JumpCloud command that can be run via the Invoke-JCCommand function the command must be configured for ''Launch Event - Event type: Run on Trigger (webhook)'' During command configuration a ''Trigger Name'' is required. The value of this trigger name is what must be populated when using the Invoke-JCCommand function. To find all JumpCloud Command triggers run: PS C:\> Get-JCCommand | Where-Object launchType -EQ ''trigger''  | Select-Object name, trigger
You can leverage the pipeline and Parameter Binding to populate the -trigger Parameter. This is shown in EXAMPLES 2 and 3.')]
        [String]$trigger,

        [Parameter(ParameterSetName = 'Variables', HelpMessage = 'Denotes the number of variables you wish to send to the JumpCloud command. This parameter creates two dynamic parameters for each variable added. -Variable_1Name = the variable name -Variable1_Value = the value to pass. See EXAMPLE 2 above for full syntax.')]
        [int]$NumberOfVariables
    )

    DynamicParam
    {
        $ParameterSetName = $PSCmdlet.ParameterSetName
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            $ParameterSetName = 'Variables'
            $NumberOfVariables = 2
        }
        If ($ParameterSetName -eq 'Variables')
        {
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            [int]$NewParams = 0
            [int]$ParamNumber = 1

            while ($NewParams -ne $NumberOfVariables)
            {

                $attr = New-Object System.Management.Automation.ParameterAttribute
                $attr.Mandatory = $true
                $attr.HelpMessage = 'Enter a variable name'
                $attr.ValueFromPipelineByPropertyName = $true
                $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl.Add($attr)
                $param = New-Object System.Management.Automation.RuntimeDefinedParameter("Variable$ParamNumber`_name", [string], $attrColl)
                $dict.Add("Variable$ParamNumber`_name", $param)

                $attr1 = New-Object System.Management.Automation.ParameterAttribute
                $attr1.Mandatory = $true
                $attr1.HelpMessage = 'Enter the Variables value'
                $attr1.ValueFromPipelineByPropertyName = $true
                $attrColl1 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl1.Add($attr1)
                $param1 = New-Object System.Management.Automation.RuntimeDefinedParameter("Variable$ParamNumber`_value", [string], $attrColl1)
                $dict.Add("Variable$ParamNumber`_value", $param1)

                $NewParams++
                $ParamNumber++
            }

            return $dict

        }

    }

    begin

    {
        Write-Verbose 'Verifying JCAPI Key'
        if ($JCAPIKEY.length -ne 40) { Connect-JCOnline }

        Write-Verbose 'Populating API headers'
        $hdrs = @{

            'Accept'    = 'application/json'
            'X-API-KEY' = $JCAPIKEY

        }

        if ($JCOrgID)
        {
            $hdrs.Add('x-org-id', "$($JCOrgID)")
        }

        Write-Verbose 'Initilizing resultsArray'
        $resultsArray = @()

        Write-Debug $PSCmdlet.ParameterSetName

    }

    process

    {

        if ($PSCmdlet.ParameterSetName -eq 'Variables')
        {

            $Variables = @{ }

            $VariableArrayList = New-Object System.Collections.ArrayList

            foreach ($param in $PSBoundParameters.GetEnumerator())
            {


                if ($param.Key -like "Variable*")
                {
                    $RawObject = [pscustomobject]@{

                        ObjectNumber = ($Param.key).Split('_')[0]
                        Type         = ($Param.key).Split('_')[1]
                        Value        = $Param.value
                    }

                    $VariableArrayList.Add($RawObject) | Out-Null

                    $UniqueVariables = $VariableArrayList | Select-Object ObjectNumber -Unique

                }


            }

            foreach ($O in  $UniqueVariables)
            {
                $Props = $VariableArrayList | Where-Object ObjectNumber -EQ $O.ObjectNumber

                $VariableName = $Props | Where-Object Type -EQ 'Name'
                $VariableValue = $Props | Where-Object Type -EQ 'Value'

                $Variables.add($VariableName.value, $VariableValue.value)

            }


        }

        $URL = "$JCUrlBasePath/api/command/trigger/$trigger"
        Write-Verbose $URL

        if ($Variables)
        {
            $CommandResults = Invoke-RestMethod -Method POST -Uri $URL -Headers $hdrs -Body:($Variables | ConvertTo-Json) -UserAgent:(Get-JCUserAgent)

        }

        else
        {
            $CommandResults = Invoke-RestMethod -Method POST -Uri $URL -Headers $hdrs -UserAgent:(Get-JCUserAgent)

        }


        $resultsArray += $CommandResults

    }

    end

    {
        return $resultsArray
    }
}