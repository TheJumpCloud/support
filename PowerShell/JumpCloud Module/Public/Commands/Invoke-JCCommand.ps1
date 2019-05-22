Function Invoke-JCCommand ()
{
    [CmdletBinding(DefaultParameterSetName = 'NoVariables')]

    param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [String]$trigger,

        [Parameter(ParameterSetName = 'Variables')]
        [int]
        $NumberOfVariables
    )

    DynamicParam
    {

        If ($PSCmdlet.ParameterSetName -eq 'Variables')
        {
            $dict = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            [int]$NewParams = 0
            [int]$ParamNumber = 1

            while ($NewParams -ne $NumberOfVariables)
            {

                $attr = New-Object System.Management.Automation.ParameterAttribute
                $attr.HelpMessage = "Enter a variable name"
                $attr.Mandatory = $true
                $attr.ValueFromPipelineByPropertyName = $true
                $attrColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
                $attrColl.Add($attr)
                $param = New-Object System.Management.Automation.RuntimeDefinedParameter("Variable$ParamNumber`_name", [string], $attrColl)
                $dict.Add("Variable$ParamNumber`_name", $param)

                $attr1 = New-Object System.Management.Automation.ParameterAttribute
                $attr1.HelpMessage = "Enter the Variables value"
                $attr1.Mandatory = $true
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
        if ($JCAPIKEY.length -ne 40) {Connect-JConline}

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

            $Variables = @{}

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

                    $UniqueVariables = $VariableArrayList | select ObjectNumber -Unique

                }


            }

            foreach ($O in  $UniqueVariables)
            {
                $Props = $VariableArrayList | ? ObjectNumber -EQ $O.ObjectNumber

                $VariableName = $Props | ? Type -EQ 'Name'
                $VariableValue = $Props | ? Type -EQ 'Value'

                $Variables.add($VariableName.value, $VariableValue.value)

            }


        }

        $URL = "$JCUrlBasePath/api/command/trigger/$trigger"
        Write-Verbose $URL


        $CommandResults = Invoke-RestMethod -Method POST -Uri $URL -Headers $hdrs -Body $Variables -UserAgent:(Get-JCUserAgent -PSCallStack:(Get-PSCallStack))

        $resultsArray += $CommandResults

    }

    end

    {
        return $resultsArray
    }
}