function Invoke-TerraformPlan
{
    [CmdletBinding()]
    param
    (
        # The path to the terraform configuration to plan against
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $TerraformConfigPath = $PWD,

        # The Path to the Terraform executable to use
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $TerraformPath = 'terraform',

        # The path to store the output of the Terraform plan
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $OutputPath,

        # A resource to target (useful in testing)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $Target,

        # Whether or not to refresh resources
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]
        $Refresh = $true,

        # Whether or not to use detailed exit codes
        [Parameter(
            Mandatory = $false
        )]
        [bool]
        $DetailedExitCodes = $false,

        #  Limit the number of concurrent operation as Terraform walks the graph.
        [Parameter(
            Mandatory = $false
        )]
        [int]
        $Parallelism,

        # Whether or not to enable color output, defaults to false so as not to break CI/CD tools
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]
        $EnableColor = $false
    )
    $ValidExitCodes = @(0)
    $PlanArgs = @('plan')
    if ($EnableColor -eq $false)
    {
        Write-Verbose "Disabling color output"
        $PlanArgs += @("-no-color")
    }
    if ($OutputPath)
    {
        Write-Verbose "Setting output path to $OutputPath"
        $PlanArgs += "-out=$OutputPath"
    }
    if ($Target)
    {
        Write-Verbose "Targetting $target"
        $PlanArgs += "-target='$Target'"
    }
    if ($Refresh -eq $false)
    {
        Write-Verbose "Disabling refresh"
        $PlanArgs += "-refresh=false"
    }
    if ($DetailedExitCodes -eq $true)
    {
        Write-Verbose "Using detailed exit codes"
        # terraform plan may actually return a non-zero exit code when detailed exit codes are used https://www.terraform.io/docs/cli/commands/plan.html#detailed-exitcode
        $ValidExitCodes += 2
        $PlanArgs += "-detailed-exitcode"
    }
    if ($Parallelism)
    {
        Write-Verbose "Setting Parallelism to $Parallelism"
        $PlanArgs += "-parallelism=$Parallelism"
    }
    try
    {
        $TerraformParams = @{
            FilePath = $TerraformPath
            ArgumentList = $PlanArgs
            ExitCodes = $ValidExitCodes
            WorkingDirectory = $TerraformConfigPath
            PassThru = $true
            SuppressOutput = $true
        }
        if ($VerbosePreference -eq 'Continue')
        {
            $TerraformParams.Remove('SuppressOutput')
        }
        $TerraformPlan = Invoke-NativeCommand @TerraformParams | Select-Object -ExpandProperty OutputContent # We want to extract the plan results for later consumption
    }
    catch
    {
        Write-Error "Terraform plan has failed.`n$($_.Exception.Message)"
    } 
    $TerraformResult = @{
        PlanOutput = $TerraformPlan
    }
    if ($OutputPath)
    {
        try
        {
            $AbsoluteOutputPath = Get-Item $OutputPath | Convert-Path
        }
        catch
        {
            Write-Error "Failed to find Terraform plan output at $OutputPath.`n$($_.Exception.Message)"
        }
        # Add the path to the Terraform plan output to the returned object so it can be piped into Invoke-Terraform show if desired
        $TerraformResult.Add('TerraformPlanPath', $AbsoluteOutputPath)
    }
    Return [pscustomobject]$TerraformResult
}