<#
.SYNOPSIS
Gets JumpCloud workflow templates.
.DESCRIPTION
Get-JCWorkflowTemplate retrieves workflow templates available in JumpCloud.
Supports filtering by Template ID, Name, Category, or listing all available templates.
.EXAMPLE
PS C:\> Get-JCWorkflowTemplate
.EXAMPLE
PS C:\> Get-JCWorkflowTemplate -Id '64f8a123b456c7890def1234'
.EXAMPLE
PS C:\> Get-JCWorkflowTemplate -Name 'User Onboarding'
.EXAMPLE
PS C:\> Get-JCWorkflowTemplate -Category 'Identity Management'
.PARAMETER Id
The ID of the workflow template to retrieve. Aliased to TemplateID.
.PARAMETER Name
The Name of the workflow template to retrieve. Aliased to TemplateName.
.PARAMETER Category
The Category of workflow templates to retrieve. Aliased to TemplateCategory.
#>
function Get-JCWorkflowTemplate {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'ById', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('TemplateID', 'template_id')]
        [System.String]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
        [Alias('TemplateName')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByCategory')]
        [Alias('TemplateCategory')]
        [System.String]
        $Category
    )

    begin {
        Write-Debug 'Verifying JCAPI Key'
        if ([System.String]::IsNullOrEmpty($JCAPIKEY)) {
            Connect-JCOnline
        }
    }

    process {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'ById') {
                $URL = "$JCUrlBasePath/api/v2/workflows/templates/$Id"
                Write-Debug $URL
                return Invoke-JCApi -Method 'GET' -Url $URL
            }

            # For 'All', 'ByName', or 'ByCategory', retrieve templates list
            $URL = "$JCUrlBasePath/api/v2/workflows/templates"
            Write-Debug $URL
            $response = Invoke-JCApi -Method 'GET' -Url $URL

            $templates = if ($null -ne $response.results) { $response.results } else { $response }

            if ($null -eq $templates) {
                $templates = @()
            }

            switch ($PSCmdlet.ParameterSetName) {
                'All' {
                    return $templates
                }
                'ByName' {
                    $matched = @($templates) | Where-Object { $_.name -eq $Name }
                    if (-not $matched -or $matched.Count -eq 0) {
                        throw "Workflow template with Name '$Name' was not found."
                    }
                    if ($matched.Count -gt 1) {
                        throw "Multiple workflow templates found with Name '$Name'. Use -Id instead."
                    }
                    return $matched[0]
                }
                'ByCategory' {
                    $matchedCategory = @($templates) | Where-Object {
                        $_.category -eq $Category -or
                        $_.categoryName -eq $Category -or
                        ($_.categories -and $_.categories -contains $Category)
                    }
                    return $matchedCategory
                }
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            if ($PSCmdlet.ParameterSetName -eq 'ById') {
                throw "Failed to get workflow template for '$Id'. Details: $errorMessage"
            } elseif ($PSCmdlet.ParameterSetName -eq 'ByName') {
                throw "Failed to get workflow template with Name '$Name'. Details: $errorMessage"
            } else {
                throw "Failed to get workflow templates. Details: $errorMessage"
            }
        }
    }
}