function New-BrownserveGitHubStageReleaseWorkflow
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        [Parameter(Mandatory = $false)]
        [switch]
        $IncludeUseWorkingCopyOption
    )
    begin
    {
        try
        {
            $Template = Get-Content (Join-Path $PSScriptRoot 'templates' 'psmodule_github_stage-release.yaml.template') -Raw
        }
        catch
        {
            throw "Failed to import stage-release workflow template.`n$($_.Exception.Message)"
        }
    }
    process
    {
        $Template = $Template -replace '###MODULE_NAME###', $ModuleName

        if ($IncludeUseWorkingCopyOption)
        {
            $UseWorkingCopyInput = @'
        use_working_copy:
          description: 'Use the working copy of Brownserve.PSTools instead of the published NuGet package'
          required: false
          type: boolean
          default: false
'@
            $UseWorkingCopyConditional = @'
              if ('${{ inputs.use_working_copy }}' -eq 'true') {
                $Params.Add('UseWorkingCopy', $true)
              }
'@
            $Template = $Template -replace '###USE_WORKING_COPY_INPUT###\r?\n', "$UseWorkingCopyInput`n"
            $Template = $Template -replace '###USE_WORKING_COPY_CONDITIONAL###\r?\n', "$UseWorkingCopyConditional`n"
        }
        else
        {
            $Template = $Template -replace '###USE_WORKING_COPY_INPUT###\r?\n', ''
            $Template = $Template -replace '###USE_WORKING_COPY_CONDITIONAL###\r?\n', ''
        }

        return $Template
    }
    end
    {
    }
}
