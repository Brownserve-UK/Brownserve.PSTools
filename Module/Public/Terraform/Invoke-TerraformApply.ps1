function Invoke-TerraformApply
{
    [CmdletBinding()]
    param
    (
        # The path to the Terraform configuration
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $TerraformConfigPath = $PWD,

        # The path to the Terraform binary
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $TerraformPath = 'terraform',

        # A Terraform plan output object to be imported and used
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [alias('TerraformPlanPath')]
        [string]
        $PlanFilePath,

        # A resource to target (useful in testing)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $Target,

        # Whether or not to compact warning messages
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]
        $CompactWarnings = $false,

        # Whether or not to disable colo(u)r output, recommended when using programmatically...
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]
        $EnableColor = $false,

        # Limit the number of concurrent operation as Terraform walks the graph.
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [int]
        $Parallelism
    )
    if ($Target -and $PlanFilePath)
    {
        throw "Cannot specify both -Target and -PlanFilePath"
    }
    # Set up our arguments
    $ApplyArgs = @('apply')
    if ($Target)
    {
        Write-Verbose "Targetting resource $Target"
        $ApplyArgs += "-target=$Target"
    }
    if (!$PlanFilePath)
    {
        # If we've got no plan file we'll have to auto approve our changes otherwise it will fail as we have no stdin
        Write-Warning "Auto-approving changes"
        $ApplyArgs += '-auto-approve'
    }
    if ($CompactWarnings -eq $true)
    {
        Write-Verbose "Compacting warning messages"
        $ApplyArgs += '-compact-warnings'
    }
    if ($EnableColor -eq $false)
    {
        Write-Verbose "Disabling color output"
        $ApplyArgs += '-no-color'
    }
    if ($Parallelism)
    {
        Write-Verbose "Setting max parallelism to $Parallelism"
        $ApplyArgs += "-parallelism=$Parallelism"
    }
    # The plan file must be the last argument!
    if ($PlanFilePath)
    {
        Write-Verbose "Using stored plan $PlanFilePath"
        $ApplyArgs += $PlanFilePath
    }
    Write-Verbose "Running 'terraform apply $($ApplyArgs -join ' ')'"
    try
    {
        $ApplyParams = @{
            FilePath = $TerraformPath
            ArgumentList = $ApplyArgs
            WorkingDirectory = $TerraformConfigPath
            PassThru = $true
            SuppressOutput = $true
        }
        if ($VerbosePreference -eq 'Continue')
        {
            $ApplyParams.Remove('SuppressOutput')
        }
        $ApplyOutput = Invoke-NativeCommand @ApplyParams | Select-Object -ExpandProperty OutputContent # We'll want to return this
    }
    catch
    {
        Write-Error "Terraform apply resulted in an error.`n$($_.Exception.Message)"
    }
    Return $ApplyOutput
}